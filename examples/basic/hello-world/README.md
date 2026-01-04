# Hello World Docker Example

The simplest Docker example to demonstrate containerization.

## What This Does

This Dockerfile creates a container that:
- Uses Alpine Linux (a minimal Linux distribution)
- Creates a simple shell script
- Prints a greeting message with container information

## Build and Run

```bash
# Build the image
docker build -t hello-world .

# Run the container
docker run hello-world

# Run with custom name
docker run --name my-hello hello-world

# Run interactively
docker run -it hello-world sh
```

## Expected Output

```
Hello from Docker!
Container ID: abc123def456
Current time: Sat Jan 4 12:00:00 UTC 2026
```

## Learning Points

- **FROM**: Specifies the base image (Alpine Linux 3.19)
- **WORKDIR**: Sets the working directory inside the container
- **RUN**: Executes commands during image build
- **CMD**: Specifies the default command when container starts
- **Layer Caching**: Each instruction creates a new layer

## Exploring Further

Try these commands to learn more:

```bash
# View image details
docker images hello-world

# Inspect the image
docker inspect hello-world

# View image layers
docker history hello-world

# Remove the image
docker rmi hello-world
```
