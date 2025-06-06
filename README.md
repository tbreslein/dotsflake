# dotsflake

my dots in a nix flake

## structure

the hosts default.nix files includes both regular nixos/darwin as well as
home manager config.
kain is the only machine with gaming, so I skip having a dedicated gaming role.

```
hosts
  \ raziel/default.nix
    \ hardware-configuration.nix
  | kain/default.nix
    \ hardware-configuration.nix
  | vorador/default.nix
    \ hardware-configuration.nix
  | mbp/default.nix

modules
  \ common/default.nix
  | shell/default.nix
  | code/default.nix
  | linux/default.nix
  | darwin/default.nxi
  | desktop/default.nix
    \ linux.nix
    \ darwin.nix
```

## TODO

continue home manager settings at programs.c

- configure bash and make sure you get all the necessary integrations
- desktop/linux:
  - hyprland
  - clipboard
  - screenshots
  - waybar
  - wallpaper
  - mako
  - wlsunset
- desktop/darwin:
  - brew
