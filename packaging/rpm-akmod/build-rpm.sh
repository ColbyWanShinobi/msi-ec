#!/usr/bin/env bash
# Build an installable akmod RPM.  Run this directly on Fedora, or use
# build-rpm-container.sh on Silverblue/Kinoite to keep build dependencies off
# the immutable host.
set -euo pipefail

readonly PROJECT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
readonly RPM_ROOT="${RPM_TOPDIR:-$PROJECT_DIR/dist/rpmbuild}"

if ! command -v rpmbuild >/dev/null; then
    cat >&2 <<'EOF'
rpmbuild is not installed.

Fedora Workstation:
  sudo dnf install rpm-build akmods kernel-devel kmodtool gcc make elfutils-libelf-devel

Fedora Silverblue/Kinoite (recommended; does not layer build tools):
  make rpm-container
EOF
    exit 1
fi

make -C "$PROJECT_DIR/packaging/rpm-akmod" RPM_ROOT="$RPM_ROOT" rpm

shopt -s nullglob
rpms=("$RPM_ROOT"/RPMS/*/*.rpm)
if ((${#rpms[@]} == 0)); then
    echo "RPM build completed but no RPM was found below $RPM_ROOT/RPMS" >&2
    exit 1
fi

akmod_rpms=("$RPM_ROOT"/RPMS/*/akmod-msi-ec-*.rpm)
common_rpms=("$RPM_ROOT"/RPMS/*/msi-ec-kmod-common-*.rpm)
if ((${#akmod_rpms[@]} == 0 || ${#common_rpms[@]} == 0)); then
    echo 'RPM build completed without the akmod and common RPMs required for installation.' >&2
    exit 1
fi

echo
echo 'RPM build complete:'
printf '  %s\n' "${rpms[@]}"
echo
echo 'Install on Fedora Silverblue/Kinoite:'
printf '  sudo rpm-ostree install %q %q\n' "${akmod_rpms[0]}" "${common_rpms[0]}"
echo '  systemctl reboot'
