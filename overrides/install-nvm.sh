#!/bin/bash

# Install nvm and latest LTS Node.js
set -e

# Install nvm if not already installed
if [ ! -d "$HOME/.nvm" ]; then
    curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.7/install.sh | bash
fi

# Create a temporary script to install Node.js with nvm
cat > /tmp/install_node.sh << 'EOF'
#!/bin/bash
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"

# Install latest LTS Node.js
nvm install --lts
nvm use --lts
nvm alias default lts/*
EOF

# Execute the script in a new shell to ensure nvm is properly loaded
bash /tmp/install_node.sh

# Clean up
rm /tmp/install_node.sh

echo "Node.js installed. You may need to restart your shell or run 'source ~/.bashrc' to use node/npm."