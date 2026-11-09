{
  lib,
  rustPlatform,
  fetchFromGitHub,
  cmake,
  pkg-config,
  makeWrapper,
  nix-update-script,

  alsa-lib,
  chafa,
  dbus,
  glib,
  openssl,
  pipewire,
}:

rustPlatform.buildRustPackage (finalAttrs: {
  pname = "cnmplayer";
  version = "0.7.3";

  src = fetchFromGitHub {
    owner = "professor-lee";
    repo = "CNMPlayer";
    tag = "v${finalAttrs.version}";
    hash = "sha256-MqhBAA68frV9oETGSHk/lt0+ouDaoRk/CuaysdhtxcY=";
  };

  # When `cargoLock` is set, buildRustPackage takes the `importCargoLock`
  # branch and `cargoHash` is never read. Reproducibility in this branch is
  # provided by `src.hash` (pins Cargo.lock inside), `outputHashes` for git
  # deps, and per-crate `checksum` entries inside Cargo.lock for crates.io.
  cargoLock = {
    lockFile = ./Cargo.lock;
  };

  nativeBuildInputs = [
    cmake
    pkg-config
    makeWrapper
    # bindgen (via pipewire-sys / alsa-sys) needs libclang.
    rustPlatform.bindgenHook
  ];

  buildInputs = [
    alsa-lib
    chafa
    dbus
    glib
    openssl
    pipewire
  ];

  # ratatui-image with feature `chafa-dyn` dynamically loads libchafa.
  postInstall = ''
    wrapProgram $out/bin/cnmplayer \
      --prefix LD_LIBRARY_PATH : "${lib.makeLibraryPath [ chafa ]}"
  '';

  passthru.updateScript = nix-update-script { attrPath = "cnmplayer"; };

  meta = {
    description = "A Rust TUI client for NetEase Cloud Music, with an embedded fullscreen playback page";
    longDescription = ''
      CNMPlayer (Customized NetEase Music Player) is a NetEase Cloud Music
      client that runs in the terminal. A single process carries two UIs: a
      host UI for browsing / search / playlists and a fullscreen playback
      page with cover, lyrics, EQ and visualizers (bars / oscilloscope /
      vector). Playback uses rodio + symphonia (mp3 / flac) over PipeWire.

      Linux media control (MPRIS, player name `cnmplayer`) is included.
      A Nerd Font is required for the playback and navigation icons.
    '';
    homepage = "https://github.com/professor-lee/CNMPlayer";
    license = lib.licenses.agpl3Only;
    mainProgram = "cnmplayer";
    platforms = [ "x86_64-linux" "aarch64-linux" ];
  };
})
