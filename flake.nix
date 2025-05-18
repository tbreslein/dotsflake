{
  description = "my dotfiles as a flake";
  inputs = {
    nixpkgs-stable.url = "github:nixos/nixpkgs/nixos-25.05";
    nixpkgs-unstable.url = "github:nixos/nixpkgs/nixos-unstable";

    home-manager = {
      url = "github:nix-community/home-manager/master";
      inputs.nixpkgs.follows = "nixpkgs-unstable";
    };
    nix-darwin = {
      url = "github:nix-darwin/nix-darwin/master";
      inputs.nixpkgs.follows = "nixpkgs-unstable";
    };
  };

  outputs =
    { self
    , nixpkgs-stable
    , nixpkgs-unstable
    , home-manager
    , nix-darwin
    ,
    } @ inputs:
    let
      supportedSystems = [ "x86_64-linux" "aarch64-linux" "aarch64-darwin" ];
      forAllSystems = nixpkgs-stable.lib.genAttrs supportedSystems;

      userConf = {
        name = "tommy";
      };

      mkArgs = system:
        let
          pkgs-stable = import nixpkgs-stable { inherit system; config.allowUnfree = true; };
          pkgs-unstable = import nixpkgs-unstable { inherit system; config.allowUnfree = true; };
        in
        { inherit inputs pkgs-stable pkgs-unstable userConf; };

      mkHome = system: hostname:
        let
          args = mkArgs system;
        in
        {
          "${hostname}" = home-manager.lib.homeManagerConfiguration {
            pkgs = args.pkgs-unstable;
            extraSpecialArgs = args;
            modules = [
              ./modules
              ./hosts/${hostname}/home.nix
            ];
          };
        };
    in
    {
      homeConfigurations =
        (mkHome "x86_64-linux" "kain")
        // (mkHome "x86_64-linux" "raziel");

      darwinConfigurations =
        let
          system = "aarch64-darwin";
          hostname = "tommysmbp";
          home = "/Users/${userConf.name}";
          args = mkArgs system;
        in
        {
          "${hostname}" =
            nix-darwin.lib.darwinSystem {
              inherit system;
              specialArgs = args;
              modules = [
                ./hosts/${hostname}/configuration.nix
                home-manager.darwinModules.home-manager
                {
                  users.users.${userConf.name}.home = "${home}";
                  home-manager = {
                    useGlobalPkgs = true;
                    useUserPackages = true;
                    extraSpecialArgs = args;
                    users.tommy = {
                      imports = [
                        ./modules
                        ./hosts/${hostname}/home.nix
                      ];
                    };
                  };
                }
              ];
            };
        };

      packages = forAllSystems (system:
        let
          pkgs = nixpkgs-unstable.legacyPackages.${system};
          isLinux = pkgs.lib.hasSuffix "linux" system;
          homeRoot = if isLinux then "/home" else "/Users";
          flakeDir = "${homeRoot}/${userConf.name}/dotsflake";
          upgradeCmd =
            let
              cmdPrefix =
                if isLinux
                then "home-manager"
                else "darwin-rebuild";
              flake =
                "--flake ${flakeDir}" +
                (if isLinux
                then "#$(cat /etc/hostname)"
                else "");
            in
            "${cmdPrefix} switch ${flake}";
          updateCmd = "nix flake update --flake ${flakeDir}";
        in
        rec {
          syke = pkgs.writeShellScriptBin "syke" /* bash */ ''
            update() {
              ${updateCmd}
            }
            upgrade() {
              ${upgradeCmd}
            }
            sync() {
              update
              upgrade
            }

            if [[ $# -eq 0 ]]; then
              sync
              exit 0
            fi

            while [[ $# -gt 0 ]] do
              case $1 in
                update)
                  update
                  shift
                  ;;
                upgrade)
                  upgrade
                  shift
                  ;;
                sync)
                  sync
                  shift
                  ;;
              esac
            done
          '';

          default = syke;
        });

      apps = forAllSystems (system: rec {
        syke = {
          type = "app";
          program = "${self.packages.${system}.default}/bin/syke";
        };
        default = syke;
      });
    };
}
