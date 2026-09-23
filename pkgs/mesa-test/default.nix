{
  pkgs,
}:

let
  # Apply the test patches only on mesa in [26.2, 26.2.3):
  #   - < 26.2   : panfrost source diverges; keep pkgs.mesa as-is (stable).
  #   - >= 26.2.3: upstream has moved on; keep pkgs.mesa as-is.
  # Within the active window aarch64-linux gets every patch.
  applyPatches =
    pkgs.stdenv.hostPlatform.isAarch64
    && pkgs.lib.versionAtLeast (pkgs.mesa.version or "0") "26.2";
in
if applyPatches then
  pkgs.mesa.overrideAttrs (oldAttrs: {
    patches = (oldAttrs.patches or [ ]) ++ [
      # ./41072.patch -- conflicts with 41123-edited (both touch gpu_access in pan_bo.c etc.)
      #       ./43893.patch
      ./41123-edited.patch
      ./44611.patch
      ./44053.patch
      ./42216.patch
      ./44495.patch
    ];
  })
else
  pkgs.mesa
