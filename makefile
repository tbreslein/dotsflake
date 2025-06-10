.PHONY: all upgrade update sync

all: upgrade

upgrade:
	sudo nixos-rebuild switch --flake ~/dotsflake

update:
	cd ~/dotsflake && nix flake update

sync: update upgrade
