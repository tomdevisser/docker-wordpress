#!/bin/bash

# Load the Sail configuration file (needed for domain variable)
source ./config/sail.conf

ca_file="$HOME/Library/Application Support/mkcert/rootCA.pem"
if [[ ! -f "$ca_file" ]]; then
  echo "mkcert CA certificate not found. Installing CA..."
  mkcert -install > /dev/null 2>&1 
fi

cert_file="./certs/cert.pem"
key_file="./certs/key.pem"

if [[ ! -f "$cert_file" || ! -f "$key_file" ]]; then
	echo "Generating TLS certificates for $domain and pma.$domain..."
	mkcert "$domain" "pma.$domain" > /dev/null 2>&1

	generated_cert=$(ls "$domain"*\.pem | grep -v 'key')
	generated_key=$(ls "$domain"*-key.pem)

	mv "$generated_cert" "$cert_file"
	mv "$generated_key" "$key_file"
fi 