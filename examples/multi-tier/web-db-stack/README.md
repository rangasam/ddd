# Web + Database Stack

A multi-container application demonstrating Docker Compose with a web app and PostgreSQL database.

## Architecture

```
┌─────────────┐
│   Web App   │  (Node.js + Express)
│  Port 3000  │
└──────┬──────┘
       │
       │ app_network
       │
┌──────▼──────┐
│  PostgreSQL │
│  Database   │
└─────────────┘
```

## Features

- Node.js web application
- PostgreSQL database
- Named volumes for data persistence
- Custom network for service communication
- Health checks for both services
- Automatic dependency management

## Usage

```bash
# Start the stack
docker-compose up -d

# View logs
docker-compose logs -f

# Check service status
docker-compose ps

# Access the application
curl http://localhost:3000

# Stop the stack
docker-compose down

# Stop and remove volumes (deletes data)
docker-compose down -v
```

## Test the Application

```bash
# Visit counter endpoint
curl http://localhost:3000

# Health check
curl http://localhost:3000/health

# Access database directly
docker-compose exec db psql -U appuser -d appdb -c "SELECT * FROM visits;"
```

## Learning Points

### Docker Compose Features

**Services:**
- `web`: Custom application built from Dockerfile
- `db`: PostgreSQL from official image

**Networking:**
- Services communicate using service names as hostnames
- `web` connects to database using `db:5432`

**Volumes:**
- `postgres_data`: Named volume persists database data
- Survives `docker-compose down` (unless using `-v` flag)

**Dependencies:**
- `depends_on` with health check ensures database is ready
- Web app waits for database to be healthy before starting

**Environment Variables:**
- Configure services without changing code
- Separate dev/prod configurations

## Advanced Commands

```bash
# View logs for specific service
docker-compose logs web

# Execute command in running container
docker-compose exec web sh
docker-compose exec db psql -U appuser -d appdb

# Rebuild services
docker-compose build

# Restart specific service
docker-compose restart web

# Scale services (requires removing container_name)
docker-compose up -d --scale web=3
```

## Project Structure

```
web-db-stack/
├── docker-compose.yml    # Orchestration file
└── web/
    ├── Dockerfile        # Web app container definition
    ├── app.js           # Application code
    └── package.json     # Node.js dependencies
```

## Best Practices Demonstrated

1. ✅ Named volumes for data persistence
2. ✅ Health checks for service readiness
3. ✅ Custom networks for isolation
4. ✅ Environment variables for configuration
5. ✅ Proper dependency management
6. ✅ Restart policies for resilience
