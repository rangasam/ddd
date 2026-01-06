# README

Simple web app that exposes a web server on port `8080` as per `./app.js`.

See `Dockerfile` for more details. This README contains a small lab walkthrough with exact commands and the outputs captured during a recent session so you can reproduce and learn from them.

Used in:
- 2023 edition of PS Docker Deep Dive course

**Warning:** The app is maintained infrequently and may contain known vulnerabilities. Use image scanning (Trivy / docker scan) before publishing.

---

Lab: build, run and inspect (example session)

1) Docker version used in the lab

```zsh
docker --version
# Example output (lab):
# Docker version 28.0.4, build b8034c0
```

2) Build locally from the `node-app` folder

```zsh
cd node-app
docker build -t ddd:nodeweb1 .
```

Example build summary (trimmed):

```
[+] Building 22.5s (11/11) FINISHED
 => naming to docker.io/library/ddd:nodeweb1
```

3) Confirm the created image

```zsh
docker images
```

Example output from the session:

```
REPOSITORY   TAG        IMAGE ID       CREATED          SIZE
ddd          nodeweb1   cbcc3203b0b9   31 seconds ago   120MB
ddd          nodeweb    14b367f77833   26 hours ago     176MB
```

4) Run the container and map port 8080

```zsh
docker run -d --name web1 -p 8080:8080 ddd:nodeweb1
# container id returned on success
```

5) Stop/remove the container and images (cleaning up)

```zsh
docker rm web1 -f
docker rmi ddd:nodeweb
docker rmi ddd:nodeweb1
```

Example session outputs when removing images:

```
Untagged: ddd:nodeweb
Deleted: sha256:14b367f77833...
Untagged: ddd:nodeweb1
Deleted: sha256:cbcc3203b0b9...
```

6) Building directly from a git repository (note: auth may be required)

Attempting to build directly from a private GitHub repo can fail if credentials are required. Example failure seen in the session:

```
docker build -t ddd:nodeweb https://github.com/rangasam/psweb.git#main
ERROR: failed to solve: failed to read dockerfile: failed to load cache key: failed to fetch remote https://github.com/rangasam/psweb.git: git stderr:
fatal: could not read Username for 'https://github.com': terminal prompts disabled
: exit status 128
```

Workaround: use a public repo or include credentials (not recommended in plain URLs). In the lab we used the author's public repo which succeeded:

```
docker build -t ddd:nodeweb https://github.com/nigelpoulton/psweb.git#main
```

7) Inspecting an image

```zsh
docker inspect ddd:nodeweb
```

Example trimmed JSON fields from the session (identifiers & sizes omitted):

```
"RepoTags": ["ddd:nodeweb"],
"Config": {"WorkingDir":"/src","Entrypoint":["node","./app.js"],"Labels":{"maintainer":"nigelpoulton@hotmail.com"}},
"Size": 43519476
```

Notes & teaching points
- Use `docker history <image>` to see which Dockerfile steps contributed size.
- When building from git, avoid embedding credentials in URLs. Use a CI runner with SSH/git credentials or build locally from a checked-out repo.
- Always scan images before pushing (e.g., `trivy image <image>`).

Further exercises
- Add `HEALTHCHECK` to the Dockerfile that probes the app on port 8080.
- Switch the base image to an explicit `alpine` or `node:18-alpine` and measure final image size via `docker images` and `docker history`.

```

