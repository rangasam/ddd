# Python Flask App

A minimal Flask application demonstrating Docker containerization for Python web apps.

## Features

- Flask web framework
- RESTful API endpoints
- Health check endpoint
- Environment variable support
- Non-root user execution

## Build and Run

```bash
# Build the image
docker build -t python-flask-app .

# Run the container
docker run -p 5000:5000 python-flask-app

# Run with environment variable
docker run -p 5000:5000 -e FLASK_ENV=production python-flask-app

# Run in background
docker run -d -p 5000:5000 --name flask-app python-flask-app
```

## Test the Application

```bash
# Access the app
curl http://localhost:5000

# Check health
curl http://localhost:5000/health

# View logs
docker logs flask-app
```

## Expected Response

```json
{
  "message": "Hello from Dockerized Flask app!",
  "timestamp": "2026-01-04T17:43:00.123456",
  "environment": "development",
  "hostname": "abc123def456"
}
```

## Learning Points

### Python Containerization

- **python:3.11-slim**: Smaller than full Python image
- **pip --no-cache-dir**: Don't store pip cache (smaller image)
- **requirements.txt first**: Leverages Docker layer caching

### Layer Caching

The order of COPY commands matters:
1. Copy requirements.txt first
2. Install dependencies (cached if requirements don't change)
3. Copy application code last (changes frequently)

### Best Practices

- ✅ Slim Python image (smaller size)
- ✅ Non-root user (security)
- ✅ Optimized layer caching
- ✅ Health checks included
- ✅ No pip cache (smaller image)

## Development Mode

For development with live reload:

```bash
# Run with volume mount
docker run -p 5000:5000 -v $(pwd):/app \
  -e FLASK_ENV=development \
  python:3.11-slim \
  sh -c "pip install Flask && python /app/app.py"
```
