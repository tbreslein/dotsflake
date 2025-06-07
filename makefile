.PHONY: all upgrade update sync

all: upgrade

upgrade:
	nix run .# -- upgrade

update:
	nix run .# -- update

sync:
	nix run .# -- sync
