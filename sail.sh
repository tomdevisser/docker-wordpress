#!/bin/bash

# Spin up Docker containers for WordPress, MySQL, PhpMyAdmin and nginx.
docker compose build > /dev/null 2>&1
echo "Spinning up the Docker containers..."
docker compose up -d > /dev/null 2>&1

echo "Waiting for MySQL..."
until docker exec dev-mysql mysqladmin ping -h "localhost" --silent > /dev/null 2>&1; do
	sleep 1
done
echo "The database is ready!"

echo "Checking if WordPress is installed..."
if docker exec dev-wordpress wp core is-installed --allow-root > /dev/null 2>&1; then
	echo "WordPress is already installed!"
else
	echo "Installing WordPress..."
	docker exec dev-wordpress wp core install \
		--allow-root \
		--url=http://localhost:8081 \
		--title="Sail Development" \
		--admin_user=admin \
		--admin_password=admin \
		--admin_email=admin@example.com \
		#> /dev/null 2>&1

	docker exec dev-wordpress wp plugin uninstall \
		--allow-root \
		--all \
		#> /dev/null 2>&1
fi

echo "WordPress is now running!"
echo ""
echo "You can view your site at http://localhost:8081/"
echo "Or browse your databse in PhpMyAdmin at http://localhost:8080/"
