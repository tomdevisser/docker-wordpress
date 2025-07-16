# Sail 🐳 | A Docker Environment for WordPress Development

This repository provides a fully containerized WordPress development environment using Docker Compose. It includes:

- PHP-FPM (custom image)
- nginx
- MySQL
- phpMyAdmin
- WordPress core
- TLS certificates
- Custom domain mapping
- WP-CLI for automation (with theme auto-activation and plugin cleanup)
- Custom `sail` and `dock` scripts for easy bootstrapping and teardown

## Requirements

- [Docker](https://docs.docker.com/get-docker/) installed and running on your system  
  (Docker Desktop is optional — any Docker-compatible runtime works)
- [`mkcert`](https://github.com/FiloSottile/mkcert) installed for generating trusted local TLS certificates
- A WordPress theme folder (your own or cloned from Git)

---

## Getting Started

1. Place your theme files inside the `theme/` directory.
2. If you'd like to rename the `theme` folder, update all references to `theme` in the config files (`docker-compose.yml`, `config/sail.conf`, etc.).
3. Copy `config/sail.sample.conf` to `config/sail.conf` and edit your preferred domain name.
4. Run `./bin/sail` to build and start the environment.
5. Visit https://yourdomain.sail/ to view the site, and https://pma.yourdomain.sail/ to access the database.
6. Run `./bin/dock` to stop the environment.

---

## Login Information

**WordPress Admin**

- URL: https://yourdomain.sail/wp-admin/
- Username: `admin`
- Password: `admin`
- Email: `admin@example.com`

**phpMyAdmin**

- URL: https://pma.yourdomain.sail/
- Server: `db`
- Username: `root`
- Password: `root`

---

## Features

- One-command WordPress install with theme auto-activation
- Custom local domains and trusted TLS certificates via `mkcert`
- Persistent database and uploads using Docker volumes
- WP-CLI for automated tasks and bootstrapping
- phpMyAdmin included for convenient database access
- Isolated environments per theme for fast switching and clean separation

---

## To do

- Add script to pull plugins and database from production
- Add support for switching domains on demand
- Add support for Firefox CA trust
