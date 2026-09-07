{
  pkgs,
}:

pkgs.niri.overrideAttrs (oldAttrs: {
  src = pkgs.fetchFromGitHub {
    owner = "niri-wm";
    repo = "niri";
    rev = "6f1a2c5f0e8274223d4204b1f8d6f7f91538967e";
    sha256 = "sha256-QHyIMGSbCQW8d5qbOrMsm6gem10bO3Au2YLa3alJfHo=";
  };
  patches = (oldAttrs.patches or [ ]) ++ [
    # https://github.com/niri-wm/niri/pull/3771
    ./3771.diff
  ];
})