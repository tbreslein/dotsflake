{ config
, lib
# , mk-syncthing-config
# , hostname
, ...
}:
let
  cfg = config.my-home.darwin;
in
{
  options.my-home.darwin.enable = lib.mkEnableOption "Enable my-home.darwin";

  config = lib.mkIf cfg.enable {
    home.shellAliases.mocostate = "tail -10 /tmp/mococlient.err.log";
    programs.bash.profileExtra = /* bash */ ''
      [[ -f "/opt/homebrew/bin/brew" ]] && \
        eval "$(/opt/homebrew/bin/brew shellenv)"
    '';
    # services.syncthing = mk-syncthing-config config lib hostname;
  };
}
