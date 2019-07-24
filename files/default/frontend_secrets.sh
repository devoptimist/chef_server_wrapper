#!/bin/bash
set -eu -o pipefail
if [[ -f /etc/opscode/private-chef-secrets.json ]]; then
    veil_hasher_secret=$(jq -r '.veil.hasher.secret' /etc/opscode/private-chef-secrets.json)
    veil_hasher_salt=$(jq  -r '.veil.hasher.salt' /etc/opscode/private-chef-secrets.json)
    veil_cipher_key=$(jq -r '.veil.cipher.key' /etc/opscode/private-chef-secrets.json)
    veil_cipher_iv=$(jq -r '.veil.cipher.iv' /etc/opscode/private-chef-secrets.json)
    veil_credentials=$(jq -r '.veil.credentials' /etc/opscode/private-chef-secrets.json)
    VAR1=$(cat <<EOF
{
  "veil_hasher_secret":"${veil_hasher_secret}",
  "veil_hasher_salt":"${veil_hasher_salt}",
  "veil_cipher_key":"${veil_cipher_key}",
  "veil_cipher_iv":"${veil_cipher_iv}",
  "veil_credentials":"${veil_credentials}"
}
EOF
  )
  else
    VAR1=$(cat <<EOF
{
  "veil_hasher_secret":"",
  "veil_hasher_salt":"",
  "veil_cipher_key":"",
  "veil_cipher_iv":"",
  "veil_credentials":""
}
EOF
  )
fi
echo "${VAR1}" | jq '.'
