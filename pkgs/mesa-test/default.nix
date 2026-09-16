{
  pkgs,
}:

if pkgs.stdenv.hostPlatform.isAarch64 then
  pkgs.mesa.overrideAttrs (oldAttrs: {
    patches = (oldAttrs.patches or [ ]) ++ [
      ./41072.patch
      # Drain in-flight GPU work before marking BOs evictable; closes the
      # BO-cache -> kernel shrinker race that triggers DATA_INVALID_FAULT
      # on Mali-G57 under memory pressure. Depends on the bo_access_lock
      # introduced by 41072.
      # ./panfrost-dontneed-drain.patch
      ./43893.patch
      ./44053.patch
      ./42216.patch
      # ./44363-edited.patch
    ];
  })
else
  pkgs.mesa
