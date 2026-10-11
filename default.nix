# This file describes your repository contents.
# It should return a set of nix derivations
# and optionally the special attributes `lib`, `modules` and `overlays`.
# It should NOT import <nixpkgs> directly. Instead, you should take pkgs as an argument.

# Note: this is a legacy NUR entrypoint (consumed via `nix-env -f .` and
# `ci.nix`). There is intentionally no `flake.nix`: CI is the only
# consumer of this repo, and real downstream users build the kernel via
# `mobile-nixos` directly. We pin the upstream source here via
# `builtins.fetchGit` (an impure builtin that realizes the path at
# eval time, so `--option restrict-eval true` in the CI check step
# does not need a separate prefetch step).

{
  pkgs ? import <nixpkgs> { },
}:

let
  # Pinned upstream: branch `chromebook-ciri-7.3` -> commit `d45d3f9...`.
  # `builtins.fetchGit` is an impure builtin; under restrict-eval the
  # `git+https://github.com` URI must be in `--allowed-uris`.
  src = builtins.fetchGit {
    url = "https://github.com/FZDSLR/mobile-nixos.git";
    rev = "d45d3f9c84aa1ffccef171502eeffa7f6e922128";
  };
  mobileNixosOverlay = import "${src}/overlay/overlay.nix";
  # Standalone stub for `systemBuild-structuredConfig`. The NixOS module
  # `mobile-nixos/modules/kernel-config.nix` normally injects this via
  # `nixpkgs.overlays`; outside a full NixOS evaluation we return an
  # empty config, since the actual kernel config comes from
  # `./config.aarch64` in the upstream package.
  structuredConfigOverlay = (_final: _super: {
    systemBuild-structuredConfig = _version: { };
  });
in
rec {
  # The `lib`, `modules`, and `overlays` names are special
  lib = import ./lib { inherit pkgs; }; # functions
  modules = import ./modules; # NixOS modules
  overlays = import ./overlays; # nixpkgs overlays

  niri-patched = import ./pkgs/niri-patched { inherit pkgs; };
  mesa-41072 = import ./pkgs/mesa-41072 { inherit pkgs; };

  libva-v4l2_request-sofus13 = pkgs.callPackage ./pkgs/libva-v4l2_request-sofus13 { };

  # Lenovo Chromebook Duet 11 (Ciri) stage-1 kernel.
  # Built via mobile-nixos's `kernel-builder` (resolved by the overlay).
  # The actual `default.nix` (with version, src, patches, config) is
  # imported from the locked mobile-nixos source tree.
  #
  # `ciriKernel` is marked `meta.broken` on non-aarch64 hosts (see
  # `pkgs/ciri-kernel/default.nix`), so `ci.nix`'s `isBuildable` skips
  # it on x86_64 runners and only builds it natively on aarch64.
  ciriKernel =
    (pkgs.appendOverlays [
      mobileNixosOverlay
      structuredConfigOverlay
    ]).callPackage ./pkgs/ciri-kernel
      { inherit src; };
}
