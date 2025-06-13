UNAME := $(shell uname -s)
ifeq ($(UNAME),Darwin)
	OS = macos
else ifeq ($(UNAME),Linux)
	OS = linux
else
	$(error OS not supported by this Makefile)
endif

ifeq ($(OS),macos)
	REBUILD_COMMAND = darwin-rebuild
else ifeq ($(OS),linux)
	REBUILD_COMMAND = nixos-rebuild
endif

.PHONY: all
all: upgrade

.PHONY: upgrade
upgrade:
	sudo $(REBUILD_COMMAND) switch --flake ~/dotsflake

.PHONY: update
update:
	cd ~/dotsflake && nix flake update

.PHONY: sync
sync: update upgrade
