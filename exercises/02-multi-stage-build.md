# Exercise 2: Multi-stage Build

**Difficulty**: Beginner  
**Time**: 20-30 minutes

## Objective

Learn to use multi-stage builds to create smaller, more efficient Docker images.

## Task

Create a Node.js application that:
1. Uses TypeScript for development
2. Compiles to JavaScript for production
3. Uses multi-stage build to separate build and runtime
4. Results in a small production image

## Requirements

1. Create a simple TypeScript Express app
2. Use multi-stage Dockerfile with:
   - Build stage: Compile TypeScript
   - Production stage: Run compiled JavaScript
3. Production image should only contain:
   - Node runtime
   - Compiled JavaScript
   - Production dependencies
4. Final image should be < 150MB

## Project Structure

```
.
├── Dockerfile
├── package.json
├── tsconfig.json
└── src/
    └── index.ts
```

## Expected Behavior

```bash
docker build -t typescript-app .
docker run -p 3000:3000 typescript-app
curl http://localhost:3000
# Output: {"message": "Hello from TypeScript!"}
```

## Validation

- [ ] Build completes successfully
- [ ] TypeScript compiles without errors
- [ ] Production image doesn't contain TypeScript files
- [ ] Production image doesn't contain dev dependencies
- [ ] Image size < 150MB
- [ ] Application runs correctly

## Hints

<details>
<summary>Hint 1: Multi-stage Dockerfile pattern</summary>

```dockerfile
# Build stage
FROM node:18 AS builder
WORKDIR /app
COPY package*.json tsconfig.json ./
RUN npm install
COPY src ./src
RUN npm run build

# Production stage
FROM node:18-alpine
WORKDIR /app
COPY --from=builder /app/dist ./dist
COPY package*.json ./
RUN npm ci --only=production
CMD ["node", "dist/index.js"]
```
</details>

<details>
<summary>Hint 2: TypeScript config</summary>

```json
{
  "compilerOptions": {
    "target": "ES2020",
    "module": "commonjs",
    "outDir": "./dist",
    "rootDir": "./src",
    "strict": true
  }
}
```
</details>

## Bonus Challenges

1. Compare image sizes with and without multi-stage build
2. Use different base images (alpine, slim, distroless)
3. Add source maps for better debugging
4. Implement health check endpoint
5. Add build arguments for environment configuration

## What You Learned

- Multi-stage builds
- Separating build and runtime dependencies
- Optimizing image size
- TypeScript compilation in Docker
- Best practices for production images

## Comparison

After completing the exercise, compare:

```bash
# Single-stage build
docker images typescript-app:single
# Expected: ~1GB

# Multi-stage build
docker images typescript-app:multi
# Expected: ~150MB

# Size difference
# Savings: ~85%!
```
