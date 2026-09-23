{
  pkgs,
}:

# ChromeOS kernel (branch R152-16765B-6.6)
# 源仓库：https://chromium.googlesource.com/chromiumos/third_party/kernel
#
# rev 0e760c82fdf40d3162b8ddd15cb60a03f8b54c49 对应特定 board/kernel 的快照。
#
# sha256 来自 CI 首次构建失败时的报错，已回填。
# CI 配置见 .github/workflows/build.yml，缓存产物推送到 fzdslr-nur.cachix.org。
#
# 注意：pkgs.fetchgit 默认带 preferLocalBuild = true，会被 ci.nix 的
# isCacheable 过滤掉，导致 CI 不构建也不入 Cachix。overrideAttrs 把它
# 关掉，强制进 cacheOutputs。
(pkgs.fetchgit {
  url = "https://chromium.googlesource.com/chromiumos/third_party/kernel.git";
  rev = "0e760c82fdf40d3162b8ddd15cb60a03f8b54c49";
  sha256 = "sha256-vQ+ECbBkqn4UHUp9OCP7fMcl2ak6kqTW6v5ULZNePT4=";
}).overrideAttrs (_: { preferLocalBuild = false; })