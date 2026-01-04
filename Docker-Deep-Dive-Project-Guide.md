# Docker Deep Dive — Project Guide (based on repository)

This document maps the repository's project folders to Docker Deep Dive concepts and provides step-by-step implementation, run instructions, safety guardrails, troubleshooting tips, prerequisites, and optional monitoring/plotting instructions. It synthesizes the course slide topics (attached) into practical, repository-specific guidance.

> Repository root folders covered: `compose/`, `multi-stage/`, `node-app/`, `stacks/`, `stackv2-app/`.

## Quick prerequisites

- macOS (your environment). zsh is default shell.
- Docker Desktop (recommended) or Docker Engine + Compose v2. Ensure Docker daemon running.
- docker CLI and docker compose available (run `docker --version` and `docker compose version`).
- Python 3.8+ with pip for optional plotting. Example packages: `matplotlib`, `pandas`.
- Go 1.18+ for `multi-stage/cmd` (if you want to build/run Go code). `node` and `npm` for `node-app` (optional).

Optional tools for safety & scanning:
- trivy (container image scanner): https://aquasecurity.github.io/trivy/
- hadolint (Dockerfile linter).

## How to use this guide

- Follow the per-project sections below to build, run, and explore each sample.
- Use the Safety & Guardrails section before exposing services to the network or running in CI.
- Use the Troubleshooting section if you hit common errors.
- Use the Monitoring & Plots section to collect runtime metrics and visualize resource usage.

---

## 1) `compose/` — docker-compose basics

Purpose: Demonstrates multi-container apps using Compose (single-file). Follows the course topic: "docker-compose" and "multi-container apps".

Files of interest: `compose/compose.yaml`, `compose/Dockerfile`, `compose/README.md`, `compose/app/` (Python app).

Step-by-step

1. Inspect compose file
   - Open `compose/compose.yaml`. Note services, networks, and volume definitions.
2. Build and start
   - From repository root or `compose/` directory, run:

