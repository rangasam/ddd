# Simple Node.js App

A basic Express.js application demonstrating Docker best practices for web applications.

## Features

- Express.js web server
- Health check endpoint
- Environment variable configuration
- Multi-stage build
- Non-root user execution
- Health checks

## Build and Run

```bash
# Build the image
docker build -t simple-node-app .

# Run the container
docker run -p 3000:3000 simple-node-app

# Run with environment variable
docker run -p 3000:3000 -e NODE_ENV=production simple-node-app

# Run in background
docker run -d -p 3000:3000 --name node-app simple-node-app
```

## Test the Application

```bash
# Access the app
curl http://localhost:3000

# Check health endpoint
curl http://localhost:3000/health

# View logs
docker logs node-app

# Check health status
docker inspect --format='{{.State.Health.Status}}' node-app
```

## Expected Response

```json
{
  "message": "Hello from Dockerized Node.js app!",
  "timestamp": "2026-01-04T17:43:00.000Z",
  "environment": "development",
  "hostname": "abc123def456"
}
```

## Learning Points

### Multi-stage Builds

The Dockerfile uses two stages:
1. **Builder stage**: Installs dependencies
2. **Production stage**: Copies only what's needed

Benefits:
- Smaller final image (no build tools)
- Faster builds (cached layers)
- More secure (fewer attack surfaces)

### Security Best Practices

- ✅ Non-root user (nodejs)
- ✅ Minimal base image (Alpine)
- ✅ Production dependencies only
- ✅ Health checks enabled

### Docker Commands Explained

- `COPY --from=builder`: Copy files from previous stage
- `EXPOSE 3000`: Document the port (doesn't actually publish)
- `HEALTHCHECK`: Docker monitors container health
- `USER nodejs`: Run as non-root user

## Advanced Usage

```bash
# Build with custom tag
docker build -t simple-node-app:v1.0 .

# Run with resource limits
docker run -p 3000:3000 --memory="256m" --cpus="0.5" simple-node-app

# Mount code for development
docker run -p 3000:3000 -v $(pwd):/app node:18-alpine node /app/app.js
```
