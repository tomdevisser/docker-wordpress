#!/bin/bash

# Load the Sail configuration file (needed for domain variable)
source ./config/sail.conf

echo "Syncing with remote server..."

local_plugins_dir="./plugins"

if [[ -z "$remote_user" || -z "$remote_host" || -z "$remote_port" || -z "$remote_path" || -z "$remote_pass" ]]; then
  echo "Missing SFTP/SSH credentials in config. Skipping plugin sync."
  exit 0
fi

sshpass -p "$remote_pass" rsync -rLtz --delete --exclude=.gitkeep -e "ssh -p $remote_port -o StrictHostKeyChecking=no" \
  "$remote_user@$remote_host:$remote_path/wp-content/plugins/" \
  "$local_plugins_dir/"

if [[ $? -eq 0 ]]; then
  echo "Plugins synced successfully."
else
  echo "Error syncing plugins."
fi

# Get WordPress core version from remote server
remote_wp_version=$(sshpass -p "$remote_pass" ssh -p "$remote_port" -o StrictHostKeyChecking=no "$remote_user@$remote_host" "cd $remote_path && wp core version --allow-root" 2>/dev/null)

# Get local WordPress core version
local_wp_version=$(docker exec dev-wordpress wp core version --allow-root 2>/dev/null)

if [[ -n "$remote_wp_version" ]]; then
  if [[ "$remote_wp_version" != "$local_wp_version" ]]; then
    echo "Updating local WordPress to match remote version: $remote_wp_version (was $local_wp_version)"
    docker exec dev-wordpress wp core update --version="$remote_wp_version" --force --allow-root
  else
    echo "Local WordPress core version already matches remote ($remote_wp_version). No update needed."
  fi
else
  echo "Could not retrieve remote WordPress version. Skipping core version sync."
fi

