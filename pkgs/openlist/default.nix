{
  lib,
  buildGoModule,
  fetchFromGitHub,
  fetchzip,
  fuse,
  stdenv,
  installShellFiles,
  versionCheckHook,
  callPackage,
}:
buildGoModule rec {
  pname = "OpenList";
  version = "4.0.4";
  webVersion = "4.0.4";

  src = fetchFromGitHub {
    owner = "OpenListTeam";
    repo = "OpenList";
    tag = "v${version}";
    hash = "sha256-/7sTvFwv+H0JpzF+7kLzIE3o0juzLWt2LHcH0QeaiAk=";
    # populate values that require us to use git. By doing this in postFetch we
    # can delete .git afterwards and maintain better reproducibility of the src.
    leaveDotGit = true;
    postFetch = ''
      cd "$out"
      git rev-parse HEAD > $out/COMMIT
      # '0000-00-00T00:00:00Z'
      date -u -d "@$(git log -1 --pretty=%ct)" "+%Y-%m-%dT%H:%M:%SZ" > $out/SOURCE_DATE_EPOCH
      find "$out" -name .git -print0 | xargs -0 rm -rf
    '';
  };
  web = fetchzip {
    url = "https://github.com/OpenListTeam/OpenList-Frontend/releases/download/v${webVersion}/openlist-frontend-dist-v${webVersion}.tar.gz";
    hash = "sha256-6QtGGQVH4kXRfbAkhZOLnurVNfZeBhJrG/42c11UGqY=";
    stripRoot=false;
  };

  proxyVendor = true;
  vendorHash = "sha256-t+vd+D+c6N7+49w0nG6hmx1Cyk8vTGTj9CKcuyTL6tU=";

  buildInputs = [ fuse ];

  tags = [ "jsoniter" ];

  ldflags = [
    "-s"
    "-w"
    "-X \"github.com/OpenListTeam/OpenList/internal/conf.GitAuthor=Xhofe <i@nn.ci>\""
    "-X github.com/OpenListTeam/OpenList/internal/conf.Version=${version}"
    "-X github.com/OpenListTeam/OpenList/internal/conf.WebVersion=${webVersion}"
  ];

  preConfigure = ''
    rm -rf public/dist
    cp -r ${web} public/dist
  '';

  preBuild = ''
    ldflags+=" -X \"github.com/OpenListTeam/OpenList/internal/conf.GoVersion=$(go version | sed 's/go version //')\""
    ldflags+=" -X \"github.com/OpenListTeam/OpenList/internal/conf.BuiltAt=$(cat SOURCE_DATE_EPOCH)\""
    ldflags+=" -X github.com/OpenListTeam/OpenList/internal/conf.GitCommit=$(cat COMMIT)"
  '';

  checkFlags =
    let
      # Skip tests that require network access
      skippedTests = [
        "TestHTTPAll"
        "TestWebsocketAll"
        "TestWebsocketCaller"
        "TestDownloadOrder"
      ];
    in
    [ "-skip=^${builtins.concatStringsSep "$|^" skippedTests}$" ];

  nativeBuildInputs = [ installShellFiles ];

  postInstall = lib.optionalString (stdenv.buildPlatform.canExecute stdenv.hostPlatform) ''
    installShellCompletion --cmd OpenList \
      --bash <($out/bin/OpenList completion bash) \
      --fish <($out/bin/OpenList completion fish) \
      --zsh <($out/bin/OpenList completion zsh)
  '';

  doInstallCheck = true;

  versionCheckProgramArg = "version";

  nativeInstallCheckInputs = [
    versionCheckHook
  ];

  meta = {
    description = "File list/WebDAV program that supports multiple storages";
    homepage = "https://github.com/OpenListTeam/OpenList";
    changelog = "https://github.com/OpenListTeam/OpenList/releases/tag/v${version}";
    license = with lib.licenses; [
      agpl3Only
      mit # OpenList-Frontend
    ];
    sourceProvenance = with lib.sourceTypes; [
      fromSource
      binaryBytecode #OpenList-Frontend
    ];
    mainProgram = "OpenList";
  };
}
