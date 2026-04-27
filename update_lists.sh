#!/bin/bash

# Định nghĩa đường dẫn tương đối trong Github Workspace
DIR="rules"
BLOCK_OUT="./$DIR/blocklists.txt"
ALLOW_OUT="./$DIR/allowlists.txt"
BLOCK_TMP="/tmp/blocklists.tmp"
ALLOW_TMP="/tmp/allowlists.tmp"

# Tạo thư mục rules nếu chưa có
mkdir -p "./$DIR"

# Cleanup khi script exit
trap "rm -f $BLOCK_TMP $ALLOW_TMP; exit" INT TERM EXIT

extract_domains() {
  awk '{
    if (/^[[:space:]]*$/ || /^[!#]/) next
    line = tolower($0)
    sub(/^@@\|\|?/, "", line)
    sub(/^\|\|?/, "", line)
    sub(/\^.*/, "", line)
    sub(/[#!].*/, "", line)
    sub(/\/.*/, "", line)
    sub(/:.*/, "", line)
    sub(/^[0-9.]+[[:space:]]+/, "", line)
    gsub(/^[[:space:]]+|[[:space:]]+$/, "", line)
    if (line ~ /^[a-z0-9]([a-z0-9-]{0,61}[a-z0-9])?(\.[a-z0-9]([a-z0-9-]{0,61}[a-z0-9])?)+$/ && !seen[line]++) print line
  }'
}

echo "Downloading and processing blocklists..."
curl -fsSL --max-time 60 \
https://v.firebog.net/hosts/AdguardDNS.txt \
https://raw.githubusercontent.com/bigdargon/hostsVN/master/hosts \
https://raw.githubusercontent.com/badmojr/1Hosts/master/Lite/domains.wildcards \
https://cdn.jsdelivr.net/gh/hagezi/dns-blocklists@latest/wildcard/popupads-onlydomains.txt \
https://v.firebog.net/hosts/Easyprivacy.txt \
https://cdn.jsdelivr.net/gh/hagezi/dns-blocklists@latest/domains/native.apple.txt \
https://cdn.jsdelivr.net/gh/hagezi/dns-blocklists@latest/domains/native.tiktok.extended.txt \
https://cdn.jsdelivr.net/gh/hagezi/dns-blocklists@latest/domains/native.xiaomi.txt \
https://raw.githubusercontent.com/bibicadotnet/AdGuard-Home-blocklists/refs/heads/main/byme.txt \
https://urlhaus.abuse.ch/downloads/hostfile \
https://cdn.jsdelivr.net/gh/hagezi/dns-blocklists@latest/wildcard/tif.mini-onlydomains.txt \
| extract_domains > "$BLOCK_TMP"

echo "Downloading and processing allowlists..."
curl -fsSL --max-time 60 \
https://raw.githubusercontent.com/bibicadotnet/AdGuard-Home-blocklists/refs/heads/main/whitelist.txt \
| extract_domains > "$ALLOW_TMP"

# Di chuyển file tmp vào thư mục đích
mv "$BLOCK_TMP" "$BLOCK_OUT"
mv "$ALLOW_TMP" "$ALLOW_OUT"

echo "Done. Files saved to $BLOCK_OUT and $ALLOW_OUT"
