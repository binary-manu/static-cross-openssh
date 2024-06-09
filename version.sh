set -exo pipefail

list_github_tags() {
  git ls-remote --tags --refs "$1" | grep -o 'refs/tags/.*' | cut -d/ -f3-
}

list_bootlin_versions() {
  local arch
  arch="$1"
  curl -sL "https://toolchains.bootlin.com/downloads/releases/toolchains/$arch/tarballs/" |
    sed -En 's/.*href="'"$arch"'--musl--stable-([^"]+).tar.bz2".*/\1/p'
}

sort_versions() {
  sed 'h; s/[+-]/./g; s/.p\([[:digit:]]\)/.z\1/; s/$/.z/; G; s/\n/ /' |
    LC_ALL=C sort -t. -k 1,1 -k 2,2n -k 3,3n -k 4,4n -k 5,5n | awk '{print $2}'
}
