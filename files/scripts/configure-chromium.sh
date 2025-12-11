#!/usr/bin/env bash
# configure-chromium.sh
# Sets Chromium as default browser and pre-installs privacy extensions
# Place in: files/scripts/configure-chromium.sh

set -euo pipefail

echo "Configuring Chromium with privacy extensions..."

# ============================================
# Chrome/Chromium Extension IDs
# ============================================
# uBlock Origin: cjpalhdlnbpafiamejdnhcphjbkeiagm
# Privacy Badger: pkehgijcmpdhfbdbbnkijodmdjhbjlgp

# ============================================
# Chromium Flatpak Policy Directory
# For system-wide Flatpak Chromium installations
# ============================================

CHROMIUM_POLICY_DIR="/etc/chromium/policies/managed"
CHROMIUM_POLICY_DIR_ALT="/var/lib/flatpak/app/org.chromium.Chromium/current/active/files/etc/chromium/policies/managed"

# Create policy directories
mkdir -p "${CHROMIUM_POLICY_DIR}"
mkdir -p /etc/chromium/policies/recommended

# ============================================
# Extension Installation Policy
# Force-installs extensions from Chrome Web Store
# ============================================

cat > "${CHROMIUM_POLICY_DIR}/extensions.json" << 'EOF'
{
  "ExtensionInstallForcelist": [
    "cjpalhdlnbpafiamejdnhcphjbkeiagm;https://clients2.google.com/service/update2/crx",
    "pkehgijcmpdhfbdbbnkijodmdjhbjlgp;https://clients2.google.com/service/update2/crx"
  ],
  "ExtensionInstallAllowlist": [
    "cjpalhdlnbpafiamejdnhcphjbkeiagm",
    "pkehgijcmpdhfbdbbnkijodmdjhbjlgp"
  ]
}
EOF

echo "Extension policy created: uBlock Origin + Privacy Badger will auto-install"

# ============================================
# Privacy-Focused Default Settings
# ============================================

cat > "${CHROMIUM_POLICY_DIR}/privacy.json" << 'EOF'
{
  "BlockThirdPartyCookies": true,
  "DefaultSearchProviderEnabled": true,
  "DefaultSearchProviderName": "DuckDuckGo",
  "DefaultSearchProviderSearchURL": "https://duckduckgo.com/?q={searchTerms}",
  "DefaultSearchProviderSuggestURL": "https://duckduckgo.com/ac/?q={searchTerms}&type=list",
  "MetricsReportingEnabled": false,
  "SafeBrowsingProtectionLevel": 1,
  "UrlKeyedAnonymizedDataCollectionEnabled": false,
  "SpellcheckEnabled": true,
  "SpellcheckLanguage": ["en-US", "de-DE"]
}
EOF

echo "Privacy defaults configured"

# ============================================
# Set Chromium as Default Browser (xdg-settings)
# Applied at first boot via systemd user service
# ============================================

# Create a first-boot script to set defaults
mkdir -p /etc/profile.d

cat > /etc/profile.d/set-chromium-default.sh << 'EOF'
#!/bin/bash
# Set Chromium Flatpak as default browser on first login
# This runs once per user

MARKER="$HOME/.config/.chromium-default-set"

if [ ! -f "$MARKER" ]; then
    # Wait for Flatpak to be available
    if flatpak info org.chromium.Chromium &>/dev/null; then
        xdg-settings set default-web-browser org.chromium.Chromium.desktop 2>/dev/null || true
        xdg-mime default org.chromium.Chromium.desktop x-scheme-handler/http 2>/dev/null || true
        xdg-mime default org.chromium.Chromium.desktop x-scheme-handler/https 2>/dev/null || true
        xdg-mime default org.chromium.Chromium.desktop text/html 2>/dev/null || true
        mkdir -p "$(dirname "$MARKER")"
        touch "$MARKER"
    fi
fi
EOF

chmod +x /etc/profile.d/set-chromium-default.sh

# ============================================
# Symlink policy for Flatpak Chromium
# Flatpak reads from different location
# ============================================

# Create the Flatpak override to allow policy reading
mkdir -p /etc/flatpak/overrides
cat > /etc/flatpak/overrides/org.chromium.Chromium << 'EOF'
[Context]
filesystems=/etc/chromium/policies:ro
EOF

echo "Chromium configuration complete"
echo "Extensions will install on first Chromium launch after Flatpak install"