```zsh
cd compose
docker compose up --build
```

   - Expected: Compose builds image(s) and starts containers. Visit the listed port (e.g., http://localhost:5000) if the app exposes HTTP.
3. Stop and remove

```zsh
docker compose down --volumes --remove-orphans
```

Notes and tips
- Use `docker compose up --build --detach` to run in background.
- `docker compose ps` shows services.
- Use `.env` and secret files to avoid committing credentials.

Suggested exercises
- Add a `depends_on` or healthcheck to a service.
- Add a named volume and verify persistence by restarting the stack.

---

## 2) `multi-stage/` — multi-stage Docker builds and Go app

Purpose: Demonstrates multi-stage builds for smaller images and build-time separation.

Files: `multi-stage/Dockerfile`, `multi-stage/cmd/server/`, `multi-stage/cmd/client/`, `go.mod`, `go.sum`.

What multi-stage builds teach
- Compile in a builder stage (with Go toolchain), then copy only the binary into a minimal runtime image (scratch or alpine).
- Reduces final image size and attack surface.

Build and run (local)

1. Build image manually

```zsh
cd multi-stage
docker build -t ddd/multi-stage-server:latest -f Dockerfile .
```

2. Run server

```zsh
docker run --rm -p 8080:8080 ddd/multi-stage-server:latest
```

3. Or build and run client/server via provided scripts or by running the `cmd` binaries (or `go run`).

Notes
- Confirm the Dockerfile uses multi-stage: look for multiple `FROM` lines and a final `COPY --from=builder ...`.
- Rebuild after modifying Go code.

Security tip
- Prefer distroless or `scratch` for final stage to reduce packages and shells.

---

## 3) `node-app/` — node app with Dockerfile

Purpose: Basic Node.js app showing Dockerfile best practices and containerizing Node apps.

Files: `node-app/Dockerfile`, `node-app/app.js`, `node-app/package.json`.

Run steps

```zsh
cd node-app
# build
docker build -t ddd/node-app:latest .
# run
docker run --rm -p 3000:3000 ddd/node-app:latest
```

Optional: Use `docker compose` if you want to add a separate service (e.g., a redis cache). `docker compose` file not provided here, but you can create one.

Best practices used/should be used
- Use `.dockerignore` to exclude node_modules and dev files.
- Use a specific Node base image (e.g., `node:18-alpine`).
- Use non-root user in image if possible.

---

## 4) `stacks/` & `stackv2-app/` — stack examples and reproducible stacks

Purpose: Demonstrates stacks and Compose files for deployable stacks (possible differences across versions).

Files to inspect: `stacks/compose.yaml`, `stackv2-app/Dockerfile`, etc.

Steps
1. Inspect `compose.yaml` and check Compose file version and features (secrets, configs, deploy).
2. Start with `docker compose` (v2) commands as earlier.

Stack vs Compose nuance
- Docker Stacks (swarm) uses `docker stack deploy` and requires swarm mode. The repo likely demonstrates Compose v2 features rather than actual swarm stacks; check `stacks/README.md`.

If using Docker Swarm (advanced)

```zsh
# initialize swarm (single node)
docker swarm init
# deploy stack
docker stack deploy -c stacks/compose.yaml mystack
# list
docker stack ls
docker stack services mystack
```

Caution: Swarm changes environment — use `docker swarm leave --force` to exit.

---

## Resource limits, healthchecks, networking, and volumes (cross-cutting topics)

- Use `healthcheck` in Dockerfiles or Compose to allow orchestrators to verify container readiness.
- Set `mem_limit`, `cpus` (Compose) or `--memory`, `--cpus` (docker run) to safe defaults when experimenting on a laptop.
- Use named volumes for persistent data and bind mounts for dev iteration.
- Use user namespaces or run processes as non-root within containers where feasible.

Example Compose snippet for limits and healthcheck

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

Note: `deploy` is ignored by plain `docker compose up` (used by swarm). For local resource limits, use `mem_limit` in v1 compose or `docker run` flags.

---

## Safety & guardrails (must-read before running public-facing services)

1. Secrets & credentials
   - Never commit API keys, passwords, or `.env` files to the repo.
   - Use Docker secrets (for swarm) or external secrets manager in production. For local testing, use `.env` but list it in `.gitignore`.
2. Image scanning
   - Scan images with Trivy before publishing: `trivy image ddd/node-app:latest`.
3. Least privilege
   - Run processes as a non-root user inside the image.
4. Limit resource usage
   - Avoid runaway containers on laptops: set cpu/memory caps when running experiments.
5. Network exposure
   - Avoid binding production apps to `0.0.0.0` unless required. Prefer `127.0.0.1` for local-only services.
6. Remove dangling resources
   - Periodically run: `docker system prune --all --volumes` (careful — this deletes images and volumes).

---

## Troubleshooting (common issues & fixes)

1. Build fails with permission or file not found
   - Ensure Dockerfile paths and context are correct. `docker build -f path/to/Dockerfile .` sets build context to `.`; if files outside context, they will be unavailable.
2. Port already in use
   - `bind: address already in use` -> change host port or kill the process using the port (`lsof -i :3000` then `kill`), or change container port mapping.
3. Compose `...no such service` or `no such network`
   - Run `docker compose up` from the directory where `compose.yaml` exists, or pass `-f` path.
4. Slow builds
   - Use multi-stage builds and proper caching. Keep the `COPY` ordering and `RUN` layers optimized.
5. File permission issues inside container
   - If host-created files are owned by root, set `chown` in Dockerfile or use `--user` to map to a non-root user.
6. Volume mounting on macOS is slow
   - Consider using cached mounts or bind only necessary directories; use Docker Desktop file sharing optimizations.

If you get specific error messages, search exact text; the fix is often 1–2 lines.

---

## Monitoring & plots — collect `docker stats` and plot resource usage

Goal: collect metrics for containers while running a scenario and plot CPU and memory usage.

1. Collect metrics (simple CSV using `docker stats` JSON)

Create a short collector script `tools/collect_stats.py` (not included here) or run this quick one-liner to capture CPU/MEM every 2s for a container:

```zsh
# Example: capture metrics for a container named 'compose_web_1'
container=compose_web_1
echo "timestamp,cpu_percent,mem_usage,mem_limit,mem_percent" > stats.csv
while true; do
  ts=$(date +%s)
  out=$(docker stats --no-stream --format "{{.CPUPerc}},{{.MemUsage}},{{.MemPerc}}" $container 2>/dev/null)
  if [ -z "$out" ]; then break; fi
  # out example: "0.10%,12MiB / 1GiB,1.17%"
  cpu=$(echo $out | awk -F',' '{print $1}' | tr -d '%')
  mem_usage=$(echo $out | awk -F',' '{print $2}' | awk '{print $1}')
  mem_percent=$(echo $out | awk -F',' '{print $3}' | tr -d '%')
  echo "$ts,$cpu,$mem_usage,,$mem_percent" >> stats.csv
  sleep 2
done
```

2. Plot with Python (example)

Save this snippet to `tools/plot_stats.py`:

```python
import pandas as pd
import matplotlib.pyplot as plt

df = pd.read_csv('stats.csv', names=['timestamp','cpu','mem_usage','mem_limit','mem_percent'], header=0)
df['time'] = pd.to_datetime(df['timestamp'], unit='s')

plt.figure(figsize=(10,4))
plt.plot(df['time'], df['cpu'].astype(float), label='CPU%')
plt.ylabel('CPU%')
plt.legend()
plt.tight_layout()
plt.savefig('cpu_plot.png')

plt.figure(figsize=(10,4))
plt.plot(df['time'], df['mem_percent'].astype(float), label='Mem%')
plt.ylabel('Memory %')
plt.legend()
plt.tight_layout()
plt.savefig('mem_plot.png')
```

Run:

```zsh
python3 -m pip install pandas matplotlib
python3 tools/plot_stats.py
```

The plots `cpu_plot.png` and `mem_plot.png` show trends. Use them to understand hotspots, memory leaks, or CPU spikes while exercising the app.

Note: For production-grade monitoring use Prometheus + Grafana or a hosted APM (Datadog, New Relic).

---

## Recommended exercises (learning path)

1. Compose: Add a Redis service to `compose/` and update the Python app to use it.
2. Multi-stage: Modify the Go server to include an additional endpoint and verify the final image size remains small.
3. Node-app: Add a healthcheck and user non-root in the Dockerfile.
4. Stacks: If you want to try swarm, initialize a local swarm and deploy `stacks/compose.yaml` as a stack.
5. CI/CD: Add a small GitHub Actions job to build and scan images using trivy and push to Docker Hub (use secrets in repo settings).

---

## Quick checklist before publishing or sharing images

- [ ] Remove secrets from code and .env files
- [ ] Run image scanner (Trivy)
- [ ] Run Dockerfile linter (hadolint)
- [ ] Tag images with semantic tags, not `latest` only
- [ ] Use minimal base images where possible

---

## Troubleshooting appendix (common log snippets)

- "permission denied" during `COPY` or `ADD`: ensure files exist in context and correct owner/permissions. Avoid copying root-owned files unexpectedly.
- "No such file or directory" when starting entrypoint: verify binary path and that multi-stage copied binary into final image.
- "address already in use": change port mapping host side or stop other service.

---

## Notes about the attached course slides

The attached slide folders (02..13) map directly to the sections above — they contain topic-level theory such as architecture, images, multi-stage builds, networking, volumes, compose, and production multi-container apps. Use the per-slide PDFs for deeper conceptual reading while following the hands-on steps in this repository.

---

## Where to go next

- If you'd like, I can:
  - Add `tools/collect_stats.py` and `tools/plot_stats.py` to the repo (as runnable files).
  - Add a lint/scan GitHub Actions workflow template.
  - Create a short walkthrough README for each subfolder with exact port numbers and example responses.

If you want any of the above, tell me which and I'll add them.

---

## Completion summary

This document provides the hands-on mapping between the repo projects and the Docker Deep Dive course topics, step-by-step build/run commands, safety guardrails, troubleshooting steps, recommended exercises, and an example approach to collect and plot container metrics.


---

Generated on: 2026-01-04

