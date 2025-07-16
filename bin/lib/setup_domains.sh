#!/bin/bash

# Load the Sail configuration file (needed for domain variable)
source ./config/sail.conf

if ! grep -q "$domain" /etc/hosts; then
	echo "Adding $domain to /etc/hosts (requires sudo)..."
	echo "127.0.0.1 $domain" | sudo tee -a /etc/hosts > /dev/null
fi

if ! grep -q "pma.$domain" /etc/hosts; then
	echo "Adding pma.$domain to /etc/hosts (requires sudo)..."
	echo "127.0.0.1 pma.$domain" | sudo tee -a /etc/hosts > /dev/null
fi 