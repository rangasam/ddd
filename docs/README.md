# Docker Concepts Documentation

This directory contains educational resources for learning Docker concepts.

## Documentation Files

- **dockerfile-best-practices.md**: Writing efficient and secure Dockerfiles
- **networking.md**: Understanding Docker networking
- **volumes.md**: Data persistence and management
- **terminal-prompt-configuration.md**: Configure terminal prompt to show only current directory name

## Learning Path

1. Start with basic concepts (images, containers, Dockerfile)
2. Practice with examples in `/examples/basic`
3. Learn about web applications in `/examples/web-apps`
4. Master multi-container apps in `/examples/multi-tier`
5. Deep dive into specific topics with these documentation files

## Quick Reference

### Essential Commands

```bash
# Images
docker images                    # List images
docker build -t name .          # Build image
docker rmi image-name           # Remove image
docker pull image-name          # Download image

# Containers
docker ps                       # List running containers
docker ps -a                    # List all containers
docker run image-name           # Run container
docker stop container-id        # Stop container
docker rm container-id          # Remove container
docker logs container-id        # View logs

# Cleanup
docker system prune             # Remove unused data
docker system prune -a          # Remove all unused data
docker volume prune             # Remove unused volumes
```

### Docker Compose Commands

```bash
docker-compose up               # Start services
docker-compose up -d            # Start in background
docker-compose down             # Stop services
docker-compose ps               # List services
docker-compose logs             # View logs
docker-compose build            # Build images
```
