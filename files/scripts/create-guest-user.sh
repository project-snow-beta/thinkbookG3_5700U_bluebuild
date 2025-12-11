#!/usr/bin/env bash
# create-guest-user.sh
# Creates a passwordless guest account for shared/kiosk use
# Place in: files/scripts/create-guest-user.sh

set -euo pipefail

echo "Creating guest user account..."

# Create guest user with no password
# -m: create home directory
# -s: set shell to bash
# -c: comment/full name
useradd -m -s /bin/bash -c "Guest Account" guest || true

# Remove any password requirement (passwordless login)
passwd -d guest

# Allow autologin for guest (optional - uncomment if desired)
# This would need GDM/SDDM configuration as well

# Create basic home directory structure
mkdir -p /home/guest/{Desktop,Documents,Downloads}
chown -R guest:guest /home/guest

# Set restrictive permissions on guest home
chmod 700 /home/guest

echo "Guest user created successfully (passwordless)"
echo "NOTE: For automatic first-time setup prompt, configure AccountsService or SDDM"
