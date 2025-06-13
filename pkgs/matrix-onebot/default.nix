{ lib
, rustPlatform
, fetchFromGitHub
, fetchurl
}:

rustPlatform.buildRustPackage rec {
  pname = "matrix-onebot";
  version = "v0.2.0-alpha.2";

  src = fetchFromGitHub {
    owner = "d14n-ob";
    repo = pname;
    rev = "b37fa48eea66e93b906ac7e865684fec5434079f";
    hash = "sha256-yllPyL44ZoQWrXrdiFFvrQzMoJ5mp3z4pUIvLkcsaBE=";
  };

  cargoHash = "sha256-09XutDTaR03hNGHSw6D1b+4yxSgMWnX9JBFtFmfYuvw=";

  patches = [
    (fetchurl {
      url = "https://github.com/FZDSLR/matrix-onebot/commit/0514986c04df763a170baabb826097e8067e4e6d.patch";
      sha256 = "0lshvkc8d9clr8l4acvmar4nkvr5cf535b8przm55357dk9y4dnx";
    })
  ];

  meta = with lib; {
    description = "Matrix bot implementation following the onebot specification";
    homepage = "https://github.com/d14n-ob/matrix-onebot";
    license = licenses.mpl20;
  };
}
