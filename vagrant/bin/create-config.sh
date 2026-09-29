#!/bin/bash
set -euo pipefail

# This script parses the output of `vagrant ssh-config` for a specific VM,
# and generates a JSON object containing the instance's connection details.
#
# $1: Path to the file containing `vagrant ssh-config` output for ALL VMs.
# $2: The specific VM name (Host) to extract.
# $3: Path to the output file where the JSON will be written.
# $4: The private IP address of the VM.
# $5: Path to the known hosts file.
# --- Input validation ---
if [[ $# -ne 5 ]]; then
    echo "Usage: $0 <ssh-config-path> <vm-name> <output-json-path> <ip-address> <known-hosts-file>" >&2
    exit 1
fi

SSH_CONFIG_FILE="$1"
VM_NAME="$2"
OUTPUT_FILE="$3"
IP_ADDRESS="$4"
KNOWN_HOSTS_FILE="$5"

if [[ ! -f "$SSH_CONFIG_FILE" ]]; then
    echo "Error: SSH config file not found at '$SSH_CONFIG_FILE'" >&2
    exit 1
fi

# --- Extract the block for the specific VM ---
# Use awk to find the block for the given VM_NAME. A block starts with "Host <VM_NAME>"
# and ends with a blank line or end of file.
VM_CONFIG=$(awk -v vm_name="$VM_NAME" '
    $1 == "Host" && $2 == vm_name { in_block=1 }
    in_block { print }
    /^[[:space:]]*$/ { in_block=0 }
' "$SSH_CONFIG_FILE")

if [[ -z "$VM_CONFIG" ]]; then
    echo "Error: Could not find config for VM '$VM_NAME' in '$SSH_CONFIG_FILE'" >&2
    exit 1
fi

# --- Helper function to extract value from the extracted block ---
get_config_value() {
    echo "$VM_CONFIG" | grep -i "^  $1\s" | awk '{print $2}' | sed 's/"//g'
}

# --- Extract connection details ---
HOSTNAME=$(get_config_value "HostName")
USER=$(get_config_value "User")
PORT=$(get_config_value "Port")
IDENTITY_FILE=$(get_config_value "IdentityFile")

if [[ ! -f "$IDENTITY_FILE" ]]; then
    # Vagrant sometimes uses relative paths. Try to resolve it relative to the config file's dir.
    BASE_DIR=$(dirname "$SSH_CONFIG_FILE")
    if [[ -f "$BASE_DIR/$IDENTITY_FILE" ]]; then
        IDENTITY_FILE="$BASE_DIR/$IDENTITY_FILE"
    else
        echo "Error: Identity file not found at '$IDENTITY_FILE'" >&2
        exit 1
    fi
fi

# --- Create JSON output ---
# Using jq to safely construct the JSON object.
jq -n \
  --arg address "$HOSTNAME" \
  --argjson port "$PORT" \
  --arg user "$USER" \
  --arg privateKeyPath "$IDENTITY_FILE" \
  --arg private_ip "$IP_ADDRESS" \
  --arg knownHostsPath "$KNOWN_HOSTS_FILE" \
  '{
    connection: {
      ssh: {
        address: {
          host: $address,
          port: $port,
          user: $user
        },
        auth: {
          method: "privateKey",
          privateKeyPath: $privateKeyPath
        },
        hostKey: {
          knownHostsPath: $knownHostsPath
        },
        options: {}
      }
    },
    addresses: [ $private_ip ]
  }' > "$OUTPUT_FILE"

chmod 600 "$OUTPUT_FILE"