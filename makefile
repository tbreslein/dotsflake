all:
	if [[ $(shell uname -s) == "Linux" ]]; then sudo nixos-rebuild switch --flake .; else darwin-rebuild switch --flake .; fi
