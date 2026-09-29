#!/bin/bash

set -euo pipefail

# ---
#
# Generates a generic Ansible inventory (hosts.ini) and ssh_config.
#
# Arguments:
#   $1: Path to context.json
#   $2: Path to params.json
#   $3: Output directory path
#
# Outputs:
#   $3/ssh_config
#   $3/hosts.ini
#
# ---

# --- Argument validation ---
if [ "$#" -ne 3 ]; then
    echo "Usage: $0 <context.json> <params.json> <output_dir>"
    exit 1
fi

CONTEXT_JSON=$1
PARAMS_JSON=$2
OUTPUT_DIR=$3

# --- Create output directory ---
mkdir -p "$OUTPUT_DIR"

SSH_CONFIG_FILE="$OUTPUT_DIR/ssh_config"
HOSTS_INI_FILE="$OUTPUT_DIR/hosts.ini"

# ==============================================================================
# Generate ssh_config
# ==============================================================================
echo "Generating ssh_config to $SSH_CONFIG_FILE..."
# Initialize file
: > "$SSH_CONFIG_FILE"

# Read node info from context.json and generate ssh_config
jq -r '
  .inventory.nodes | to_entries[] |
  "Host " + .key + "\n" +
  "  HostName " + .value.connection.ssh.address.host + "\n" +
  "  Port " + (.value.connection.ssh.address.port | tostring) + "\n" +
  "  User " + .value.connection.ssh.address.user + "\n" +
  "  IdentityFile " + .value.connection.ssh.auth.privateKeyPath + "\n" +
  "  StrictHostKeyChecking no\n" +
  "  UserKnownHostsFile /dev/null\n"
' "$CONTEXT_JSON" > "$SSH_CONFIG_FILE"

# ==============================================================================
# Generate hosts.ini
# ==============================================================================
echo "Generating hosts.ini to $HOSTS_INI_FILE..."
# Initialize file
: > "$HOSTS_INI_FILE"

# --- [all] section ---
echo "[all]" >> "$HOSTS_INI_FILE"
jq -r '
  .inventory.nodes | to_entries[] |
  # Use the node name as the host, which will be resolved by ssh_config
  .key + " ip=" + .value.addresses[0]
' "$CONTEXT_JSON" >> "$HOSTS_INI_FILE"
echo "" >> "$HOSTS_INI_FILE"

# --- Dynamic group sections ---
# Read group info from params.json (.groups)
GROUP_NAMES=$(jq -r '.groups | keys[]' "$PARAMS_JSON")

for group in $GROUP_NAMES; do
  # Create section only if the group has nodes
  if [ -n "$(jq -r --arg g "$group" '.groups[$g][]' "$PARAMS_JSON")" ]; then
    echo "[$group]" >> "$HOSTS_INI_FILE"
    # Add nodes belonging to each group
    jq -r --arg g "$group" '.groups[$g][]' "$PARAMS_JSON" >> "$HOSTS_INI_FILE"
    echo "" >> "$HOSTS_INI_FILE"
  fi
done

# --- [all:vars] section ---
# Set ansible_ssh_common_args to use the generated ssh_config
# Other common vars can be added here from params.json if needed
echo "[all:vars]" >> "$HOSTS_INI_FILE"
echo "ansible_ssh_common_args='-F ./ssh_config'" >> "$HOSTS_INI_FILE"

# Conditionally add become settings if 'become_user' is provided
BECOME_USER=$(jq -r '.become_user // ""' "$PARAMS_JSON")
if [ -n "$BECOME_USER" ]; then
  echo "ansible_become=true" >> "$HOSTS_INI_FILE"
  echo "ansible_become_user=$BECOME_USER" >> "$HOSTS_INI_FILE"
fi

echo "Inventory generation complete."