#!/bin/bash

# Update repo & upgrade dependencies/OS
sudo apt update && sudo apt -y upgrade

# Install tools
sudo apt -y install ovmf qemu-kvm qemu-system-x86

# Download windows server latest
wget -O win2022.iso "https://drive.massgrave.dev/en-us_windows_server_2022_updated_dec_2023_x64_dvd_f101ef8f.iso"

# Download & install ngrok
wget https://bin.equinox.io/c/bNyj1mQVY4c/ngrok-v3-stable-linux-amd64.tgz

# Extract ngrok
tar -xvzf ngrok-v3-stable-linux-amd64.tgz ; mv ngrok /usr/local/bin

# Add ngrok authtoken
export NGROK_AUTH_TOKEN=${{ secrets.NGROK_AUTH_TOKEN }} ; ngrok config add-authtoken $NGROK_AUTH_TOKEN

# Run ngrok tunnel(s)
ngrok tcp 5901

# Make vm images
qemu-img create -f raw win10.img 30G

# Start vm(s) with specified parameter(s)
qemu-system-x86_64 -smp 2 -cpu host -boot order=c -m 8G -device usb-ehci,id=usb,bus=pci.0,addr=0x4 -device usb-tablet -vnc 127.0.0.1:1 -drive file=win2022.iso,media=cdrom -drive file=win10.img,format=raw -device e1000,netdev=n0 -netdev user,id=n0 -vga qxl --enable-kvm -pflash /usr/share/OVMF/OVMF_CODE.fd