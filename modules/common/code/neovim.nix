{ config, lib, pkgs, user-conf, ... }:
let
  cfg = config.my-system.code.neovim;
in
{
  options.my-system.code.neovim = {
    enable = lib.mkEnableOption "Enable neovim";
    nvim-config = lib.mkOption {
      type = lib.types.enum [ "minimal" "big" ];
      default = "minimal";
    };
  };

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
          eslint
          nixd
          statix
          nixpkgs-fmt
          tree-sitter
        ];
        file = {
          ".luacheckrc".text = ''
            globals = { "vim" }
          '';

          ".config/nvim".source = config.lib.file.mkOutOfStoreSymlink "${user-conf.dots-dir}/modules/common/code/${cfg.nvim-config}-nvim";
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
          package = pkgs.neovim-unwrapped;
          defaultEditor = true;
          plugins =
            if cfg.nvim-config == "big" then
              (with pkgs.vimPlugins; [
                # ui
                nvim-treesitter.withAllGrammars
                nvim-treesitter-context
                gruvbox-material

                # tooling
                conform-nvim
                nvim-lint

                # navigation
                plenary-nvim
                telescope-nvim
                telescope-zf-native-nvim

                # lsp
                blink-cmp
                friendly-snippets
                nvim-lspconfig

                # dap
                nvim-dap
                nvim-dap-view
                nvim-dap-go
                nvim-dap-python
              ]) else
              (with pkgs.vimPlugins; [
                nvim-treesitter.withAllGrammars
                nvim-treesitter-context
                mini-base16
                mini-files
                mini-pick
              ]);
          withNodeJs = false;
          withPython3 = false;
          withRuby = false;
        };
      };
    };
  };
}
