#!/bin/bash

# Check if the Sail configuration file exists.
if [ ! -f ./sail.conf ]; then
	echo "Missing sail.conf, please create one or use the provided sample."
	exit 1
fi

if ! command -v mkcert &> /dev/null; then
	echo "mkcert is not installed. Please install it via Homebrew: brew install mkcert"
fi

# Ensure mkcert CA is installed, so certs are trusted by default.
ca_file="$HOME/Library/Application Support/mkcert/rootCA.pem"
if [[ ! -f "$ca_file" ]]; then
  echo "mkcert CA not found, installing..."
  mkcert -install > /dev/null 2>&1 
else
  echo "mkcert CA already trusted by your system."
fi

# Load the Sail configuration file.
source ./sail.conf

# Validate the config variables.
if [ -z "$domain" ]; then
	echo "'domain' is not set in sail.conf."
	exit 1
fi

cert_file="./certs/cert.pem"
key_file="./certs/key.pem"

if [[ ! -f "$cert_file" || ! -f "$key_file" ]]; then
	echo "Generating TLS certificate for $domain and pma.$domain..."
	mkcert "$domain" "pma.$domain" > /dev/null 2>&1

	generated_cert=$(ls "$domain"*\.pem | grep -v 'key')
	generated_key=$(ls "$domain"*-key.pem)

	mv "$generated_cert" "$cert_file"
	mv "$generated_key" "$key_file"
fi

# Check if the domain exists in /etc/hosts.
if ! grep -q "$domain" /etc/hosts; then
	echo "Adding $domain to /etc/hosts (requires sudo)..."
	echo "127.0.0.1 $domain" | sudo tee -a /etc/hosts > /dev/null
fi

# Check if the PMAdomain exists in /etc/hosts.
if ! grep -q "pma.$domain" /etc/hosts; then
	echo "127.0.0.1 pma.$domain" | sudo tee -a /etc/hosts > /dev/null
fi

# Create a dynamic nginx/default.conf with the correct domain names.
cp nginx/default.template.conf nginx/default.conf
echo "" | sudo tee -a /etc/hosts > /dev/null # Add a newline first
sed -i '' "s|\$domain|$domain|g" nginx/default.conf
sed -i '' "s|\$pma_domain|pma.$domain|g" nginx/default.conf

# Spin up Docker containers for WordPress, MySQL, PhpMyAdmin and nginx.
docker compose build > /dev/null 2>&1
echo "Spinning up the Docker containers..."
docker compose up -d > /dev/null 2>&1

echo "Waiting for MySQL..."
until docker exec dev-mysql mysqladmin ping -h "localhost" --silent > /dev/null 2>&1; do
	sleep 1
done
echo "The database is ready!"

# Wait for WordPress DB to be connectable from inside the wp container.
echo "Waiting for WordPress to connect to MySQL..."

until docker exec dev-wordpress wp db check --allow-root > /dev/null 2>&1; do
  printf "."
  sleep 1
done
echo ""

echo "WordPress can connect to the database!"

# Install WordPress and prepare the environment with WP CLI.
echo "Checking if WordPress is installed..."
if docker exec dev-wordpress wp core is-installed --allow-root > /dev/null 2>&1; then
	echo "WordPress is already installed!"
else
	echo "Installing WordPress..."
	docker exec dev-wordpress wp core install \
		--allow-root \
		--url=https://$domain/ \
		--title="Sail Development" \
		--admin_user=admin \
		--admin_password=admin \
		--admin_email=admin@example.com \
		> /dev/null 2>&1

	docker exec dev-wordpress wp plugin uninstall \
		--allow-root \
		--all \
		> /dev/null 2>&1
fi

echo "WordPress is now running!"
echo ""
echo "You can view your site at https://$domain/."
echo "Or browse your databse in PhpMyAdmin at https://pma.$domain/."
