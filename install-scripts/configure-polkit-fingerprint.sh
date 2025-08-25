#!/bin/bash
set -e

# Configure polkit PAM to use fingerprint OR password (not both)
echo "Configuring polkit fingerprint authentication..."

# Backup original if it exists and we haven't backed it up yet
if [[ -f /etc/pam.d/polkit-1 ]] && [[ ! -f /etc/pam.d/polkit-1.backup ]]; then
    sudo cp /etc/pam.d/polkit-1 /etc/pam.d/polkit-1.backup
fi

# Configure polkit-1 PAM to use sufficient (either/or) not required+optional (both)
sudo tee /etc/pam.d/polkit-1 > /dev/null << 'EOF'
auth      sufficient pam_unix.so nullok try_first_pass
auth      sufficient pam_fprintd.so
auth      required pam_deny.so

account   required pam_unix.so
password  required pam_unix.so
session   required pam_unix.so
EOF

echo "✓ Polkit fingerprint authentication configured"
echo "  Authentication will now accept either fingerprint OR password"