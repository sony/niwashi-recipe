#!/bin/bash
set -euo pipefail

# Usage function
usage() {
    echo "Usage: $0 <ssh_config_file> [output_file]" >&2
    echo "  ssh_config_file: Path to SSH config file" >&2
    echo "  output_file:     Path to output known_hosts file (optional, defaults to stdout)" >&2
    exit 1
}

# Check arguments
if [ $# -lt 1 ]; then
    usage
fi

SSH_CONFIG_FILE="$1"
OUTPUT_FILE="${2:-}"

# Check if ssh_config file exists
if [ ! -f "$SSH_CONFIG_FILE" ]; then
    echo "Error: SSH config file not found: $SSH_CONFIG_FILE" >&2
    exit 1
fi

# Temporary file for storing results
TEMP_OUTPUT=$(mktemp)
trap "rm -f $TEMP_OUTPUT" EXIT

# Parse ssh_config and extract Host, HostName, and Port
awk '
BEGIN {
    host = ""
    hostname = ""
    port = "22"
}
/^Host / {
    # Process previous host if exists
    if (host != "" && hostname != "") {
        print hostname ":" port
    }
    # Start new host
    host = $2
    hostname = ""
    port = "22"
}
/^[[:space:]]+HostName / {
    hostname = $2
}
/^[[:space:]]+Port / {
    port = $2
}
END {
    # Process last host
    if (host != "" && hostname != "") {
        print hostname ":" port
    }
}
' "$SSH_CONFIG_FILE" | while IFS=: read -r hostname port; do
    echo "Scanning $hostname:$port..." >&2
    # Run ssh-keyscan with timeout to avoid hanging
    if timeout 10 ssh-keyscan -p "$port" -T 5 "$hostname" 2>/dev/null >> "$TEMP_OUTPUT"; then
        echo "  Success" >&2
    else
        echo "  Failed or timeout" >&2
    fi
done

# Output results
if [ -n "$OUTPUT_FILE" ]; then
    mv "$TEMP_OUTPUT" "$OUTPUT_FILE"
    echo "Known hosts file created: $OUTPUT_FILE" >&2
else
    cat "$TEMP_OUTPUT"
fi
