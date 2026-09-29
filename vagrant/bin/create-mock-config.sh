#!/bin/bash

#!/bin/bash
set -euo pipefail

# $1: IP
# $2: The specific VM name (Host) to extract.
# $3: Path to the output file where the JSON will be written.

# --- Input validation ---
if [[ $# -ne 4 ]]; then
    echo "Usage: $0 <ip> <vm-name> <output-json-path> <known-hosts-file>" >&2
    exit 1
fi

IP="$1"
VM_NAME="$2"
OUTPUT_FILE="$3"
KNOWN_HOSTS_FILE="$4"

# --- Extract connection details ---
HOSTNAME=$IP
USER=ubuntu
PORT=22
IDENTITY_FILE=/tmp/dummy-identify # dummy data

# --- Create JSON output ---
# Using jq to safely construct the JSON object.
jq -n \
  --arg address "$HOSTNAME" \
  --argjson port "$PORT" \
  --arg user "$USER" \
  --arg privateKeyPath "/path/to/private-key" \
  --arg private_ip "$IP" \
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
