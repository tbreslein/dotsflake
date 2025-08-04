{ config, lib, pkgs, hm, user-conf, ... }:
let
  cfg = config.my-system.code;
in
{
  imports = [
    ./neovim.nix
    ./emacs.nix
    ./zed.nix
  ];

  options.my-system.code.enable = lib.mkEnableOption "Enable code role";

  config = lib.mkIf cfg.enable {
    ${hm} = {
      home.packages = with pkgs; [
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

      editorconfig = {
        enable = true;
        settings = {
          "*" = {
            charset = "utf-8";
            indent_size = 4;
            indent_style = "space";
            max_line_width = 80;
            trim_trailing_whitespace = true;
          };
          "*.{nix,cabal,hs,lua}" = {
            indent_size = 2;
          };
          "*.{json,js,jsx,ts,tsx,cjs,mjs}" = {
            indent_size = 2;
          };
          "*.{yml,yaml,ml,mli,hl,md,mdx,html,astro}" = {
            indent_size = 2;
          };
          "CMakeLists.txt" = {
            indent_size = 2;
          };
          "{m,M}akefile" = {
            indent_style = "tab";
          };
        };
      };

      programs = {
        jq.enable = true;

        direnv = {
          enable = true;
          enableBashIntegration = true;
          nix-direnv.enable = true;
          silent = true;
        };

        lazygit.enable = true;
        tmux.extraConfig =
          /*
          tmux
          */
          ''
            bind-key C-g popup -E -w90% -h90% "lazygit"
          '';

        bash.profileExtra = /* bash */ ''
          [[ -f "${config.home.homeDirectory}/.cargo/env" ]] && \
            source "${config.home.homeDirectory}/.cargo/env"
        '';
      };
    };
  };
}
