# Exercise 3: Web App with Database

**Difficulty**: Intermediate  
**Time**: 30-40 minutes

## Objective

Learn to orchestrate multiple containers using Docker Compose and handle service dependencies.

## Task

Create a web application with:
1. Node.js REST API
2. PostgreSQL database
3. Redis cache
4. Proper networking and data persistence

## Requirements

### API Service
- CRUD endpoints for a simple todo list
- Connect to PostgreSQL for storage
- Use Redis for caching
- Health check endpoint

### Database Service
- PostgreSQL 15
- Persistent data storage
- Initialization script

### Cache Service
- Redis latest
- Optional persistence

### Docker Compose
- Define all services
- Custom network
- Named volumes
- Environment variables
- Service dependencies

## Project Structure

```
.
├── docker-compose.yml
├── api/
│   ├── Dockerfile
│   ├── package.json
│   └── index.js
└── db/
    └── init.sql
```

## API Endpoints

```
GET    /todos          - List all todos
POST   /todos          - Create todo
GET    /todos/:id      - Get todo by ID
PUT    /todos/:id      - Update todo
DELETE /todos/:id      - Delete todo
GET    /health         - Health check
```

## Expected Behavior

```bash
docker-compose up -d

# Create todo
curl -X POST http://localhost:3000/todos \
  -H "Content-Type: application/json" \
  -d '{"title":"Learn Docker","completed":false}'

# Get todos
curl http://localhost:3000/todos

# Health check
curl http://localhost:3000/health
```

## Validation

- [ ] All services start successfully
- [ ] API can connect to database
- [ ] API can connect to Redis
- [ ] Data persists after restart
- [ ] Health checks pass
- [ ] Services can communicate by name

## Hints

<details>
<summary>Hint 1: docker-compose.yml structure</summary>

```yaml
version: '3.8'

services:
  api:
    build: ./api
    ports:
      - "3000:3000"
    environment:
      - DB_HOST=db
      - REDIS_HOST=redis
    depends_on:
      db:
        condition: service_healthy
      redis:
        condition: service_started
    networks:
      - app-network

  db:
    image: postgres:15-alpine
    environment:
      - POSTGRES_DB=todos
      - POSTGRES_USER=user
      - POSTGRES_PASSWORD=password
    volumes:
      - postgres-data:/var/lib/postgresql/data
      - ./db/init.sql:/docker-entrypoint-initdb.d/init.sql
    healthcheck:
      test: ["CMD-SHELL", "pg_isready -U user"]
      interval: 5s
      timeout: 5s
      retries: 5
    networks:
      - app-network

  redis:
    image: redis:alpine
    networks:
      - app-network

volumes:
  postgres-data:

networks:
  app-network:
    driver: bridge
```
</details>

<details>
<summary>Hint 2: Database initialization script</summary>

```sql
CREATE TABLE IF NOT EXISTS todos (
    id SERIAL PRIMARY KEY,
    title VARCHAR(255) NOT NULL,
    completed BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
```
</details>

## Bonus Challenges

1. Add pgAdmin for database management
2. Implement Redis caching for GET requests
3. Add Docker healthchecks to API service
4. Create separate docker-compose files for dev/prod
5. Add Nginx as reverse proxy
6. Implement database migrations

## Testing

```bash
# Start services
docker-compose up -d

# Check status
docker-compose ps

# View logs
docker-compose logs -f api

# Test database connection
docker-compose exec db psql -U user -d todos -c "SELECT * FROM todos;"

# Test Redis connection
docker-compose exec redis redis-cli ping

# Stop services
docker-compose down

# Stop and remove data
docker-compose down -v
```

## What You Learned

- Docker Compose orchestration
- Multi-service applications
- Service dependencies
- Networking between containers
- Volume management
- Health checks
- Environment configuration
- Database initialization
