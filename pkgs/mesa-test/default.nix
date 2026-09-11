{
  pkgs,
}:

if pkgs.stdenv.hostPlatform.isAarch64 then
  pkgs.mesa.overrideAttrs (oldAttrs: {
    patches = (oldAttrs.patches or [ ]) ++ [
      ./41072.patch
      ./43893.patch
      # ./44053.patch
      ./44363-edited.patch
    ];
  })
else
  pkgs.mesa
