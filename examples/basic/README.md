# Basic Docker Examples

This directory contains fundamental Docker examples to get started with containerization.

## Examples

### 1. Hello World Container

A simple example demonstrating the most basic Docker container.

```bash
cd hello-world
docker build -t hello-world .
docker run hello-world
```

### 2. Alpine Linux Base

Learn about minimal Docker images using Alpine Linux.

```bash
cd alpine-base
docker build -t alpine-example .
docker run -it alpine-example
```

## Key Concepts

- **Docker Images**: Read-only templates used to create containers
- **Docker Containers**: Running instances of Docker images
- **Dockerfile**: Text file containing instructions to build a Docker image
- **Docker Build**: Process of creating an image from a Dockerfile
- **Docker Run**: Command to create and start a container from an image

## Best Practices

1. Use specific base image tags (avoid `latest`)
2. Minimize the number of layers
3. Clean up unnecessary files in the same layer
4. Use `.dockerignore` to exclude unnecessary files
