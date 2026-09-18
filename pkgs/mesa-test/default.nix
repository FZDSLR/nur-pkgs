{
  pkgs,
}:

let
  # Only apply the test patches on mesa >= 26.2 (the codebase these
  # patches were tested against). Older stable branches (e.g. 26.1.7
  # on nixos-stable) must keep building `pkgs.mesa` as-is, since the
  # panfrost source diverges across 26.1 -> 26.2.
  applyPatches =
    pkgs.stdenv.hostPlatform.isAarch64
    && pkgs.lib.versionAtLeast (pkgs.mesa.version or "0") "26.2";
in
if applyPatches then
  pkgs.mesa.overrideAttrs (oldAttrs: {
    patches = (oldAttrs.patches or [ ]) ++ [
      # ./41072.patch -- conflicts with 41123-edited (both touch gpu_access in pan_bo.c etc.)
      ./43893.patch
      ./41123-edited.patch
      ./44053.patch
      ./42216.patch
      ./44495.patch
    ];
  })
else
  pkgs.mesa