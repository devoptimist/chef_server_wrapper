#!/bin/bash
set -eu -o pipefail
if [[ -f /etc/opscode/private-chef-secrets.json ]]; then
    VAR1=$(jq '.veil' /etc/opscode/private-chef-secrets.json)
  else
      VAR1=$(cat <<EOF
{"veil": ""}
EOF
  )
fi
echo "${VAR1}" | jq '.'
