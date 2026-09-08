{
  pkgs,
}:

if pkgs.stdenv.hostPlatform.isAarch64 then
  pkgs.mesa.overrideAttrs (oldAttrs: {
    src = pkgs.fetchFromGitLab {
      domain = "gitlab.freedesktop.org";
      owner = "mesa";
      repo = "mesa";
      rev = "8fce8eee280f2592c653f7c541c65c6d6c97598c";
      sha256 = "1dngslbj9iq7ll5wryxil043hyghxay9rgla8nk2y2jpsa95rwlz";
    };
    version = "26.3.0-devel";
    patches = (oldAttrs.patches or [ ]) ++ [
      ./41123.patch
    ];
  })
else
  pkgs.mesa
