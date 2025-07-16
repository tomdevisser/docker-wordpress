#!/bin/bash

# Load the Sail configuration file (needed for domain variable)
source ./config/sail.conf

echo "Generating Nginx configuration for $domain and pma.$domain..."

cp config/nginx/default.template.conf config/nginx/default.conf
echo "" | sudo tee -a /etc/hosts > /dev/null # Add a newline first
sed -i '' "s|\$domain|$domain|g" config/nginx/default.conf
sed -i '' "s|\$pma_domain|pma.$domain|g" config/nginx/default.conf 