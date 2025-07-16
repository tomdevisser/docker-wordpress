#!/bin/bash

# Load config
source ./config/sail.conf

# Set local database backup directory
local_db_dir="./database"
mkdir -p "$local_db_dir"

# Generate timestamped filename
now=$(date +"%Y%m%d_%H%M%S")
local_sql_file="$local_db_dir/live_$now.sql"
remote_sql_file="live_$now.sql"

# Check required variables
if [[ -z "$remote_user" || -z "$remote_host" || -z "$remote_port" || -z "$remote_path" ]]; then
  echo "Missing SFTP/SSH credentials in config. Skipping database sync."
  exit 0
fi

# Export database on remote server
sshpass -p "$remote_pass" ssh -p "$remote_port" -o StrictHostKeyChecking=no "$remote_user@$remote_host" "cd $remote_path && wp db export --allow-root $remote_sql_file"
if [[ $? -ne 0 ]]; then
  echo "Failed to export database on remote server."
  exit 1
fi

# Get remote domain (with protocol)
remote_siteurl=$(sshpass -p "$remote_pass" ssh -p "$remote_port" -o StrictHostKeyChecking=no "$remote_user@$remote_host" "cd $remote_path && wp option get siteurl --allow-root")
if [[ -z "$remote_siteurl" ]]; then
  echo "Failed to get remote siteurl."
  exit 1
fi

# Download the SQL file
sshpass -p "$remote_pass" scp -P "$remote_port" -o StrictHostKeyChecking=no "$remote_user@$remote_host:$remote_path/$remote_sql_file" "$local_sql_file"
if [[ $? -ne 0 ]]; then
  echo "Failed to download database export."
  exit 1
fi

# Clean up remote SQL file
sshpass -p "$remote_pass" ssh -p "$remote_port" -o StrictHostKeyChecking=no "$remote_user@$remote_host" "rm $remote_path/$remote_sql_file"

# Import into local WordPress
# Copy SQL file into the container
container_path="/var/www/html/$remote_sql_file"
docker cp "$local_sql_file" dev-wordpress:"$container_path"

echo "Importing external database into local WordPress..."

docker exec dev-wordpress wp db import "$container_path" --allow-root
if [[ $? -ne 0 ]]; then
  echo "Failed to import database into local WordPress."
  exit 1
fi

# Search-replace remote siteurl with local siteurl (including protocol)
echo "Running search-replace for siteurl..."
docker exec dev-wordpress wp search-replace "$remote_siteurl" "https://$domain" --all-tables --allow-root

# Remove the SQL file from the container after import (cleanup)
docker exec dev-wordpress rm "$container_path"

echo "Database sync complete. Backup saved as $local_sql_file." 