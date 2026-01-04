# Web Application Examples

This directory contains Docker examples for containerizing web applications.

## Examples

### 1. Simple Node.js App

A basic Express.js application demonstrating web app containerization.

### 2. Python Flask App

A minimal Flask application showing Python web app deployment.

## Key Concepts

- **Port Mapping**: Exposing container ports to the host
- **EXPOSE**: Documenting which ports the app uses
- **Environment Variables**: Configuring apps in containers
- **Multi-stage Builds**: Creating smaller production images
- **Health Checks**: Monitoring container health

## Running Web Apps

```bash
# Build the image
docker build -t myapp .

# Run with port mapping
docker run -p 3000:3000 myapp

# Run in background (detached)
docker run -d -p 3000:3000 myapp

# View logs
docker logs <container-id>

# Stop container
docker stop <container-id>
```
