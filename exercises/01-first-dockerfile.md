# Exercise 1: Create Your First Dockerfile

**Difficulty**: Beginner  
**Time**: 15-20 minutes

## Objective

Learn to create a basic Dockerfile and understand fundamental Docker instructions.

## Task

Create a Docker image that:
1. Uses Python 3.11 as the base image
2. Installs the `requests` library
3. Runs a script that fetches a URL and prints the status code

## Requirements

1. Create a `Dockerfile`
2. Create a Python script `fetch.py` that:
   - Takes a URL as an environment variable
   - Makes an HTTP request to that URL
   - Prints the status code and response time
3. The container should run as a non-root user
4. Use proper layer caching (copy requirements before code)

## Expected Behavior

```bash
docker build -t url-fetcher .
docker run -e URL=https://example.com url-fetcher
# Output: Status: 200, Time: 0.234s
```

## Validation

- [ ] Image builds successfully
- [ ] Container runs without errors
- [ ] Can fetch different URLs via environment variable
- [ ] Runs as non-root user
- [ ] Image size is reasonable (< 200MB)

## Hints

<details>
<summary>Hint 1: Python script structure</summary>

```python
import os
import requests
import time

url = os.getenv('URL', 'https://example.com')
start = time.time()
response = requests.get(url)
elapsed = time.time() - start
print(f"Status: {response.status_code}, Time: {elapsed:.3f}s")
```
</details>

<details>
<summary>Hint 2: Dockerfile structure</summary>

```dockerfile
FROM python:3.11-slim

# Install dependencies first (for caching)
COPY requirements.txt .
RUN pip install -r requirements.txt

# Copy application code
COPY fetch.py .

# Create non-root user
RUN useradd -m appuser
USER appuser

# Set default URL
ENV URL=https://example.com

CMD ["python", "fetch.py"]
```
</details>

## Bonus Challenges

1. Add error handling for invalid URLs
2. Add timeout configuration via environment variable
3. Make the script retry on failure
4. Use Alpine Python base image instead of slim

## Solution

Check the `solution/` directory for a complete implementation.

## What You Learned

- Creating a Dockerfile from scratch
- Using environment variables
- Layer caching optimization
- Running as non-root user
- Building and running containers
