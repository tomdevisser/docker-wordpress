#!/bin/bash

echo "Waiting for MySQL to become available..."
until docker exec dev-mysql mysqladmin ping -h "localhost" --silent > /dev/null 2>&1; do
	sleep 1
done
echo "MySQL is ready!" 