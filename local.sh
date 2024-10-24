#!/usr/bin/env bash
export NIX_PKGS_ALLOW_UNFREE=1
sudo -E \
  nixos-rebuild switch \
  --impure \
  --flake .# \
  --override-input base ~/MT/repos/talbergs/base/ \
  --override-input webtools ~/MT/repos/talbergs/system-web/ \
  --override-input dbtools ~/MT/repos/talbergs/system-db/ \
  --override-input editor ~/MT/repos/talbergs/editor/ \
  --override-input shell ~/MT/repos/talbergs/shell/
