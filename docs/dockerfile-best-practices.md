# Dockerfile Best Practices

A comprehensive guide to writing efficient, secure, and maintainable Dockerfiles.

## 1. Use Specific Base Images

**Bad:**
```dockerfile
FROM node
```

**Good:**
```dockerfile
FROM node:18-alpine
```

**Why:** Specific versions ensure reproducibility. Alpine variants are smaller and more secure.

## 2. Minimize Layers

**Bad:**
```dockerfile
RUN apt-get update
RUN apt-get install -y curl
RUN apt-get install -y git
```

**Good:**
```dockerfile
RUN apt-get update && \
    apt-get install -y \
        curl \
        git \
    && rm -rf /var/lib/apt/lists/*
```

**Why:** Each RUN creates a new layer. Combining commands reduces image size.

## 3. Order Instructions by Change Frequency

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

**Why:** Docker caches layers. Place rarely changing instructions first.

## 4. Use Multi-stage Builds

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

**Why:** Smaller final images, no build dependencies in production.

## 5. Use .dockerignore

Create `.dockerignore` file:
```
node_modules
.git
.env
*.log
```

**Why:** Faster builds, smaller context, better security.

## 6. Run as Non-root User

```dockerfile
RUN adduser -D -u 1000 appuser
USER appuser
```

**Why:** Security - limit damage if container is compromised.

## 7. Use HEALTHCHECK

```dockerfile
HEALTHCHECK --interval=30s --timeout=3s \
  CMD curl -f http://localhost/ || exit 1
```

**Why:** Docker can monitor and restart unhealthy containers.

## 8. Clean Up in the Same Layer

**Bad:**
```dockerfile
RUN apt-get update
RUN apt-get install -y package
RUN apt-get clean
```

**Good:**
```dockerfile
RUN apt-get update && \
    apt-get install -y package && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*
```

**Why:** Cleaning in same layer reduces final image size.

## 9. Use COPY Instead of ADD

**Good:**
```dockerfile
COPY app.js .
```

**Bad (unless you need ADD features):**
```dockerfile
ADD app.js .
```

**Why:** COPY is more transparent. ADD has implicit behavior (tar extraction, URL downloads).

## 10. Pin Package Versions

**Bad:**
```
express
```

**Good:**
```
express@4.18.2
```

**Why:** Reproducible builds, avoid unexpected changes.

## Complete Example

```dockerfile
# Use specific version
FROM node:18-alpine AS builder

# Set working directory
WORKDIR /app

# Copy dependency files first
COPY package*.json ./

# Install dependencies
RUN npm ci --only=production

# Production stage
FROM node:18-alpine

# Install security updates
RUN apk update && apk upgrade && rm -rf /var/cache/apk/*

WORKDIR /app

# Copy from builder
COPY --from=builder /app/node_modules ./node_modules
COPY --from=builder /app/package*.json ./

# Copy application
COPY . .

# Create non-root user
RUN addgroup -g 1001 -S nodejs && \
    adduser -S nodejs -u 1001 && \
    chown -R nodejs:nodejs /app

# Switch to non-root user
USER nodejs

# Expose port
EXPOSE 3000

# Health check
HEALTHCHECK --interval=30s --timeout=3s \
  CMD node -e "require('http').get('http://localhost:3000/health', (r) => process.exit(r.statusCode === 200 ? 0 : 1))"

# Start application
CMD ["node", "index.js"]
```

## Checklist

- [ ] Use specific base image versions
- [ ] Combine RUN commands to reduce layers
- [ ] Order instructions by change frequency
- [ ] Use multi-stage builds for smaller images
- [ ] Include .dockerignore file
- [ ] Run as non-root user
- [ ] Add health checks
- [ ] Clean up in same layer
- [ ] Use COPY over ADD
- [ ] Pin dependency versions
- [ ] Document exposed ports
- [ ] Use meaningful tags
