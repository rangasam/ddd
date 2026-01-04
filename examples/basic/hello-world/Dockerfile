# Use a minimal base image
FROM alpine:3.19

# Set working directory
WORKDIR /app

# Create a simple script
RUN echo '#!/bin/sh' > hello.sh && \
    echo 'echo "Hello from Docker!"' >> hello.sh && \
    echo 'echo "Container ID: $(hostname)"' >> hello.sh && \
    echo 'echo "Current time: $(date)"' >> hello.sh && \
    chmod +x hello.sh

# Run the script when container starts
CMD ["./hello.sh"]
