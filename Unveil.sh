#!/bin/bash

# Unveil - The Ultimate Auto Decoder

# Function to check if a command exists
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Check for required tools (base64, base32, and base58)
if ! command_exists base64 || ! command_exists base32; then
    echo "Error: Please install coreutils (base64, base32) before running this script."
    exit 1
fi

if ! command_exists base58; then
    echo "Warning: 'base58' not found. Install it with 'sudo apt install base58' if needed."
fi

# Get user input
echo -n "Enter the encoded string: "
read encoded

echo -e "\nTrying to decode with Unveil..."

# Function to check if output is valid ASCII text
is_valid_ascii() {
    echo "$1" | tr -d '\n' | grep -q "^[[:print:]]\+$"
}

# Try Base64 decoding
base64_decoded=$(echo "$encoded" | base64 -d 2>/dev/null)
if [ $? -eq 0 ] && is_valid_ascii "$base64_decoded"; then
    echo "[+] Base64 Decoded: $base64_decoded"
    exit 0
fi

# Try Base32 decoding (handle missing padding)
base32_fixed=$(echo "$encoded" | tr -d '=')
base32_decoded=$(echo "$base32_fixed" | base32 -d 2>/dev/null)
if [ $? -eq 0 ] && is_valid_ascii "$base32_decoded"; then
    echo "[+] Base32 Decoded: $base32_decoded"
    exit 0
fi

# Try Base58 decoding (if installed)
if command_exists base58; then
    base58_decoded=$(echo "$encoded" | base58 -d 2>/dev/null)
    if [ $? -eq 0 ] && is_valid_ascii "$base58_decoded"; then
        echo "[+] Base58 Decoded: $base58_decoded"
        exit 0
    fi
fi

# Try ROT13 decoding
rot13_decoded=$(echo "$encoded" | tr 'A-Za-z' 'N-ZA-Mn-za-m' 2>/dev/null)
if [ "$rot13_decoded" != "$encoded" ] && is_valid_ascii "$rot13_decoded"; then
    echo "[+] ROT13 Decoded: $rot13_decoded"
    exit 0
fi

echo "[-] Unveil could not determine encoding type or failed to decode. Try another input."
exit 1

