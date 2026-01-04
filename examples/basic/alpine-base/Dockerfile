# Use Alpine Linux as base
FROM alpine:3.19

# Install some useful tools
RUN apk add --no-cache \
    bash \
    curl \
    wget \
    vim

# Create a user (security best practice)
RUN adduser -D -u 1000 dockeruser

# Switch to non-root user
USER dockeruser

# Set working directory
WORKDIR /home/dockeruser

# Default command - start bash shell
CMD ["/bin/bash"]
