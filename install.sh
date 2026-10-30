#!/usr/bin/env bash
# shellcheck disable=SC1091,SC2154
set -Eeuo pipefail

VERSION="6.0.1"
WORKDIR="$(mktemp -d)"
trap 'rm -rf "$WORKDIR"' EXIT

ANYDESK_URL="https://web.archive.org/web/20230419070452if_/https://download.anydesk.com/linux/deb/anydesk_6.0.1-1_amd64.deb"
GTK_URL="https://deb.debian.org/debian/pool/main/g/gtkglext/libgtkglext1_1.2.0-11_amd64.deb"
PANGO_URL="https://deb.debian.org/debian/pool/main/p/pangox-compat/libpangox-1.0-0_0.0.2-5.1_amd64.deb"

ANYDESK_SHA512="9ff2d5fe2d87e06f2860fc1759af3b1b10749feb3a97023905a314047e42e805028619f81a4d541cd3fd0ffab8bec71965e191a3d295d745f7738b150c53fc69"
GTK_SHA512="f6d33fc8e9d3efd3c7d7da24b5d0f965a4784a67d136a93b232b9eab049307b321aeab5cff6fc2c91d7d6e3cd7a2283f12d05e55e3722f8c5c87fe6c75199069"
PANGO_SHA512="27e9f8df702a07ff64a6f22dd58da4b0deda30317d25425ff0b966647e6126c498ebfb5ed9fe05346a9171ba6ae6026f89b53e7b2fe6d85e3745273189659282"

if [[ $EUID -eq 0 ]]; then
    echo "Run as a normal user, not root."
    exit 1
fi

source /etc/os-release

if [[ "$ID" != "debian" || "$(dpkg --print-architecture)" != "amd64" ]]; then
    echo "Only Debian AMD64 is supported."
    exit 1
fi

echo "==> Installing download tools"
sudo apt-get update
sudo apt-get install -y ca-certificates curl

cd "$WORKDIR"

download() {
    curl --fail --location --silent --show-error --retry 3 "$1" -o "$2"
}

echo "==> Downloading AnyDesk $VERSION"
download "$ANYDESK_URL" anydesk.deb

echo "$ANYDESK_SHA512  anydesk.deb" | sha512sum --check -

echo "==> Downloading compatibility libraries"
download "$GTK_URL" libgtkglext1.deb
download "$PANGO_URL" libpangox.deb

echo "==> Verifying compatibility libraries"
echo "$GTK_SHA512  libgtkglext1.deb" | sha512sum --check -
echo "$PANGO_SHA512  libpangox.deb" | sha512sum --check -

verify_deb() {
    local file="$1" package="$2" version="$3"

    [[ "$(dpkg-deb -f "$file" Package)" == "$package" ]] || {
        echo "Invalid package: $file"
        exit 1
    }

    [[ "$(dpkg-deb -f "$file" Version)" == "$version" ]] || {
        echo "Unexpected package version: $file"
        exit 1
    }

    [[ "$(dpkg-deb -f "$file" Architecture)" == "amd64" ]] || {
        echo "Wrong architecture: $file"
        exit 1
    }
}

verify_deb anydesk.deb anydesk 6.0.1
verify_deb libgtkglext1.deb libgtkglext1 1.2.0-11
verify_deb libpangox.deb libpangox-1.0-0 0.0.2-5.1

echo "==> Installing packages"
sudo apt-get install -y \
    ./libgtkglext1.deb \
    ./libpangox.deb \
    ./anydesk.deb

echo "==> Checking shared libraries"
if ldd /usr/bin/anydesk | grep -q "not found"; then
    ldd /usr/bin/anydesk | grep "not found"
    echo "Missing shared libraries."
    exit 1
fi

echo "==> Enabling AnyDesk"
sudo systemctl enable --now anydesk.service

echo
echo "AnyDesk $VERSION installed successfully."
echo "AnyDesk ID:"
anydesk --get-id || true

echo
systemctl status anydesk --no-pager || true
echo
echo "Configure unattended access through the AnyDesk GUI."
