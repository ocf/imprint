{
  description = "OCF WordPress Project";

  inputs = {
    nixpkgs = {
      type = "github";
      owner = "nixos";
      repo = "nixpkgs";
      ref = "nixos-25.11";
    };
  };

  outputs =
    {
      nixpkgs,
      systems,
      ...
    }:
    let
      pkgsFor = system: import nixpkgs { inherit system; };
      forAllSystems = fn: nixpkgs.lib.genAttrs (import systems) (system: fn (pkgsFor system));
    in
    {
      formatter = forAllSystems (pkgs: pkgs.nixfmt-tree);

      packages = forAllSystems (
        pkgs:
        let
          nginxConfigFile = builtins.readFile ./config/nginx.conf;
          nginxConfig = pkgs.writeTextFile {
            name = "nginx.conf";
            text = nginxConfigFile;
            destination = "/conf/wp-nginx.conf";
          };
          phpFpmConfigFile = builtins.readFile ./config/php-fpm.conf;
          poolConfigFile = builtins.readFile ./config/wordpress-pool.conf;
          phpFpmConfig = pkgs.writeTextFile {
            name = "php-fpm.conf";
            text = phpFpmConfigFile;
            destination = "/etc/php-fpm.conf";
          };
          poolConfig = pkgs.writeTextFile {
            name = "wordpress-pool.conf";
            text = poolConfigFile;
            destination = "/etc/php-fpm.d/wordpress-pool.conf";
          };
          wpConfigFile = builtins.readFile ./config/wp-config.php;
          wpConfig = pkgs.writeTextFile {
            name = "wp-config.php";
            text = wpConfigFile;
            destination = "/share/wordpress/wp-config-template.php";
          };
          wpWithConfig = pkgs.wordpress.overrideAttrs (old: {
            postInstall = ''
              cp ${wpConfig}/share/wordpress/wp-config-template.php $out/share/wordpress/wp-config.php
            '';
          });
          cleanup = pkgs.writeShellScriptBin "cleanup-wp" ''
            mkdir var/log/nginx
          '';
          cleanupRoot = pkgs.writeShellScriptBin "cleanup-wp-root" ''
            chown -R nobody:nogroup share/wordpress 
          '';
          startup = pkgs.writeShellScriptBin "startup-wp" ''
            set -e
            if ! wp core is-installed 2>/dev/null; then
              ${pkgs.wp-cli}/bin/wp core install --url="localhost:8080" --title="OCF WordPress Template" --admin_user=admin --admin_password="$(tr -dc '[:alnum:]' < /dev/urandom | head -c256)" --admin_email="wp-admin@ocf.berkeley.edu" --allow-root
            fi
            php-fpm -p / &&
            nginx -c /conf/wp-nginx.conf
          '';
          linkPkgs =
            name: path: pkgsToLink:
            pkgs.runCommand name { } (
              pkgs.lib.strings.concatStringsSep "\n" (
                builtins.map (pkg: "mkdir -p $out/${path} && ln -s ${pkg} $out/${path}/${pkg.name}") pkgsToLink
              )
            );
          themes = linkPkgs "themes" "share/wordpress/wp-content/themes" (
            with pkgs;
            [
              wordpressPackages.themes.twentytwentyfive
              wordpressPackages.themes.twentytwentyfour
            ]
          );
          plugins = linkPkgs "plugins" "share/wordpress/wp-content/plugins" (
            with pkgs;
            [
              wordpressPackages.plugins.hello-dolly
            ]
          );
        in
        {
          docker = pkgs.dockerTools.buildLayeredImage {
            name = "ocf-wordpress-core";
            tag = "latest";

            contents = with pkgs; [
              bash
              coreutils
              vim
              wp-cli
              gnugrep
              mariadb

              nginxConfig
              phpFpmConfig
              poolConfig
              #wpConfig

              #pkgs.wordpress
              wpWithConfig
              nginx
              php

              dockerTools.fakeNss
              dockerTools.binSh

              themes
              plugins
            ];

            #extraCommands = "mkdir var/log/nginx";
            extraCommands = "${cleanup}/bin/cleanup-wp";

            fakeRootCommands = "${cleanupRoot}/bin/cleanup-wp-root";

            config = {
              WorkingDir = "/share/wordpress";
              Cmd = [ "${startup}/bin/startup-wp" ];
            };
          };
        }
      );
    };
}
