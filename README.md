# Docker Deep Dive — Project Guide

This repository contains practical examples and labs that accompany the Docker Deep Dive training material. The README below consolidates the per-project guidance, step-by-step instructions, prerequisites, safety guardrails, troubleshooting steps, monitoring/plotting examples, and suggested exercises.

Folders covered: `compose/`, `multi-stage/`, `node-app/`, `stacks/`, `stackv2-app/`, and related helper tools in `tools/`.

---

## Quick prerequisites

- macOS (zsh) or any OS with Docker Desktop / Docker Engine installed.

- Docker Desktop (recommended) or Docker Engine + Compose v2. Ensure Docker daemon running.

- docker CLI and docker compose available: `docker --version` and `docker compose version`.

- Python 3.8+ with pip for optional plotting (packages: `pandas`, `matplotlib`).

- Go 1.18+ for `multi-stage` if you want to build/run Go code.

- Node.js for `node-app` local development (optional).

Optional security tooling

- Trivy: image scanning (https://aquasecurity.github.io/trivy/)

- Hadolint: Dockerfile linter

---

## How to use this reference

- Follow the per-project quick start to build and run services.

- Read the Safety & Guardrails section before exposing services publicly.

- Use the Troubleshooting section for common errors and quick fixes.

- Use the Monitoring & Plots section to collect runtime metrics and visualize resource usage.

---

## Project: `compose/` — Compose / multi-container basics

Purpose

- Demonstrate multi-container applications using Docker Compose (Python + Redis example).

Files

- `compose/compose.yaml` — Compose definition

- `compose/Dockerfile` and `compose/app/` — Python Flask app and Dockerfile

Quick start

```zsh
cd compose
# Build and run in foreground (good for debugging)
docker compose up --build
# Or run detached
docker compose up --build --detach
# See logs
docker compose logs -f
# Stop and remove
docker compose down --volumes --remove-orphans
```

Notes

- Default ports: check `compose/compose.yaml` or `compose/app/app.py` for the web port.

- Use `.env` for environment variables if you need to change credentials or ports.

Step-by-step implementation ideas

1. Add a healthcheck to the web service in `compose.yaml` (improves orchestration readiness).

2. Add a named volume and test data persistence across `docker compose down` and `up`.

3. Add a Redis password via environment variable and mount a `.env` file (do not commit secrets).

Development tips

- Modify `compose/app/` Python code and rebuild with `docker compose up --build`.

- For faster iteration use a bind mount: in development, mount source into the container instead of copying in the Dockerfile.

---

## Project: `multi-stage/` — Multi-stage builds (Go server/client)

Purpose

- Show how to use multi-stage Docker builds to produce small production images.

Files

- `multi-stage/Dockerfile` — multi-stage build that compiles Go and copies binary into minimal image

- `cmd/` — example client/server Go code

Quick start

```zsh
cd multi-stage
# Build with Docker
docker build -t rangasam/ddd:multi-stage-server -f Dockerfile .
# Run the service
docker run --rm -p 8080:8080 rangasam/ddd:multi-stage-server
```

Notes and tips

- Confirm a `COPY --from=builder` exists in final stage.

- For faster local iteration, use `go build` locally and mount the binary into an image for testing.

- Prefer `scratch` or distroless images for the final stage to reduce surface area.

Exercise

- Add debug instrumentation to the server endpoint and observe memory/CPU under load.

---

## Project: `node-app/` — Node.js example

Purpose

- Containerize a Node.js web app and demonstrate Dockerfile best practices.

Files

- `node-app/Dockerfile`, `node-app/app.js`, `node-app/package.json`

Quick start

```zsh
cd node-app
docker build -t rangasam/ddd:node-app .
docker run --rm -p 3000:3000 rangasam/ddd:node-app
```

Best practices to implement

- Add a `.dockerignore` excluding `node_modules` and dev files

- Use a specific, minimal Node base image (e.g., `node:18-alpine`)

- Create a non-root user in the Dockerfile and run the process as that user

- Add a `HEALTHCHECK` to the Dockerfile

Exercise

- Add a Redis cache and modify the app to use it; run with Compose by creating a `docker-compose.yaml` or adding to the `compose` project.

---

## Project: `stacks/` and `stackv2-app/` — Stack examples & Swarm notes

Purpose

- Demonstrate stack files and swarm-specific options (deploy, replicas, placement).

Files

- `stacks/compose.yaml` (stack-mode) with `deploy` instructions

- `stackv2-app/` example app variation

Quick start (Compose local)

```zsh
# For local compose testing
docker compose -f stacks/compose.yaml up --build
```

Using Docker Swarm (advanced)

```zsh
# Initialize swarm
docker swarm init
# Deploy stack to swarm
docker stack deploy -c stacks/compose.yaml mystack
# List stacks and services
docker stack ls
docker stack services mystack
# Teardown
docker stack rm mystack
docker swarm leave --force
```

Caution

- Swarm mode modifies docker state (nodes, networks); don't run on production nodes unintentionally.

---

## Cross-cutting: healthchecks, resource limits, networking, and volumes

- Add `healthcheck` to Dockerfile or Compose to allow orchestrators to detect unhealthy containers.

- Use resource limits where possible for local testing:

  - `docker run --memory=512m --cpus=0.5 ...`

  - Compose `deploy` section is used by swarm; plain `docker compose up` ignores `deploy` limits.

- Prefer named volumes for stateful services and bind mounts only for dev convenience.

Example Compose snippet

```yaml
services:
  web:
    image: rangasam/ddd:node-app
    deploy:
      resources:
        limits:
          cpus: '0.50'
          memory: 512M
    healthcheck:
      test: ["CMD-SHELL", "curl -f <http://localhost:3000> || exit 1"]
      interval: 30s
      timeout: 10s
      retries: 3
```

---

## Safety & guardrails

1. Secrets & credentials

   - Never commit API keys or `.env` files. Use Docker secrets (swarm) or an external secrets manager.

2. Image scanning

   - Scan with Trivy: `trivy image <image>`

3. Least privilege

   - Run processes as non-root user in images.

4. Network exposure

   - Prefer `127.0.0.1` for local-only services; avoid binding to `0.0.0.0` if not needed.

5. Clean up resources

   - Use `docker system prune --all --volumes` carefully to remove unused resources.

---

## Troubleshooting quick reference

- Build errors: verify Dockerfile paths and build context. Use `docker build -f path/to/Dockerfile .`.

- Port conflicts: `lsof -i :<port>` to find host process.

- Compose no such service: run `docker compose` from folder with compose file or pass `-f`.

- Permission issues: check file ownership; set proper `chown` in Dockerfile or use `--user`.

- Mount slowness on macOS: reduce bind mounts or use cached mounts in Docker Desktop.

---

## Monitoring & plotting example

Collect `docker stats` into CSV and plot CPU/MEM over time using Python.

Collector example (bash):

```zsh
container=compose_web_1
echo "timestamp,cpu,mem" > stats.csv
while docker ps --format '{{.Names}}' | grep -q "${container}"; do
  ts=$(date +%s)
  out=$(docker stats --no-stream --format "{{.CPUPerc}},{{.MemPerc}}" ${container})
  cpu=$(echo $out | awk -F',' '{print $1}' | tr -d '%')
  mem=$(echo $out | awk -F',' '{print $2}' | tr -d '%')
  echo "${ts},${cpu},${mem}" >> stats.csv
  sleep 2
done
```

Plot example (`tools/plot_stats.py`):

```python
import pandas as pd
import matplotlib.pyplot as plt

df = pd.read_csv('stats.csv', names=['timestamp','cpu','mem'], header=0)
df['time'] = pd.to_datetime(df['timestamp'], unit='s')

plt.figure(figsize=(10,4))
plt.plot(df['time'], df['cpu'].astype(float), label='CPU%')
plt.ylabel('CPU%')
plt.legend()
plt.tight_layout()
plt.savefig('cpu_plot.png')

plt.figure(figsize=(10,4))
plt.plot(df['time'], df['mem'].astype(float), label='Mem%')
plt.ylabel('Memory %')
plt.legend()
plt.tight_layout()
plt.savefig('mem_plot.png')
```

Install dependencies and run:

```zsh
python3 -m pip install pandas matplotlib
python3 tools/plot_stats.py
```

Interpretation tips

- Correlate spikes with app activity (requests); CPU bursts indicate compute-heavy work; sustained memory growth can indicate leaks.

---

## Suggested exercises (learning path)

- Compose: add Redis and update Python app to persist data and handle failures.

- Multi-stage: modify Go server and verify final image size remains small.

- Node-app: add a `HEALTHCHECK` and non-root user; use Trivy for scanning.

- Stacks: test swarm deploy on a local VM and practice rolling updates.

- CI/CD: add a GitHub Actions job to build, lint Dockerfiles (hadolint), and scan images (Trivy).

---

## Files created by tooling

- `PROJECT-GUIDE.md` — project guide draft

- `Docker-Deep-Dive-Project-Guide.md` — earlier guide copy

- `tools/command_logger.zsh` and `tools/generate_lab_docs.py` — helper tools to capture terminal commands and generate per-folder docs

---

## Where to get more info

See the attached slide PDFs under `docker-deep-dive-2023/` for the course material (architecture, images, multi-stage builds, networking, volumes, Compose, and production practices).

---

If you'd like, I can:

- Run markdown lint and fix style issues (blank lines, headings) before committing.

- Push this merged README to `main` and resolve the previous merge differences.

- Create per-folder READMEs with exact port numbers and sample responses.

Tell me which of the above actions you want me to do next.
