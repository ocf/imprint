{
  description = "OCF WordPress Project";

  inputs = {
    nixpkgs = {
      type = "github";
      owner = "nixos";
      repo = "nixpkgs";
      ref = "nixos-25.11";
    };

    systems = {
      type = "github";
      owner = "nix-systems";
      repo = "default";
      ref = "main";
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
          mkShAppInputs =
            name: runtimeInputs:
            pkgs.writeShellApplication {
              inherit name;
              runtimeInputs = [ pkgs.busybox ] ++ runtimeInputs;
              text = builtins.readFile ./bin/${name};
            };
          mkShApp = name: mkShAppInputs name [ ];
          mkConfig =
            name: destination:
            pkgs.writeTextFile {
              inherit name destination;
              text = builtins.readFile ./config/${name};
            };
          mkWpContent =
            name: pkgsToLink:
            let
              path = "share/wordpress/wp-content/${name}";
            in
            pkgs.runCommand name { } ''
              mkdir -p $out/${path}
              ${pkgs.lib.concatMapStrings (pkg: "ln -s ${pkg} $out/${path}/${pkg.wpName}\n") pkgsToLink}
            '';

          nginxConfig = mkConfig "nginx.conf" "/conf/wp-nginx.conf";
          phpFpmConfig = mkConfig "php-fpm.conf" "/etc/php-fpm.conf";
          poolConfig = mkConfig "wordpress-pool.conf" "/etc/php-fpm.d/wordpress-pool.conf";
          wpConfig = mkConfig "wp-config.php" "/share/wordpress/wp-config.php";

          # WordPress determines its install location via the ABSPATH php constant, which is set based
          # on the location of the .php scripts. Overriding the WordPress package to add our config
          # to it is the simplest and most consistent solution.
          wpWithConfig = pkgs.wordpress.overrideAttrs (old: {
            postInstall = ''
              cp ${wpConfig}/share/wordpress/wp-config.php $out/share/wordpress/wp-config.php
            '';
          });

          cleanup = mkShApp "cleanup-wp";
          cleanupRoot = mkShApp "cleanup-wp-root";
          startup = mkShAppInputs "startup-wp" [ pkgs.wp-cli ];

          themes = mkWpContent "themes" (
            with pkgs.wordpressPackages.themes;
            [
              twentytwentyfive
              twentytwentyfour
            ]
          );
          plugins = mkWpContent "plugins" (
            with pkgs.wordpressPackages.plugins;
            [
              hello-dolly
            ]
          );
        in
        {
          docker = pkgs.dockerTools.buildLayeredImage {
            name = "ocf-wordpress-core";
            tag = "latest";

            contents = with pkgs; [
              # development convenience
              wp-cli
              busybox

              nginxConfig
              phpFpmConfig
              poolConfig

              wpWithConfig
              nginx
              php

              dockerTools.fakeNss
              dockerTools.binSh

              themes
              plugins
            ];

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
