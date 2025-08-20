#!/bin/bash
set -e

echo "Setting up network resume after suspend..."

# Create systemd sleep hook script
echo "Creating network resume hook..."
sudo tee /usr/lib/systemd/system-sleep/network-resume >/dev/null <<'EOF'
#!/bin/bash
case $1 in
    post)
        # Reset network interface after resume
        ip link set eno1 down
        sleep 1
        ip link set eno1 up
        ;;
esac
EOF

# Make the script executable
sudo chmod +x /usr/lib/systemd/system-sleep/network-resume

echo "✓ Network resume hook installed"
echo ""
echo "This will automatically reset the eno1 network interface after each resume from suspend"
echo "to prevent 'network unreachable' issues."