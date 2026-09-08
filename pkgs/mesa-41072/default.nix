{
  pkgs,
}:

if pkgs.stdenv.hostPlatform.isAarch64 then
  pkgs.mesa.overrideAttrs (oldAttrs: {
    patches = (oldAttrs.patches or [ ]) ++ [
      ./41072.patch
    ];
  })
else
  pkgs.mesa
