# This file describes your repository contents.
# It should return a set of nix derivations
# and optionally the special attributes `lib`, `modules` and `overlays`.
# It should NOT import <nixpkgs>. Instead, you should take pkgs as an argument.
# Having pkgs default to <nixpkgs> is fine though, and it lets you use short
# commands such as:
#     nix-build -A mypackage

{
  pkgs ? import <nixpkgs> { },
}:

rec {
  # The `lib`, `modules`, and `overlays` names are special
  lib = import ./lib { inherit pkgs; }; # functions
  modules = import ./modules; # NixOS modules
  overlays = import ./overlays; # nixpkgs overlays

  niri-patched = import ./pkgs/niri-patched { inherit pkgs; };
  mesa-41072 = import ./pkgs/mesa-41072 { inherit pkgs; };
  cros-kernel-R152-16765B-6.6 = import ./pkgs/cros-kernel-R152-16765B-6.6 { inherit pkgs; };
}
