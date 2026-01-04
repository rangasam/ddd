# Multi-tier Application Examples

This directory demonstrates Docker Compose for orchestrating multi-container applications.

## Examples

### 1. Web + Database Stack

A simple web application with PostgreSQL database.

### 2. Nginx + App + Database

A complete three-tier architecture with reverse proxy, application server, and database.

## Key Concepts

- **Docker Compose**: Tool for defining multi-container applications
- **Services**: Individual containers in your application
- **Networks**: Communication between containers
- **Volumes**: Persistent data storage
- **Dependencies**: Service startup order

## Docker Compose Basics

```bash
# Start all services
docker-compose up

# Start in background
docker-compose up -d

# View logs
docker-compose logs

# Stop all services
docker-compose down

# Stop and remove volumes
docker-compose down -v

# Rebuild images
docker-compose build

# Scale a service
docker-compose up -d --scale web=3
```

## Benefits of Docker Compose

1. **Single command deployment**: Start entire stack with one command
2. **Consistent environments**: Same setup for dev, test, and prod
3. **Isolation**: Each project has its own network
4. **Easy scaling**: Scale services up or down
5. **Service discovery**: Containers find each other by service name
