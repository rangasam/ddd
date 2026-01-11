# Docker Deep Dive — Comprehensive Guide

This repository contains practical examples, labs, and comprehensive documentation for learning Docker. It accompanies the Docker Deep Dive training material with hands-on projects, step-by-step instructions, best practices, and exercises.

**Repository:** `rangasam/ddd`  
**Course:** Docker Deep Dive (Pluralsight 2023 Edition)

---

## Table of Contents

- [Quick Start](#quick-start)
- [Prerequisites](#prerequisites)
- [Project Structure](#project-structure)
- [Projects](#projects)
  - [Compose - Multi-container Basics](#project-compose)
  - [Multi-stage Builds](#project-multi-stage)
  - [Node.js Application](#project-node-app)
  - [Docker Stacks](#project-stacks)
- [Docker Concepts](#docker-concepts)
  - [Dockerfile Best Practices](#dockerfile-best-practices)
  - [Networking](#networking)
  - [Volumes & Data Management](#volumes)
- [Exercises](#exercises)
- [Essential Commands](#essential-commands)
- [Safety & Security](#safety-and-security)
- [Troubleshooting](#troubleshooting)
- [Monitoring & Plotting](#monitoring)
- [Learning Path](#learning-path)
- [Lab Session Reference](#lab-session-reference)
- [Git Workflow](#git-workflow)

---

## Quick Start

Get started with Docker in 5 minutes!

### Your First Container

```bash
# Hello World
cd examples/basic/hello-world
docker build -t hello-world .
docker run hello-world

# Interactive Container
cd ../alpine-base
docker build -t alpine-example .
docker run -it alpine-example

# Web Application
cd ../../web-apps/simple-node-app
docker build -t simple-node-app .
docker run -d -p 3000:3000 --name node-app simple-node-app
curl http://localhost:3000

# Cleanup
docker stop node-app
docker rm node-app

# Multi-container Application
cd ../../multi-tier/web-db-stack
docker-compose up -d
curl http://localhost:3000
docker-compose down
```

---

## Prerequisites

### Required

- **macOS** (zsh) or any OS with Docker Desktop / Docker Engine
- **Docker Desktop** (recommended) or Docker Engine + Compose v2
- Ensure Docker daemon is running
- Verify installation:
  ```bash
  docker --version        # Docker version 28.0.4+
  docker compose version  # Docker Compose v2+
  ```

### Optional

- **Python 3.8+** with pip for plotting (packages: `pandas`, `matplotlib`)
- **Go 1.18+** for `multi-stage` project
- **Node.js** for `node-app` local development
- **Trivy** for image scanning: https://aquasecurity.github.io/trivy/
- **Hadolint** for Dockerfile linting

---

## Project Structure

```
.
├── compose/              # Docker Compose multi-container example
├── multi-stage/          # Multi-stage build example (Go)
├── node-app/             # Node.js web application
├── stacks/               # Docker Stack examples
├── stackv2-app/          # Stack variation
├── examples/
│   ├── basic/            # Fundamental Docker examples
│   ├── web-apps/         # Web application examples
│   └── multi-tier/       # Multi-container architectures
├── exercises/            # Hands-on learning exercises
├── docs/                 # Comprehensive documentation
├── tools/                # Helper scripts and utilities
└── docker-deep-dive-2023/  # Course slide materials
```

---

## Projects

### Project: `compose/`

**Purpose:** Demonstrate multi-container applications using Docker Compose (Python Flask + Redis).

**Files:**
- `compose/compose.yaml` — Compose definition
- `compose/Dockerfile` — Python Flask app
- `compose/app/` — Application code

**Quick Start:**

```bash
cd compose
# Build and run in foreground
docker compose up --build

# Or run detached
docker compose up --build --detach

# View logs
docker compose logs -f

# Stop and remove
docker compose down --volumes --remove-orphans
```

**Features:**
- Simple counter app that displays Docker image info
- Redis backend for counting page refreshes
- Pre-built image: `rangasam/ddd:compose`

**Development Tips:**
- Modify `compose/app/` Python code and rebuild
- Use bind mounts for faster iteration
- Add `.env` for environment variables

**Exercises:**
1. Add a healthcheck to the web service
2. Add a named volume and test data persistence
3. Add Redis password via environment variable

---

### Project: `multi-stage/`

**Purpose:** Demonstrate multi-stage Docker builds for smaller production images.

**Files:**
- `multi-stage/Dockerfile` — Multi-stage build
- `cmd/` — Go client/server example code

**Quick Start:**

```bash
cd multi-stage
# Build with Docker
docker build -t multi:stage .

# Run the service
docker run --rm -p 8080:8080 multi:stage

# Examine image layers
docker history multi:stage

# Inspect metadata
docker inspect multi:stage
```

**Key Concepts:**
- Compile in builder stage (with Go toolchain)
- Copy only binary into minimal runtime image
- Reduces final image size and attack surface
- Final image: ~9MB

**Example Output:**
```
IMAGE          CREATED              SIZE      
01e0fc5220eb   About a minute ago   7.92MB    # server binary
<missing>      About a minute ago   7.99MB    # client binary
```

**Exercises:**
1. Switch final stage to `scratch` or distroless
2. Compare image sizes
3. Add debug instrumentation

---

### Project: `node-app/`

**Purpose:** Containerize a Node.js web app with Dockerfile best practices.

**Files:**
- `node-app/Dockerfile`
- `node-app/app.js`
- `node-app/package.json`

**Quick Start:**

```bash
cd node-app
# Build image
docker build -t ddd:nodeweb1 .

# Run container
docker run -d --name web1 -p 8080:8080 ddd:nodeweb1

# Test
curl http://localhost:8080

# Cleanup
docker rm web1 -f
docker rmi ddd:nodeweb1
```

**Port:** 8080

**Lab Session Output (Real Example):**
```
Docker version: 28.0.4
Build time: 22.5s
Image size: 120MB (optimized) vs 176MB (unoptimized)
```

**Best Practices:**
- ✅ Add `.dockerignore` excluding `node_modules`
- ✅ Use specific Node base image (`node:18-alpine`)
- ✅ Create non-root user
- ✅ Add `HEALTHCHECK`

**Exercises:**
1. Add health check endpoint
2. Switch to Alpine base image
3. Add Redis cache with Compose

---

### Project: `stacks/`

**Purpose:** Demonstrate Docker Stack files and Swarm-specific options.

**Files:**
- `stacks/compose.yaml` — Stack definition with deploy options
- `stackv2-app/` — Stack variation

**Quick Start (Compose Local):**

```bash
docker compose -f stacks/compose.yaml up --build
```

**Using Docker Swarm (Advanced):**

```bash
# Initialize swarm
docker swarm init

# Deploy stack
docker stack deploy -c stacks/compose.yaml mystack

# List services
docker stack ls
docker stack services mystack

# Teardown
docker stack rm mystack
docker swarm leave --force
```

**⚠️ Caution:** Swarm mode modifies Docker state; use carefully.

---

## Docker Concepts

### Dockerfile Best Practices

#### 1. Use Specific Base Images

**Bad:**
```dockerfile
FROM node
```

**Good:**
```dockerfile
FROM node:18-alpine
```

#### 2. Minimize Layers

**Bad:**
```dockerfile
RUN apt-get update
RUN apt-get install -y curl
RUN apt-get install -y git
```

**Good:**
```dockerfile
RUN apt-get update && \
    apt-get install -y curl git && \
    rm -rf /var/lib/apt/lists/*
```

#### 3. Order Instructions by Change Frequency

**Bad:**
```dockerfile
COPY . .
RUN npm install
```

**Good:**
```dockerfile
COPY package*.json ./
RUN npm install
COPY . .
```

#### 4. Use Multi-stage Builds

```dockerfile
# Build stage
FROM node:18 AS builder
WORKDIR /app
COPY package*.json ./
RUN npm install
COPY . .
RUN npm run build

# Production stage
FROM node:18-alpine
WORKDIR /app
COPY --from=builder /app/dist ./dist
COPY package*.json ./
RUN npm ci --only=production
CMD ["node", "dist/index.js"]
```

#### 5. Run as Non-root User

```dockerfile
RUN adduser -D -u 1000 appuser
USER appuser
```

#### 6. Use HEALTHCHECK

```dockerfile
HEALTHCHECK --interval=30s --timeout=3s \
  CMD curl -f http://localhost/ || exit 1
```

#### Complete Example

```dockerfile
FROM node:18-alpine AS builder
WORKDIR /app
COPY package*.json ./
RUN npm ci --only=production

FROM node:18-alpine
RUN apk update && apk upgrade && rm -rf /var/cache/apk/*
WORKDIR /app
COPY --from=builder /app/node_modules ./node_modules
COPY --from=builder /app/package*.json ./
COPY . .

RUN addgroup -g 1001 -S nodejs && \
    adduser -S nodejs -u 1001 && \
    chown -R nodejs:nodejs /app

USER nodejs
EXPOSE 3000

HEALTHCHECK --interval=30s --timeout=3s \
  CMD node -e "require('http').get('http://localhost:3000/health', (r) => process.exit(r.statusCode === 200 ? 0 : 1))"

CMD ["node", "index.js"]
```

**Checklist:**
- [ ] Use specific base image versions
- [ ] Combine RUN commands
- [ ] Order by change frequency
- [ ] Use multi-stage builds
- [ ] Include .dockerignore
- [ ] Run as non-root user
- [ ] Add health checks
- [ ] Use COPY over ADD
- [ ] Pin dependency versions

---

### Networking

#### Network Types

**1. Bridge (Default)**
```bash
docker network create my-bridge
docker run -d --network my-bridge --name web nginx
docker run -d --network my-bridge --name app node
```

**2. Host**
```bash
docker run --network host nginx
```

**3. None**
```bash
docker run --network none alpine
```

**4. Overlay** (Multi-host)
```bash
docker network create -d overlay my-overlay
```

#### Port Mapping

```bash
# Map port 80 to 8080
docker run -p 8080:80 nginx

# Random host port
docker run -p 80 nginx

# Specific interface
docker run -p 127.0.0.1:8080:80 nginx

# UDP port
docker run -p 8080:80/udp nginx
```

#### Docker Compose Networking

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

#### Network Commands

```bash
docker network ls
docker network inspect bridge
docker network create my-network
docker network connect my-network container-name
docker network disconnect my-network container-name
docker network rm my-network
docker network prune
```

---

### Volumes

#### Types of Storage

**1. Volumes (Recommended)**
```bash
docker volume create my-data
docker run -v my-data:/app/data nginx
```

**2. Bind Mounts**
```bash
docker run -v $(pwd):/app nginx
docker run -v $(pwd):/app:ro nginx  # read-only
```

**3. tmpfs Mounts** (Linux only)
```bash
docker run --tmpfs /app/cache nginx
```

#### Volume Commands

```bash
docker volume ls
docker volume create my-volume
docker volume inspect my-volume
docker volume rm my-volume
docker volume prune
```

#### Docker Compose Volumes

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
      
      # Read-only config
      - ./config.json:/app/config.json:ro
      
      # Anonymous volume
      - /app/node_modules

volumes:
  app_data:
    driver: local
```

#### Backup and Restore

**Backup:**
```bash
docker run --rm \
  -v my-volume:/data \
  -v $(pwd):/backup \
  alpine tar czf /backup/backup.tar.gz -C /data .
```

**Restore:**
```bash
docker run --rm \
  -v my-volume:/data \
  -v $(pwd):/backup \
  alpine sh -c "cd /data && tar xzf /backup/backup.tar.gz"
```

---

## Exercises

### Exercise 1: Create Your First Dockerfile

**Difficulty:** Beginner  
**Time:** 15-20 minutes

Create a Docker image that:
1. Uses Python 3.11 base image
2. Installs `requests` library
3. Runs a script that fetches a URL
4. Runs as non-root user

```bash
docker build -t url-fetcher .
docker run -e URL=https://example.com url-fetcher
```

### Exercise 2: Multi-stage Build

**Difficulty:** Beginner  
**Time:** 20-30 minutes

Create a TypeScript Node.js app that:
1. Uses multi-stage build
2. Compiles TypeScript in build stage
3. Runs JavaScript in production stage
4. Final image < 150MB

### Exercise 3: Web App with Database

**Difficulty:** Intermediate  
**Time:** 30-40 minutes

Create a full-stack application:
1. Node.js REST API
2. PostgreSQL database
3. Redis cache
4. Docker Compose orchestration

**Services:**
- API: CRUD todo list
- Database: PostgreSQL with init script
- Cache: Redis for performance

---

## Essential Commands

### Images

```bash
docker images                    # List all images
docker build -t name:tag .       # Build image
docker rmi image-name            # Remove image
docker pull image-name           # Download image
docker history image-name        # View layers
docker inspect image-name        # View metadata
```

### Containers

```bash
docker ps                        # Running containers
docker ps -a                     # All containers
docker run image-name            # Run container
docker run -d image-name         # Run in background
docker run -it image-name sh     # Interactive shell
docker stop container-id         # Stop container
docker rm container-id           # Remove container
docker logs container-id         # View logs
docker exec -it container-id sh  # Execute command
```

### Docker Compose

```bash
docker compose up                # Start services
docker compose up -d             # Start in background
docker compose up --build        # Rebuild and start
docker compose down              # Stop services
docker compose down -v           # Stop and remove volumes
docker compose ps                # List services
docker compose logs              # View logs
docker compose logs -f           # Follow logs
```

### Cleanup

```bash
docker system prune              # Remove unused data
docker system prune -a           # Remove all unused
docker volume prune              # Remove unused volumes
docker network prune             # Remove unused networks
docker system df                 # Show disk usage
```

---

## Safety and Security

### 1. Secrets & Credentials

- ❌ Never commit API keys or `.env` files
- ✅ Use Docker secrets (Swarm) or external secrets manager
- ✅ Add sensitive files to `.gitignore`

### 2. Image Scanning

```bash
# Scan with Trivy
trivy image myimage:latest

# Docker scan (if available)
docker scan myimage:latest
```

### 3. Least Privilege

- Run processes as non-root user in containers
- Use minimal base images (Alpine, distroless)
- Drop unnecessary capabilities

### 4. Network Exposure

- Prefer `127.0.0.1` for local-only services
- Avoid binding to `0.0.0.0` unless necessary
- Use internal networks for service-to-service communication

### 5. Resource Limits

```bash
docker run --memory=512m --cpus=0.5 myapp
```

```yaml
services:
  web:
    deploy:
      resources:
        limits:
          cpus: '0.50'
          memory: 512M
```

### 6. Health Checks

```yaml
healthcheck:
  test: ["CMD-SHELL", "curl -f http://localhost:3000 || exit 1"]
  interval: 30s
  timeout: 10s
  retries: 3
```

---

## Troubleshooting

### Build Errors

**Problem:** File not found during build
```bash
# Solution: Check build context
docker build -f path/to/Dockerfile .
```

**Problem:** Permission denied
```bash
# Solution: Check file ownership or run as correct user
```

### Port Conflicts

**Problem:** Port already in use
```bash
# Find process using port
lsof -i :3000

# Kill process or use different port
docker run -p 8080:3000 myapp
```

### Compose Issues

**Problem:** No such service
```bash
# Solution: Run from directory with compose.yaml or use -f
docker compose -f path/to/compose.yaml up
```

### Volume Performance

**Problem:** Slow bind mounts on macOS
```yaml
# Solution: Use named volumes for node_modules
volumes:
  - ./src:/app/src
  - /app/node_modules  # Exclude from bind mount
```

### Image Cleanup

**Problem:** Dangling images consuming space
```bash
# List dangling images
docker images -f "dangling=true"

# Remove specific image (stop containers first)
docker ps -a --filter "ancestor=image-id"
docker stop container-id
docker rm container-id
docker rmi image-id

# Or force remove
docker rmi -f image-id

# Global cleanup
docker system prune -a
```

### Network Troubleshooting

```bash
# Check container network settings
docker inspect container-name | grep -A 20 Networks

# Test connectivity
docker exec web ping -c 3 api

# Check DNS resolution
docker exec web nslookup api
```

---

## Monitoring

### Collect Docker Stats

**Collector Script:**

```bash
container=compose_web_1
echo "timestamp,cpu,mem" > stats.csv
while docker ps --format '{{.Names}}' | grep -q "${container}"; do
  ts=$(date +%s)
  out=$(docker stats --no-stream --format "{{.CPUPerc}},{{.MemPerc}}" ${container})
  cpu=$(echo $out | awk -F',' '{print $1}' | tr -d '%')
  mem=$(echo $out | awk -F',' '{print $2}' | tr -d '%')
  echo "${ts},${cpu},${mem}" >> stats.csv
  sleep 2
done
```

### Plot with Python

**File:** `tools/plot_stats.py`

```python
import pandas as pd
import matplotlib.pyplot as plt

df = pd.read_csv('stats.csv', names=['timestamp','cpu','mem'], header=0)
df['time'] = pd.to_datetime(df['timestamp'], unit='s')

plt.figure(figsize=(10,4))
plt.plot(df['time'], df['cpu'].astype(float), label='CPU%')
plt.ylabel('CPU%')
plt.legend()
plt.tight_layout()
plt.savefig('cpu_plot.png')

plt.figure(figsize=(10,4))
plt.plot(df['time'], df['mem'].astype(float), label='Mem%')
plt.ylabel('Memory %')
plt.legend()
plt.tight_layout()
plt.savefig('mem_plot.png')
```

**Install and Run:**

```bash
python3 -m pip install pandas matplotlib
python3 tools/plot_stats.py
```

**Interpretation:**
- CPU spikes indicate compute-heavy operations
- Sustained memory growth may indicate memory leaks
- Correlate with application activity

---

## Learning Path

### Week 1: Fundamentals

- [ ] Read Quick Start guide
- [ ] Complete `examples/basic/hello-world`
- [ ] Complete `examples/basic/alpine-base`
- [ ] Do Exercise 1: First Dockerfile

### Week 2: Applications

- [ ] Study Dockerfile best practices
- [ ] Work through `examples/web-apps/`
- [ ] Complete `node-app/` project
- [ ] Do Exercise 2: Multi-stage Build

### Week 3: Multi-container

- [ ] Read networking and volumes documentation
- [ ] Complete `compose/` project
- [ ] Work through `examples/multi-tier/`
- [ ] Do Exercise 3: Web App with Database

### Week 4: Advanced

- [ ] Complete `multi-stage/` project
- [ ] Explore `stacks/` and Swarm
- [ ] Practice monitoring and optimization
- [ ] Build your own application

### Suggested Learning Exercises

1. **Compose:** Add Redis password and test persistence
2. **Multi-stage:** Optimize Go server image size
3. **Node-app:** Add health check and non-root user
4. **Stacks:** Practice swarm deployment and rolling updates
5. **CI/CD:** Create GitHub Actions workflow for building and scanning

---

## Lab Session Reference

### Environment

```bash
docker --version
# Docker version 28.0.4, build b8034c0
```

### Node-app Lab Commands

```bash
cd node-app
docker build -t ddd:nodeweb1 .
# Build time: 22.5s

docker images
# REPOSITORY   TAG        IMAGE ID       CREATED          SIZE
# ddd          nodeweb1   cbcc3203b0b9   31 seconds ago   120MB

docker run -d --name web1 -p 8080:8080 ddd:nodeweb1
docker rm web1 -f
docker rmi ddd:nodeweb1
```

### Multi-stage Lab Commands

```bash
cd multi-stage
docker build -t multi:stage .
# Build time: 30.3s

docker history multi:stage
# IMAGE          SIZE      COMMENT
# 01e0fc5220eb   7.92MB    server binary
# <missing>      7.99MB    client binary

docker inspect multi:stage
# "Size": 9105460  (~9MB)
```

### Image Cleanup Example

```bash
# List dangling images
docker images -f "dangling=true"

# Find containers using image
docker ps -a --filter "ancestor=e2ad35612109"

# Stop and remove container
docker stop e70e949a061a
docker rm e70e949a061a

# Remove image
docker rmi e2ad35612109
# or force
docker rmi -f e2ad35612109
```

### Git Build Authentication Issue

```bash
# Building from private repo fails
docker build -t ddd:nodeweb https://github.com/rangasam/psweb.git#main
# ERROR: could not read Username for 'https://github.com'

# Workaround: Use public repo or build from local clone
```

---

## Git Workflow

### Quick Status

```bash
git status --porcelain
git branch --show-current
git remote -v
git log --oneline -n 5
```

### Stage and Commit

```bash
# Stage all changes
git add -A

# Commit with descriptive message
git commit -m "docs: update README with consolidated documentation"

# Push to GitHub
git push origin main

# Verify commit
git rev-parse --short HEAD
```

### Handling Nested Repositories

```bash
# Remove nested repo from index (keep files locally)
git rm --cached gsd
git commit -m "chore: remove embedded repo from index"
git push origin main

# Or add as proper submodule
git submodule add <url> gsd
git commit -m "chore: add gsd as submodule"
git push origin main
```

---

## Additional Resources

### Documentation

- **Official Docker Docs:** https://docs.docker.com/
- **Docker Hub:** https://hub.docker.com/
- **Course Slides:** `docker-deep-dive-2023/` folder

### Pre-built Images

- `rangasam/ddd:compose` - Compose example
- `rangasam/ddd:stack2023` - Stack example
- `rangasam/ddd:node-app` - Node.js app
- `rangasam/ddd:multi-stage-server` - Go multi-stage

### Tools

- **Trivy:** Image scanning - https://aquasecurity.github.io/trivy/
- **Hadolint:** Dockerfile linter
- **Docker Desktop:** Recommended development environment

### Getting Help

1. Check project-specific README files
2. Read documentation in `docs/` directory
3. Review exercise solutions
4. Search Docker documentation
5. Ask on Docker Community Forums: https://forums.docker.com/

---

## Repository Information

**Owner:** rangasam  
**Repository:** ddd  
**Branch:** main  
**Course:** Docker Deep Dive (Pluralsight 2023)

**Security Note:** GitHub has detected 5 vulnerabilities in dependencies (1 high, 3 moderate, 1 low). Check [Dependabot alerts](https://github.com/rangasam/ddd/security/dependabot) to address these.

---

**Ready to master Docker? Start with the [Quick Start](#quick-start) section!** 🐳
