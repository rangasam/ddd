# Quick Start Guide

Get started with Docker Deep Dive in 5 minutes!

## Prerequisites

1. **Install Docker**
   - [Docker Desktop](https://www.docker.com/products/docker-desktop) (Mac/Windows)
   - [Docker Engine](https://docs.docker.com/engine/install/) (Linux)

2. **Verify Installation**
   ```bash
   docker --version
   docker-compose --version
   ```

## Your First Container

Let's run your first Docker container!

### Step 1: Hello World

```bash
cd examples/basic/hello-world
docker build -t hello-world .
docker run hello-world
```

**Expected Output:**
```
Hello from Docker!
Container ID: abc123def456
Current time: Sun Jan  4 17:43:00 UTC 2026
```

### Step 2: Interactive Container

```bash
cd ../alpine-base
docker build -t alpine-example .
docker run -it alpine-example
```

You're now inside a container! Try:
```bash
whoami
cat /etc/os-release
exit
```

### Step 3: Web Application

```bash
cd ../../web-apps/simple-node-app
docker build -t simple-node-app .
docker run -d -p 3000:3000 --name node-app simple-node-app
```

Open your browser to `http://localhost:3000` or:
```bash
curl http://localhost:3000
```

Stop the container:
```bash
docker stop node-app
docker rm node-app
```

### Step 4: Multi-container Application

```bash
cd ../../multi-tier/web-db-stack
docker-compose up -d
curl http://localhost:3000
docker-compose down
```

## Learning Path

Now that you've run your first containers, follow this path:

### Week 1: Fundamentals
- [ ] Read `docs/README.md`
- [ ] Complete all examples in `examples/basic/`
- [ ] Do Exercise 1: First Dockerfile

### Week 2: Applications
- [ ] Study `docs/dockerfile-best-practices.md`
- [ ] Work through `examples/web-apps/`
- [ ] Do Exercise 2: Multi-stage Build

### Week 3: Advanced
- [ ] Read `docs/networking.md` and `docs/volumes.md`
- [ ] Practice with `examples/multi-tier/`
- [ ] Do Exercise 3: Web App with Database

### Week 4: Mastery
- [ ] Explore all documentation
- [ ] Build your own application
- [ ] Experiment with optimizations

## Essential Commands

### Images
```bash
docker images                  # List all images
docker build -t name:tag .     # Build image
docker rmi image-name          # Remove image
docker pull image-name         # Download image
```

### Containers
```bash
docker ps                      # Running containers
docker ps -a                   # All containers
docker run image-name          # Run container
docker run -d image-name       # Run in background
docker run -it image-name sh   # Interactive shell
docker stop container-id       # Stop container
docker rm container-id         # Remove container
docker logs container-id       # View logs
```

### Docker Compose
```bash
docker-compose up              # Start services
docker-compose up -d           # Start in background
docker-compose down            # Stop services
docker-compose ps              # List services
docker-compose logs            # View logs
```

### Cleanup
```bash
docker system prune            # Remove unused data
docker system prune -a         # Remove all unused
docker volume prune            # Remove unused volumes
```

## Common Issues

### Port Already in Use
```bash
# Find process using port
lsof -i :3000
# or
netstat -tuln | grep 3000

# Use different port
docker run -p 8080:3000 myapp
```

### Permission Denied
```bash
# Add user to docker group (Linux)
sudo usermod -aG docker $USER
# Log out and back in
```

### Container Exits Immediately
```bash
# View logs
docker logs container-name

# Run interactively to debug
docker run -it image-name sh
```

## Next Steps

1. **Pick an Example**: Start with `examples/basic/hello-world`
2. **Read the README**: Each example has detailed instructions
3. **Modify and Experiment**: Change code and rebuild
4. **Do the Exercises**: Apply what you learned
5. **Build Something**: Create your own Dockerized app

## Resources

- **Official Docker Docs**: https://docs.docker.com/
- **Docker Hub**: https://hub.docker.com/
- **Best Practices**: `docs/dockerfile-best-practices.md`
- **Troubleshooting**: Check logs with `docker logs`

## Getting Help

1. Check the README in each example directory
2. Read the documentation in `docs/`
3. Look at the solutions in `exercises/`
4. Search [Docker documentation](https://docs.docker.com/)
5. Ask on [Docker Community Forums](https://forums.docker.com/)

---

**Ready to dive deep into Docker? Start with `examples/basic/hello-world`!** 🐳
