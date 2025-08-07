{
  description = "my dotfiles as a flake";
  inputs = {
    # repositories
    nixpkgs-stable.url = "github:nixos/nixpkgs/nixos-25.05";
    nixpkgs-unstable.url = "github:nixos/nixpkgs/nixos-unstable";
    chaotic.url = "github:chaotic-cx/nyx/nyxpkgs-unstable";

    # system management
    home-manager-stable = {
      url = "github:nix-community/home-manager/release-25.05";
      inputs.nixpkgs.follows = "nixpkgs-stable";
    };
    home-manager-unstable = {
      url = "github:nix-community/home-manager/master";
      inputs.nixpkgs.follows = "nixpkgs-unstable";
    };
    nix-darwin = {
      url = "github:nix-darwin/nix-darwin/master";
      inputs.nixpkgs.follows = "nixpkgs-unstable";
    };
    nix-homebrew.url = "github:zhaofengli/nix-homebrew";
    homebrew-core = {
      url = "github:homebrew/homebrew-core";
      flake = false;
    };
    homebrew-cask = {
      url = "github:homebrew/homebrew-cask";
      flake = false;
    };
    homebrew-bundle = {
      url = "github:homebrew/homebrew-bundle";
      flake = false;
    };

    # apps
    neovim-nightly-overlay = {
      url = "github:nix-community/neovim-nightly-overlay";
      inputs.nixpkgs.follows = "nixpkgs-unstable";
    };
  };

  outputs =
    { nixpkgs-stable
    , nixpkgs-unstable
    , chaotic
    , home-manager-stable
    , home-manager-unstable
    , nix-darwin
    , nix-homebrew
    , homebrew-core
    , homebrew-cask
    , homebrew-bundle
    , ...
    } @ inputs:
    let
      username = "tommy";

      mk-user-conf = lib: system: hostname:
        rec {
          name = username;
          inherit hostname system;
          inherit (hosts."${hostname}") is-linux is-darwin;
          home-dir =
            if is-linux
            then "/home/${name}"
            else "/Users/${name}";
          work-dir = "${home-dir}/work";
          code-dir = "${home-dir}/code";
          dots-dir = "${home-dir}/dotsflake";
          sync-dir = "${home-dir}/sync";

          hosts = {
            elphelt = {
              ip = "192.168.178.90";
              is-linux = true;
              is-darwin = false;
              syncthing-id = "ZZTPUBC-UHGT3I5-YOAXZF3-UDQHGE3-FE5XFMA-B6SQWSW-AKGD3UI-BTBB3QV";
              syncthing-folders = [ "notes" "house-notes" "personal" "security" "wallpapers" ];
            };
            sol = {
              ip = "192.168.178.91";
              is-linux = true;
              is-darwin = false;
              syncthing-id = "ROFGBXL-IPVQEPW-OJSL7O6-ESRCYLE-EI46JFL-KSX4AF7-FXFIDGD-USAXRAQ";
              syncthing-folders = [ "notes" "house-notes" "personal" "security" "wallpapers" ];
            };
            ky = {
              ip = "192.168.178.92";
              is-linux = true;
              is-darwin = false;
              syncthing-id = "UUCQ3DZ-QEF46SM-GK4MTAV-GNHSI4F-ZHC4L2D-U6FY7RC-6INILQA-OYEV2AD";
              syncthing-folders = [ "notes" "house-notes" "personal" "security" "wallpapers" ];
            };
            answer = {
              ip = "192.168.178.93";
              is-linux = false;
              is-darwin = true;
              syncthing-id = "ISYIUF2-TKA6QSR-74YFSUM-BW2C76T-JLDH6MR-EPRG7ZR-3XNF46T-G2V54AM";
              syncthing-folders = [ "notes" "house-notes" "wallpapers" ];
            };
            jacko = {
              ip = "192.168.178.94";
              is-linux = false;
              is-darwin = false;
              syncthing-id = "EPIB45M-EYSLN3M-T4NGOGN-Y7LAAR5-PEZHHL2-IOEX55W-OUCLTAI-EEEXEAD";
              syncthing-folders = [ "notes" "house-notes" ];
            };
          };
          syncthing-server = "elphelt";

          github-name = "tbreslein";
          work-gitlab-name = "Tommy Breslein";
          email = "tommy.breslein@protonmail.com";
          work-email = "tommy.breslein@pailot.com";
          monofont = "Commit Mono Nerd Font";
          colors = rec {
            primary = {
              background = "1d2021";
              foreground = "d4be98";
              accent = "e78a4e";
              error = normal.red;
              border = primary.accent;
            };
            normal = {
              black = "32302f";
              red = "ea6962";
              green = "a9b665";
              yellow = "d8a657";
              blue = "7daea3";
              magenta = "d3869b";
              cyan = "89b482";
              white = "d4be98";
            };
            bright = normal;
          };
        };

      mk-args = system: hostname:
        let
          pkgs-stable = import nixpkgs-stable { inherit system; };
          user-conf = mk-user-conf pkgs-stable.lib system hostname;
        in
        { inherit inputs pkgs-stable user-conf; };

      mk-system = version: system: hostname: extraModules:
        let
          args = mk-args system hostname;

          sys-func =
            if args.user-conf.is-darwin
            then nix-darwin.lib.darwinSystem
            else if version == "stable"
            then nixpkgs-stable.lib.nixosSystem
            else nixpkgs-unstable.lib.nixosSystem;

          sys-module =
            if args.user-conf.is-linux
            then ./modules/nixos
            else ./modules/darwin;

          hm-module =
            if args.user-conf.is-darwin
            then home-manager-unstable.darwinModules.home-manager
            else if version == "stable"
            then home-manager-stable.nixosModules.home-manager
            else home-manager-unstable.nixosModules.home-manager;
        in
        {
          "${hostname}" = sys-func {
            inherit system;
            specialArgs = args;
            modules = [
              ./hosts/${hostname}
              sys-module
              hm-module
            ] ++ extraModules;
          };
        };
    in
    {
      nixosConfigurations =
        (mk-system "unstable" "x86_64-linux" "sol" [ chaotic.nixosModules.default ])
        // (mk-system "unstable" "x86_64-linux" "ky" [ chaotic.nixosModules.default ])
        // (mk-system "stable" "aarch64-linux" "elphelt" [ ]);

      darwinConfigurations =
        (mk-system "unstable" "aarch64-darwin" "answer" [
          nix-homebrew.darwinModules.nix-homebrew
          {
            nix-homebrew = {
              enable = true;
              enableRosetta = true;
              user = "${username}";
              taps = {
                "homebrew/homebrew-core" = homebrew-core;
                "homebrew/homebrew-cask" = homebrew-cask;
                "homebrew/homebrew-bundle" = homebrew-bundle;
              };
            };
          }
        ]);
    };
}
