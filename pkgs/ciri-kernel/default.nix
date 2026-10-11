# Lenovo Chromebook Duet 11 (Lenovo Ciri / MT8188 Geralt variant) kernel.
#
# This is the stage-1 kernel for `mobile.system.depthcharge` devices in
# Mobile NixOS. Building it once caches the heavy closure (gcc/binutils/
# openssl/gmp/mpfr/libmpc/dtc + ~250 MB of kernel source + 9 patches)
# so downstream `kpart`, initrd, and disk-image builds hit Cachix.
#
# Strategy:
#   - `src` is the path to the mobile-nixos source tree, pinned to the
#     chromebook-ciri-7.3 commit. The legacy `default.nix` fetches it
#     via `builtins.fetchGit`; a flake caller would pass it as a
#     `mobile-nixos` input. Kept here as a callPackage argument so
#     `src` has a single source of truth.
#   - The upstream `devices/lenovo-ciri/kernel/default.nix` is `import`ed
#     and called directly. Its `./<sha>.patch` and `./config.aarch64`
#     references resolve against the source tree's directory, so no
#     per-file copying is needed.
#   - `mobile-nixos` (the set with `.kernel-builder`, `.stage-1`, etc.)
#     is resolved by callPackage from the mobile-nixos overlay applied
#     in `default.nix`.
#
# Cross-compilation: not supported here. The kernel config is aarch64-only,
# and the mobile-nixos kernel builder uses `stdenv.hostPlatform` directly.
# `ci.nix` skips this on x86_64 because of `meta.broken`.

{
  # Set provided by mobile-nixos's overlay.
  mobile-nixos,

  # Path to the mobile-nixos source tree (fetched via builtins.fetchGit
  # in `default.nix`, or passed in by a flake caller).
  src,

  # Resolved by callPackage from pkgs (used by the imported default.nix).
  fetchgit,
  fetchurl,
  python3,

  # For meta.broken below.
  stdenv,
  lib,
}:

let
  kernel = import "${src}/devices/lenovo-ciri/kernel/default.nix" {
    inherit mobile-nixos fetchgit fetchurl python3;
  };
in
kernel.overrideAttrs (old: {
  meta = (old.meta or { }) // {
    description = "Linux ${old.version or "7.3.0-rc4"} for Lenovo Chromebook Duet 11 (Ciri / MT8188 Geralt) built via mobile-nixos.kernel-builder";
    homepage = "https://github.com/FZDSLR/mobile-nixos/tree/chromebook-ciri-7.3/devices/lenovo-ciri/kernel";
    license = lib.licenses.gpl2Only;
    platforms = [ "aarch64-linux" ];
    # The kernel config is aarch64-only; cross-compilation isn't wired
    # here, so flag the package broken on non-aarch64 hosts. `ci.nix`
    # will then skip it (x86_64 runner), and only the aarch64 runner
    # builds it natively.
    broken = !(stdenv.hostPlatform.isAarch64 or false);
  };
})
