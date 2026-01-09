# Docker Deep Dive — Project Guide

This guide maps the repository project folders to Docker Deep Dive concepts and provides step-by-step instructions, prerequisites, safety guardrails, troubleshooting, and optional monitoring/plotting instructions. It is written to be runnable on macOS (zsh).

Folders covered: `compose/`, `multi-stage/`, `node-app/`, `stacks/`, `stackv2-app/` and related files.

---

## Quick prerequisites

- macOS (tested on recent macOS versions)
- Docker Desktop (recommended) or Docker Engine + Compose v2. Ensure Docker daemon running.
- docker CLI and docker compose available: `docker --version` and `docker compose version`.
- Python 3.8+ with pip for optional plotting (packages: `pandas`, `matplotlib`).
- Go 1.18+ for `multi-stage` if you want to build/run Go code.
- Node.js (optional) for `node-app` local development.

Optional security tooling
- Trivy: image scanning (https://aquasecurity.github.io/trivy/)
- Hadolint: Dockerfile linter

---

## How this guide is organized

- Per-project quick start (build, run, stop)
- Step-by-step implementation notes (what to edit for exercises)
- Safety guardrails and least-privilege advice
- Troubleshooting checklist (common errors and quick fixes)
- Monitoring & plotting (collect `docker stats` and generate simple plots)
- Suggested exercises and next steps

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

Common changes when iterating
- Modify `compose/app/` Python code, rebuild with `docker compose up --build`.
- Use bind mounts for quick dev iteration: replace COPY in Dockerfile with a mount during development.

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
docker build -t ddd/multi-stage-server:latest -f Dockerfile .
# Run the service
docker run --rm -p 8080:8080 ddd/multi-stage-server:latest
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
- Containerize a Node.js web app and show Dockerfile best practices.

Files
- `node-app/Dockerfile`, `node-app/app.js`, `node-app/package.json`

Quick start

```zsh
cd node-app
docker build -t ddd/node-app:latest .
docker run --rm -p 3000:3000 ddd/node-app:latest
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
    image: ddd/node-app:latest
    deploy:
      resources:
        limits:
          cpus: '0.50'
          memory: 512M
    healthcheck:
      test: ["CMD-SHELL", "curl -f http://localhost:3000 || exit 1"]
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

This repository contains a simple logger and generator (see `tools/`). Below is a small collector and plot workflow.

1) Collect `docker stats` into CSV (example collector)

```zsh
container=compose_web_1
echo "timestamp,cpu,mem_percent" > stats.csv
while docker ps --format '{{.Names}}' | grep -q "${container}"; do
  ts=$(date +%s)
  out=$(docker stats --no-stream --format "{{.CPUPerc}},{{.MemPerc}}" ${container})
  cpu=$(echo $out | awk -F',' '{print $1}' | tr -d '%')
  mem=$(echo $out | awk -F',' '{print $2}' | tr -d '%')
  echo "${ts},${cpu},${mem}" >> stats.csv
  sleep 2
done
```

2) Plot with Python (`tools/plot_stats.py`)

Save a script like this to `tools/plot_stats.py`:

```python
import pandas as pd
import matplotlib.pyplot as plt

df = pd.read_csv('stats.csv', names=['timestamp','cpu','mem'], header=0)
df['time'] = pd.to_datetime(df['timestamp'], unit='s')

plt.figure()
plt.plot(df['time'], df['cpu'].astype(float), label='CPU%')
plt.legend()
plt.savefig('cpu_plot.png')

plt.figure()
plt.plot(df['time'], df['mem'].astype(float), label='Mem%')
plt.legend()
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
- Node-app: add a `HEALTHCHECK` and non-root user; use `docker scan` or Trivy.
- Stacks: test swarm deploy on a local VM and practice upgrade strategies (`update_config`).
- CI/CD: add GitHub Actions job to build, lint Dockerfiles (hadolint), and scan images (Trivy).

---

## Files added by this guide

- `PROJECT-GUIDE.md` (this file)
- `tools/command_logger.zsh` and `tools/generate_lab_docs.py` (optional helper tools)

---

## Where to get more info

The attached slides in `docker-deep-dive-2023/` folders contain deep dives on architecture, images, multi-stage builds, networking, volumes, Compose, and production practices. Use them as a reference while doing the hands-on labs in this repo.

---

## Lab session artifacts (session commands & outputs)

A separate file with concrete commands and trimmed outputs from the interactive lab session has been added to this repository as `PROJECT-LAB-SESSION.md`. It contains the exact build/run/inspect examples and image-cleanup steps captured during the session (including the git-build auth failure example and the dangling image removal flow). Use that as a quick copy/paste reference while performing the labs.

Path: `PROJECT-LAB-SESSION.md`

If you prefer, I can merge the most important snippets from `PROJECT-LAB-SESSION.md` directly into the per-project sections above (node-app and multi-stage) so the master guide is fully self-contained. Say "merge lab outputs into guide" and I'll integrate and update the todo list.

If you want, I can:
- Merge this guide into the main `README.md` (resolving the existing conflict by preferring this content).
- Add the plotting scripts (`tools/plot_stats.py`) and the collector script and test them.
- Create per-folder small README walkthroughs with exact ports and sample responses.

Generated: 2026-01-04

---

## Git / GitHub quick reference (common update workflow)

These are the common commands used during the lab to check status, create commits and push updates to GitHub. Keep them handy when working through the exercises.

1) Check local status and branch

```zsh
# show unstaged/staged files in a concise format
git status --porcelain

# show current branch
git branch --show-current

# show configured remotes
git remote -v

# show recent commits (compact)
git log --oneline -n 5
```

2) Stage and commit changes

```zsh
# stage all changes (be careful; review with git status first)
git add -A

# commit with a short, descriptive message
git commit -m "docs: update node-app README with lab outputs"
```

3) Push the current branch to origin

```zsh
# push main branch to origin
git push origin main

# get the short commit id for verification
git rev-parse --short HEAD
```

4) Handling an accidentally added embedded repository

If you see a gitlink (mode 160000) for a nested folder (an embedded repo), it means a repository was added inside this one. Decide whether you intended a submodule or not.

- To remove the nested repo from the index (keep files locally):

```zsh
# remove from index only (keeps local copy)
git rm --cached gsd
git commit -m "chore: remove embedded repo from index"
git push origin main
```

- To add it as a proper submodule (preferred if it is a separate project you want to track):

```zsh
# replace <url> with the remote url for the gsd repository
git submodule add <url> gsd
git commit -m "chore: add gsd as submodule"
git push origin main
```

Notes & safety
- Avoid committing secrets or credentials; use `.gitignore` to exclude sensitive files.
- Prefer small, focused commits with descriptive messages.
- If you accidentally add large binary files or nested repos, fix them before pushing to keep the upstream history clean.
