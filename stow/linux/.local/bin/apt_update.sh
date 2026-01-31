#!/bin/bash
set -e

if grep -q 'ID=ubuntu' /etc/os-release; then
    echo "Confirmed: Running on Ubuntu. Proceeding..."
else
    echo "Error: This script is designed for Ubuntu only."
    exit 1
fi

# Update and upgrade packages
sudo apt update
sudo apt upgrade -y

# Get a sorted list of installed linux-image versions
kernels=($(dpkg --list | awk '/linux-image-[0-9]+/ {print $2}' | sed 's/linux-image-//' | sort -V))

# How many to keep
keep=2
count=${#kernels[@]}

# Only attempt removal if there are more than $keep kernels
if (( count > keep )); then
  # Determine kernels to remove
  remove=("${kernels[@]:0:count-keep}")

  for kver in "${remove[@]}"; do
    echo "Removing linux-image-$kver..."
    sudo apt remove --purge -y "linux-image-$kver"
  done
else
  echo "Only $count kernels found. Nothing to remove."
fi

# Cleanup unused dependencies
sudo apt autoremove --purge -y
