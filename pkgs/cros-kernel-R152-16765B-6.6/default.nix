{
  pkgs,
}:

# ChromeOS kernel (branch R152-16765B-6.6)
# 源仓库：https://chromium.googlesource.com/chromiumos/third_party/kernel
#
# rev 0e760c82fdf40d3162b8ddd15cb60a03f8b54c49 对应特定 board/kernel 的快照。
#
# 当前 sha256 为 lib.fakeSha256 占位：本地无法访问 googlesource 校验，
# 交由 CI（GitHub Actions 出网可达）在首次构建时打印真实 hash 后回填。
# CI 配置见 .github/workflows/build.yml，缓存产物推送到 fzdslr-nur.cachix.org。
pkgs.fetchgit {
  url = "https://chromium.googlesource.com/chromiumos/third_party/kernel.git";
  rev = "0e760c82fdf40d3162b8ddd15cb60a03f8b54c49";
  sha256 = pkgs.lib.fakeSha256;
}