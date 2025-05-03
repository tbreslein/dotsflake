.PHONY: all upgrade update sync

all: sync

upgrade:
	nix run .# -- upgrade

update:
	nix run .# -- update

sync:
	nix run .# -- sync
