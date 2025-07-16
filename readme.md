# Sail 🐳 | A Docker Environment for WordPress Development

This repository provides a fully containerized WordPress development environment using Docker Compose. It includes:

- PHP-FPM (custom image)
- nginx
- MySQL
- phpMyAdmin
- WordPress core
- WP-CLI for automation (with theme auto-activation and plugin cleanup)
- Custom `sail.sh` and `dock.sh` scripts for easy bootstrapping and teardown

## Requirements

- [Docker](https://docs.docker.com/get-docker/) installed and running on your system  
  (Docker Desktop is optional — any Docker-compatible runtime works)
- A WordPress theme folder (your own or cloned from Git)

---

## Getting Started

1. Place your theme files inside the `theme/` directory.
2. If you want to rename the theme folder, search and replace `theme` in the config files.
3. Ensure Docker is installed and running.
4. Run `sail.sh` to start the environment.
5. Run `dock.sh` to stop the environment.

---

## Login Information

**WordPress Admin**

- URL: http://localhost:8081/wp-admin
- Username: `admin`
- Password: `admin`
- Email: `admin@example.com`

**phpMyAdmin**

- URL: http://localhost:8080
- Server: `db`
- Username: `root`
- Password: `root`

---

## Features

- One-command WordPress setup with theme auto-activation
- Persistent database and uploads using Docker volumes
- Fast rebuilds and isolated environments per theme
- WP-CLI support for scripted installs and automation

---

## To Do

- Add script to pull plugins and DB from production
- Add optional domain-based routing (e.g. `mytheme.test`)
- Improve multi-environment support via `.env`
