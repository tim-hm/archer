#! /usr/bin/bash

iwctl --passphrase $WIFI_PASS station wlan0 connect $SSID

sleep 5

if ! ping google.com -c 1 -W 1000; then 
  echo "Failed to connect to the internet"
  exit 1
else
  echo "Connected"
fi