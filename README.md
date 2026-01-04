# Docker Deep Dive (DDD)

A complete Docker-based WordPress development environment with MySQL and phpMyAdmin.

## Overview

This project provides a fully containerized WordPress development environment using Docker Compose. It includes:

- **WordPress**: Latest version of WordPress
- **MySQL 8.0**: Database server
- **phpMyAdmin**: Web-based database management tool

## Prerequisites

- [Docker](https://docs.docker.com/get-docker/) (version 20.10 or higher)
- [Docker Compose](https://docs.docker.com/compose/install/) (version 2.0 or higher)

## Quick Start

### 1. Clone the Repository

```bash
git clone https://github.com/rangasam/ddd.git
cd ddd
```

### 2. Configure Environment Variables

Copy the example environment file and customize it:

```bash
cp .env.example .env
```

Edit `.env` to customize your configuration:

```
MYSQL_ROOT_PASSWORD=your_secure_password
MYSQL_DATABASE=wordpress
MYSQL_USER=wordpress
MYSQL_PASSWORD=your_wordpress_password
WORDPRESS_PORT=8080
PHPMYADMIN_PORT=8081
```

### 3. Start the Services

```bash
docker compose up -d
```

This command will:
- Download the necessary Docker images (first time only)
- Create and start all containers in detached mode
- Set up the network and volumes

### 4. Access the Applications

- **WordPress**: http://localhost:8080
- **phpMyAdmin**: http://localhost:8081

## Usage

### Using Make Commands (Recommended)

If you have `make` installed, you can use convenient shortcuts:

```bash
# Start the environment
make up

# Stop the environment
make down

# View logs
make logs

# See all available commands
make help
```

### Using Docker Compose Directly

### Starting the Environment

```bash
docker compose up -d
```

### Stopping the Environment

```bash
docker compose down
```

### Stopping and Removing All Data

**Warning**: This will delete all data including the database!

```bash
docker compose down -v
```

### Viewing Logs

```bash
# All services
docker compose logs -f

# Specific service
docker compose logs -f wordpress
docker compose logs -f db
docker compose logs -f phpmyadmin
```

### Restarting Services

```bash
docker compose restart
```

## WordPress Installation

1. Navigate to http://localhost:8080
2. Select your language
3. Click "Let's go!" to begin the installation
4. WordPress will automatically configure the database connection
5. Fill in your site information:
   - Site Title
   - Username
   - Password
   - Email
6. Click "Install WordPress"

## Project Structure

```
ddd/
├── docker-compose.yml    # Docker Compose configuration
├── .env.example          # Example environment variables
├── .env                  # Your environment variables (not in git)
├── .gitignore           # Git ignore rules
├── README.md            # This file
└── wp-content/          # WordPress themes, plugins, and uploads (created on first run)
```

## Services Details

### WordPress Container

- **Image**: wordpress:latest
- **Container Name**: ddd_wordpress
- **Port**: 8080 (configurable via WORDPRESS_PORT)
- **Depends On**: MySQL database

### MySQL Container

- **Image**: mysql:8.0
- **Container Name**: ddd_mysql
- **Authentication**: mysql_native_password
- **Persistent Volume**: db_data

### phpMyAdmin Container

- **Image**: phpmyadmin:latest
- **Container Name**: ddd_phpmyadmin
- **Port**: 8081 (configurable via PHPMYADMIN_PORT)

## Customization

### Using Custom Themes or Plugins

WordPress content is mounted to the `./wp-content` directory. You can:

1. Add custom themes to `./wp-content/themes/`
2. Add custom plugins to `./wp-content/plugins/`
3. Access uploads in `./wp-content/uploads/`

### Changing PHP Configuration

Create a custom Dockerfile extending the WordPress image:

```dockerfile
FROM wordpress:latest

# Install additional PHP extensions
RUN docker-php-ext-install mysqli pdo pdo_mysql

# Custom PHP configuration
RUN echo "upload_max_filesize = 64M" > /usr/local/etc/php/conf.d/uploads.ini
```

Update `docker-compose.yml` to build from this Dockerfile instead of using the image.

## Troubleshooting

### Port Already in Use

If ports 8080 or 8081 are already in use, change them in your `.env` file:

```
WORDPRESS_PORT=9000
PHPMYADMIN_PORT=9001
```

### Database Connection Issues

Ensure the database container is fully started before WordPress attempts to connect:

```bash
docker compose logs db
```

### Reset Everything

To start fresh:

```bash
docker compose down -v
rm -rf wp-content/
docker compose up -d
```

## Backup and Restore

### Backup Database

```bash
docker exec -e MYSQL_PWD=wordpress ddd_mysql mysqldump -u wordpress wordpress > backup.sql
```

### Restore Database

```bash
docker exec -i -e MYSQL_PWD=wordpress ddd_mysql mysql -u wordpress wordpress < backup.sql
```

### Backup WordPress Files

```bash
tar -czf wp-content-backup.tar.gz wp-content/
```

## Production Considerations

**Note**: This setup is designed for development. For production, consider:

- Using specific version tags instead of `latest`
- Setting up SSL/TLS certificates
- Implementing proper security measures
- Using managed database services
- Setting up proper backup strategies
- Configuring resource limits
- Using secrets management for sensitive data

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

## License

This project is licensed under the GNU General Public License v3.0 - see the [LICENSE](LICENSE) file for details.

## Resources

- [Docker Documentation](https://docs.docker.com/)
- [WordPress Docker Image](https://hub.docker.com/_/wordpress)
- [MySQL Docker Image](https://hub.docker.com/_/mysql)
- [phpMyAdmin Docker Image](https://hub.docker.com/_/phpmyadmin)
- [WordPress Codex](https://codex.wordpress.org/)
