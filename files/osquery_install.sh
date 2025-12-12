#!/bin/bash
set -e

export OSQUERY_KEY=1484120AC4E9F8A1A577AEEE97A80C63C9D8B80B

# Create keyrings directory if it doesn't exist
sudo mkdir -p /etc/apt/keyrings

# Download and add the GPG key using modern method
curl -sSL https://pkg.osquery.io/deb/pubkey.gpg | sudo gpg --dearmor -o /etc/apt/keyrings/osquery.gpg

# Set proper permissions on the keyring
sudo chmod 644 /etc/apt/keyrings/osquery.gpg

# Add the repository with signed-by directive
echo "deb [arch=amd64 signed-by=/etc/apt/keyrings/osquery.gpg] https://pkg.osquery.io/deb deb main" | sudo tee /etc/apt/sources.list.d/osquery.list

# Update and install
sudo apt-get update
sudo apt-get install -y osquery