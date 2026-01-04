# Alpine Linux Base Example

Learn about minimal Docker images and package management.

## What This Does

This Dockerfile demonstrates:
- Using Alpine Linux (only ~5MB base image)
- Installing packages with `apk` (Alpine Package Keeper)
- Creating a non-root user for security
- Setting up a working directory

## Build and Run

```bash
# Build the image
docker build -t alpine-example .

# Run interactively
docker run -it alpine-example

# Run with mounted volume
docker run -it -v $(pwd):/data alpine-example
```

## Inside the Container

Once inside, try these commands:

```bash
# Check OS version
cat /etc/os-release

# Check installed packages
apk info

# Install additional package
apk add git

# Check current user
whoami
id
```

## Learning Points

- **Alpine Linux**: Minimal Linux distribution perfect for containers
- **apk**: Alpine's package manager (like apt or yum)
- **--no-cache**: Don't store package cache (keeps image smaller)
- **USER**: Run container as non-root user (security)
- **Multi-line RUN**: Use `\` for readability, `&&` to chain commands

## Size Comparison

```bash
# Check image size
docker images alpine-example

# Compare with Ubuntu
docker pull ubuntu:22.04
docker images ubuntu
```

Alpine is typically 10-20x smaller than Ubuntu!

## Best Practices Demonstrated

1. ✅ Use minimal base images
2. ✅ Combine RUN commands to reduce layers
3. ✅ Use --no-cache to keep images small
4. ✅ Run as non-root user
5. ✅ Clean and organized Dockerfile structure
