{
  description = "OCF WordPress Project";

  inputs = {
    nixpkgs = {
      type = "github";
      owner = "sophiebsw";
      repo = "nixpkgs";
      ref = "fix-wordpress-overriding-26.05";
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
      self,
      nixpkgs,
      systems,
      ...
    }:
    let
      extraPlugins = builtins.fromJSON (builtins.readFile ./pkgs/extraPlugins.json);
      extraPluginLicenses = nixpkgs.lib.genAttrs (nixpkgs.lib.attrNames extraPlugins) (name: "free");
      extraThemes = builtins.fromJSON (builtins.readFile ./pkgs/extraThemes.json);
      extraThemeLicenses = nixpkgs.lib.genAttrs (nixpkgs.lib.attrNames extraThemes) (name: "free");

      overlays = nixpkgs.lib.singleton (
        final: prev: {
          wordpressPackages = prev.wordpressPackages.override (prev: {
            plugins = prev.plugins // extraPlugins;
            pluginLicenses = prev.pluginLicenses // extraPluginLicenses;
            themes = prev.themes // extraThemes;
            themeLicenses = prev.themeLicenses // extraThemeLicenses;
          });
        }
      );

      pkgsFor = system: import nixpkgs { inherit system overlays; };
      forAllSystems = fn: nixpkgs.lib.genAttrs (import systems) (system: fn (pkgsFor system));

    in
    {
      inherit extraPluginLicenses;
      formatter = forAllSystems (pkgs: pkgs.nixfmt-tree);
      wordpress = forAllSystems (pkgs: pkgs.wordpressPackages);

      packages = forAllSystems (
        pkgs:
        let
          timestamp = builtins.readFile (
            pkgs.runCommand "timestamp" { } ''
              date --date='@${toString self.lastModified}' --iso-8601=minutes > $out
            ''
          );
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
              path = "share/wordpress/${name}";
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
              rm -r $out/share/wordpress/wp-content
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
              hestia
            ]
          );
          plugins = mkWpContent "plugins" (
            with pkgs.wordpressPackages.plugins;
            [
              duplicate-page
              elementor
              gtranslate
              themeisle-companion
              updraftplus
              wordpress-importer
              wpforms-lite
              wp-migrate-db
              wpvivid-backuprestore
            ]
          );
        in
        {
          image = pkgs.dockerTools.streamLayeredImage {
            name = "ocf-wordpress-core";
            created = timestamp;
            mtime = timestamp;

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
