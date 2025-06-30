# dotsflake

my dots in a nix flake

## structure

the hosts default.nix files includes both regular nixos/darwin as well as
home manager config.
kain is the only machine with gaming, so I skip having a dedicated gaming role.

```
hosts
  | sol/
    \ hardware-configuration.nix
    \ configuration.nix
    \ home.nix
  | ky/
    \ hardware-configuration.nix
    \ configuration.nix
    \ home.nix
  | vorador/default.nix
    \ hardware-configuration.nix
  | mbp/default.nix

modules
  | nixos/
  | home/
  | darwin/
  | default.nix
```

## TODO

continue home manager settings at programs.c

- configure bash and make sure you get all the necessary integrations
- desktop/linux:
  - screenshots
  - try out niri
- desktop/darwin:
  - brew
