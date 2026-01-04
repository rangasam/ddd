# Docker Networking Guide

Understanding how containers communicate with each other and the outside world.

## Network Types

### 1. Bridge Network (Default)

The default network type for containers.

```bash
# Create a bridge network
docker network create my-bridge

# Run containers on the network
docker run -d --network my-bridge --name web nginx
docker run -d --network my-bridge --name app node
```

**Characteristics:**
- Containers can communicate using container names as hostnames
- Isolated from host network
- Provides DNS resolution between containers
- Best for single-host deployments

### 2. Host Network

Container shares host's network stack.

```bash
docker run --network host nginx
```

**Characteristics:**
- No network isolation
- Container uses host's IP address
- Better performance (no NAT)
- Port conflicts possible
- Use cases: Performance-critical applications

### 3. None Network

No networking.

```bash
docker run --network none alpine
```

**Characteristics:**
- Complete network isolation
- Only loopback interface
- Use cases: Security-sensitive applications

### 4. Overlay Network

For multi-host networking (Swarm/Kubernetes).

```bash
docker network create -d overlay my-overlay
```

## Container Communication

### Same Network

Containers on the same network communicate using container names:

```yaml
# docker-compose.yml
services:
  web:
    image: nginx
  api:
    image: node
    environment:
      - API_URL=http://web:80
```

The `api` service can reach `web` at `http://web:80`.

### Different Networks

Containers on different networks cannot communicate by default.

```bash
# Connect container to additional network
docker network connect my-network container-name
```

## Port Mapping

Expose container ports to the host:

```bash
# Map port 80 in container to 8080 on host
docker run -p 8080:80 nginx

# Map to random host port
docker run -p 80 nginx

# Bind to specific interface
docker run -p 127.0.0.1:8080:80 nginx

# Map UDP port
docker run -p 8080:80/udp nginx
```

## Network Commands

```bash
# List networks
docker network ls

# Inspect network
docker network inspect bridge

# Create network
docker network create my-network

# Connect container to network
docker network connect my-network container-name

# Disconnect container from network
docker network disconnect my-network container-name

# Remove network
docker network rm my-network

# Remove unused networks
docker network prune
```

## Docker Compose Networking

Docker Compose automatically creates a network for your services.

```yaml
version: '3.8'

services:
  web:
    image: nginx
    networks:
      - frontend
      - backend
  
  api:
    image: node
    networks:
      - backend
  
  db:
    image: postgres
    networks:
      - backend

networks:
  frontend:
    driver: bridge
  backend:
    driver: bridge
    internal: true  # No external access
```

## Network Isolation Example

```yaml
version: '3.8'

services:
  # Public-facing web server
  nginx:
    image: nginx
    ports:
      - "80:80"
    networks:
      - public
  
  # Application server (not exposed)
  app:
    build: ./app
    networks:
      - public
      - private
  
  # Database (completely isolated)
  db:
    image: postgres
    networks:
      - private

networks:
  public:
    driver: bridge
  private:
    driver: bridge
    internal: true
```

**Security:**
- `nginx` is exposed to the internet
- `app` can talk to both `nginx` and `db`
- `db` is only accessible from `app`
- `private` network has no internet access

## DNS Resolution

Docker provides built-in DNS resolution:

```bash
# In container 'web'
ping api              # Resolves to 'api' container
ping api.my-network   # Fully qualified name
```

## Network Troubleshooting

```bash
# Check container's network settings
docker inspect container-name | grep -A 20 Networks

# Test connectivity between containers
docker exec web ping -c 3 api

# Check DNS resolution
docker exec web nslookup api

# View network interfaces
docker exec web ip addr

# Check open ports
docker exec web netstat -tuln
```

## Best Practices

1. **Use custom networks**: Don't rely on default bridge
2. **Name your containers**: For easy DNS resolution
3. **Minimize exposed ports**: Only expose what's necessary
4. **Use internal networks**: For services that don't need internet
5. **Implement network segmentation**: Separate frontend/backend/database
6. **Avoid host network**: Unless absolutely necessary for performance

## Common Patterns

### Multi-tier Application

```yaml
services:
  frontend:
    networks: [public]
  backend:
    networks: [public, private]
  database:
    networks: [private]
```

### Microservices

```yaml
services:
  api-gateway:
    networks: [external, services]
  service-a:
    networks: [services, data]
  service-b:
    networks: [services, data]
  database:
    networks: [data]
```

## Summary

- **Bridge**: Default, best for single-host apps
- **Host**: Direct host access, use sparingly
- **None**: Complete isolation
- **Overlay**: Multi-host deployments
- **Custom networks**: Provide DNS and isolation
- **Port mapping**: Expose services to host
- **Network segmentation**: Enhance security
