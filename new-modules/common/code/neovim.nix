{ config, lib, pkgs, hm, user-conf, ... }:
let
  cfg = config.my-system.neovim;
in
{
  options.my-system.neovim = {
    enable = lib.mkEnableOption "Enable neovim";
    nvim-config = lib.mkOption {
      type = lib.types.enum [ "minimal" "big" ];
      default = "minimal";
    };
  };

  config = lib.mkIf cfg.enable {
    ${hm} = {
      home.shellAliases.v = "nvim";

      programs = {
        tmux.extraConfig =
          /*
          tmux
          */
          ''
            bind-key C-t popup -E -w90% -h90% "nvim ~/sync/notes/todos.md"
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
                gruvbox-material
              ]);
          withNodeJs = false;
          withPython3 = false;
          withRuby = false;
        };
      };
    };
  };
}
