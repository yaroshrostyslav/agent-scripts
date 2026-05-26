#!/bin/bash

# Description: SSH key-based auth + SFTP setup for Raspberry Pi 5
# Run as: bash ssh-setup.sh

set -euo pipefail

KEY_NAME="id_ed25519_pi_$(date +%s)"
KEY_PATH="$HOME/.ssh/$KEY_NAME"
SSH_DROPIN=/etc/ssh/sshd_config.d/99-hardening.conf

echo "=== SSH/SFTP Setup ==="
echo ""

# Step 1: Generate SSH key
echo "[1] Generating SSH key at $KEY_PATH..."
mkdir -p "$HOME/.ssh"
chmod 700 "$HOME/.ssh"
ssh-keygen -t ed25519 \
    -f "$KEY_PATH" \
    -N "" \
    -C "$USER@$(hostname)-$(date +%Y%m%d)"
echo "Done."
echo ""

# Step 2: Append public key to authorized_keys
echo "[2] Adding public key to authorized_keys..."
cat "$KEY_PATH.pub" >> "$HOME/.ssh/authorized_keys"
chmod 600 "$HOME/.ssh/authorized_keys"
echo "Done."
echo ""

# Step 3: Harden SSH config
echo "[3] Hardening SSH config..."
sudo tee "$SSH_DROPIN" > /dev/null <<EOF
# SSH hardening — applied by ssh-setup.sh
PasswordAuthentication no
ChallengeResponseAuthentication no
KbdInteractiveAuthentication no
PubkeyAuthentication yes
PermitRootLogin no
PermitEmptyPasswords no
X11Forwarding no
MaxAuthTries 3
ClientAliveInterval 300
ClientAliveCountMax 2
EOF

sudo sshd -t
sudo systemctl reload ssh
echo "Done."
echo ""

# Step 4: Output the key
echo "=== Setup complete! ==="
echo ""
echo "!!! PRIVATE KEY — save it to your client, then delete from Pi !!!"
echo ""
cat "$KEY_PATH"
echo ""
echo "PUBLIC KEY:"
cat "$KEY_PATH.pub"
echo ""
echo "Connect with: ssh -i <key-file> $USER@<pi-ip>"
echo "SFTP with:    sftp -i <key-file> $USER@<pi-ip>"
echo ""

read -rp "Delete private key from Pi? [y/N]: " REPLY
if [[ "$REPLY" =~ ^[Yy]$ ]]; then
    rm "$KEY_PATH"
    echo "Private key deleted from Pi."
else
    echo "Private key kept at: $KEY_PATH"
    echo "Don't forget to delete it manually after saving to your client."
fi