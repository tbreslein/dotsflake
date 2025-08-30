{ inputs, config, lib, pkgs, user-conf, ... }:
let
  cfg = config.my-system.code.neovim;
in
{
  options.my-system.code.neovim.enable = lib.mkEnableOption "Enable neovim";

  config = lib.mkIf cfg.enable {
    home-manager.users.${user-conf.name} = { config, ... }: {
      home = {
        shellAliases.v = "nvim";
        packages = with pkgs; [
          universal-ctags

          stylua
          luajitPackages.luacheck
          lua-language-server
          bash-language-server
          shellharden
          nodePackages.prettier
          statix
          nixpkgs-fmt
          tree-sitter
        ];
        file = {
          ".luacheckrc".text = ''
            globals = { "vim" }
          '';

          ".config/nvim/init.lua".source = config.lib.file.mkOutOfStoreSymlink "${user-conf.dots-dir}/modules/common/code/neovim.lua";
        };
      };

      programs = {
        tmux.extraConfig =
          /*
          tmux
          */
          ''
            bind-key C-t popup -E -w90% -h90% "nvim ${user-conf.sync-dir}/notes/todos.md"
          '';

        neovim = {
          enable = true;
          package = inputs.neovim-nightly-overlay.packages.${pkgs.system}.default;
          defaultEditor = true;
          withNodeJs = false;
          withPython3 = false;
          withRuby = false;
        };
      };
    };
  };
}
