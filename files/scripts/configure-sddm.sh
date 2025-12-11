#!/usr/bin/env bash
set -euo pipefail

mkdir -p /etc/sddm.conf.d

cat > /etc/sddm.conf.d/guest.conf << 'EOF'
[Users]
HideShells=
RememberLastUser=true
EOF