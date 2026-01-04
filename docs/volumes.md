# Docker Volumes and Data Management

Understanding data persistence and management in Docker containers.

## Types of Data Storage

### 1. Volumes (Recommended)

Managed by Docker, stored in Docker's storage directory.

```bash
# Create a volume
docker volume create my-data

# Use volume in container
docker run -v my-data:/app/data nginx

# With docker-compose
volumes:
  my-data:
    driver: local
```

**Advantages:**
- ✅ Managed by Docker
- ✅ Work on all platforms
- ✅ Can be backed up easily
- ✅ Better performance on Mac/Windows
- ✅ Can be shared between containers

### 2. Bind Mounts

Mount a host directory into container.

```bash
# Mount current directory
docker run -v $(pwd):/app nginx

# Read-only mount
docker run -v $(pwd):/app:ro nginx

# With docker-compose
volumes:
  - ./src:/app/src
```

**Use cases:**
- Development (live code reloading)
- Config file injection
- Log file access

**Disadvantages:**
- ❌ Path dependencies
- ❌ Less portable
- ❌ Security concerns

### 3. tmpfs Mounts

Store in host memory (Linux only).

```bash
docker run --tmpfs /app/cache nginx
```

**Use cases:**
- Temporary data
- Sensitive information
- Performance-critical caching

## Volume Commands

```bash
# List volumes
docker volume ls

# Create volume
docker volume create my-volume

# Inspect volume
docker volume inspect my-volume

# Remove volume
docker volume rm my-volume

# Remove unused volumes
docker volume prune

# Remove all volumes
docker volume prune -a
```

## Using Volumes

### Anonymous Volumes

```dockerfile
# In Dockerfile
VOLUME /app/data
```

```bash
docker run nginx
# Creates anonymous volume automatically
```

### Named Volumes

```bash
# Create and use
docker run -v my-data:/app/data nginx

# Multiple containers sharing volume
docker run -v shared:/data container1
docker run -v shared:/data container2
```

### Bind Mounts

```bash
# Development mode
docker run -v $(pwd)/src:/app/src node npm run dev

# Config file
docker run -v $(pwd)/nginx.conf:/etc/nginx/nginx.conf:ro nginx

# Logs
docker run -v $(pwd)/logs:/var/log/app myapp
```

## Docker Compose Examples

### Basic Volume

```yaml
version: '3.8'

services:
  db:
    image: postgres
    volumes:
      - postgres_data:/var/lib/postgresql/data

volumes:
  postgres_data:
```

### Multiple Volume Types

```yaml
version: '3.8'

services:
  app:
    build: .
    volumes:
      # Named volume for data
      - app_data:/app/data
      
      # Bind mount for development
      - ./src:/app/src
      
      # Bind mount read-only
      - ./config.json:/app/config.json:ro
      
      # Anonymous volume
      - /app/node_modules

volumes:
  app_data:
    driver: local
```

### Volume with Driver Options

```yaml
volumes:
  data:
    driver: local
    driver_opts:
      type: nfs
      o: addr=192.168.1.1,rw
      device: ":/path/to/dir"
```

## Data Backup and Restore

### Backup Volume

```bash
# Backup to tar file
docker run --rm \
  -v my-volume:/data \
  -v $(pwd):/backup \
  alpine tar czf /backup/backup.tar.gz -C /data .

# Using postgres example
docker run --rm \
  -v postgres_data:/var/lib/postgresql/data \
  -v $(pwd):/backup \
  postgres:15 \
  tar czf /backup/postgres-backup.tar.gz -C /var/lib/postgresql/data .
```

### Restore Volume

```bash
# Restore from tar file
docker run --rm \
  -v my-volume:/data \
  -v $(pwd):/backup \
  alpine sh -c "cd /data && tar xzf /backup/backup.tar.gz"
```

### Database Backup

```bash
# PostgreSQL backup
docker exec postgres pg_dump -U user dbname > backup.sql

# Restore
docker exec -i postgres psql -U user dbname < backup.sql

# MySQL backup
docker exec mysql mysqldump -u root -p dbname > backup.sql

# Restore
docker exec -i mysql mysql -u root -p dbname < backup.sql
```

## Volume Lifecycle

```bash
# Volume persists after container removal
docker run -v data:/app/data --name app1 nginx
docker rm app1
# 'data' volume still exists

# Volume removed with -v flag
docker run -v data:/app/data --name app2 nginx
docker rm -v app2
# 'data' volume is removed

# In docker-compose
docker-compose down        # Volumes persist
docker-compose down -v     # Volumes removed
```

## Performance Considerations

### Docker Desktop (Mac/Windows)

```yaml
services:
  app:
    volumes:
      # Slow: Bind mount
      - ./src:/app/src
      
      # Fast: Named volume
      - node_modules:/app/node_modules
```

**Pattern for development:**
```yaml
services:
  app:
    volumes:
      - ./src:/app/src              # Code
      - /app/node_modules            # Exclude node_modules
      - node_modules:/app/node_modules  # Use volume instead
```

## Common Patterns

### Development with Hot Reload

```yaml
services:
  web:
    build: .
    volumes:
      - ./src:/app/src
      - /app/node_modules
    command: npm run dev
```

### Persistent Database

```yaml
services:
  db:
    image: postgres
    volumes:
      - db_data:/var/lib/postgresql/data
      - ./init.sql:/docker-entrypoint-initdb.d/init.sql:ro

volumes:
  db_data:
```

### Shared Data Between Services

```yaml
services:
  writer:
    image: alpine
    volumes:
      - shared:/data
    command: sh -c "while true; do date >> /data/log.txt; sleep 5; done"
  
  reader:
    image: alpine
    volumes:
      - shared:/data:ro
    command: sh -c "while true; do tail -f /data/log.txt; done"

volumes:
  shared:
```

## Best Practices

1. **Use named volumes for data**: More manageable than anonymous volumes
2. **Use bind mounts for development**: Live reload, easy debugging
3. **Never store data in containers**: Containers are ephemeral
4. **Backup volumes regularly**: Automate backup process
5. **Use .dockerignore**: Prevent unnecessary files in build context
6. **Set proper permissions**: Match user IDs between host and container
7. **Use read-only mounts**: When data shouldn't be modified
8. **Clean up volumes**: Run `docker volume prune` regularly

## Troubleshooting

```bash
# Check volume location
docker volume inspect my-volume | grep Mountpoint

# Check volume usage
docker system df -v

# Fix permission issues
docker run -v data:/data alpine chown -R 1000:1000 /data

# Verify volume data
docker run --rm -v my-volume:/data alpine ls -la /data
```

## Summary

- **Volumes**: Docker-managed, portable, recommended
- **Bind mounts**: Direct host access, good for development
- **tmpfs**: In-memory, temporary data
- **Named volumes**: Explicit, manageable
- **Anonymous volumes**: Auto-created, less control
- **Backup/Restore**: Essential for data safety
- **Performance**: Named volumes faster on Docker Desktop
