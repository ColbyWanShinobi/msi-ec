#!/usr/bin/env bash
# Build in Fedora's container image; this is the preferred path for
# Silverblue/Kinoite because it does not layer build dependencies onto the host.
set -euo pipefail

readonly PROJECT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
readonly IMAGE="${MSI_EC_BUILD_IMAGE:-fedora:latest}"

command -v podman >/dev/null || {
    echo 'podman is required for containerized RPM builds.' >&2
    exit 1
}

mkdir -p "$PROJECT_DIR/dist"
podman run --rm \
    --userns=keep-id \
    --user 0 \
    --security-opt label=disable \
    --volume "$PROJECT_DIR:/src:rw" \
    --workdir /src \
    "$IMAGE" \
    bash -lc 'dnf install -y -q rpm-build akmods kernel-devel kmodtool gcc make elfutils-libelf-devel tar gzip && ./packaging/rpm-akmod/build-rpm.sh'

shopt -s nullglob
rpms=("$PROJECT_DIR"/dist/rpmbuild/RPMS/*/*.rpm)
if ((${#rpms[@]} == 0)); then
    echo 'Container build completed but no host RPM artifact was found.' >&2
    exit 1
fi

akmod_rpms=("$PROJECT_DIR"/dist/rpmbuild/RPMS/*/akmod-msi-ec-*.rpm)
common_rpms=("$PROJECT_DIR"/dist/rpmbuild/RPMS/*/msi-ec-kmod-common-*.rpm)
if ((${#akmod_rpms[@]} == 0 || ${#common_rpms[@]} == 0)); then
    echo 'Container build completed without the akmod and common RPMs required for installation.' >&2
    exit 1
fi

echo
echo 'Host RPM artifact:'
printf '  %s\n' "${rpms[@]}"
echo 'Install it on Silverblue/Kinoite with:'
printf '  sudo rpm-ostree install %q %q\n' "${akmod_rpms[0]}" "${common_rpms[0]}"
echo '  systemctl reboot'
