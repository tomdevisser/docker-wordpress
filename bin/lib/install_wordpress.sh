#!/bin/bash

# Load the Sail configuration file (needed for domain variable)
source ./config/sail.conf

# Wait for MySQL to be ready
bin/lib/wait_for_mysql.sh

echo "Waiting for WordPress to connect to the database..."
until docker exec dev-wordpress wp db check --allow-root > /dev/null 2>&1; do
  printf "."
  sleep 1
done
echo ""

echo "Database connection established!"

echo "Checking WordPress installation status..."
if docker exec dev-wordpress wp core is-installed --allow-root > /dev/null 2>&1; then
	echo "WordPress is already installed."
else
	echo "Installing WordPress for the first time..."
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