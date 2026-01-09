# Lab session: concrete commands, outputs and notes

This file collects the actual commands and trimmed outputs captured during a recent interactive session. Use it as a reference when following the hands-on labs.

## Environment

- Docker version (lab):

```text
docker --version
# Docker version 28.0.4, build b8034c0
```

## node-app lab (commands & outputs)

Build local image:

```zsh
cd node-app
docker build -t ddd:nodeweb1 .
```

Trimmed build summary from the session:

```
[+] Building 22.5s (11/11) FINISHED
 => naming to docker.io/library/ddd:nodeweb1
```

List images:

```
docker images
# example output:
REPOSITORY   TAG        IMAGE ID       CREATED          SIZE
ddd          nodeweb1   cbcc3203b0b9   31 seconds ago   120MB
ddd          nodeweb    14b367f77833   26 hours ago     176MB
```

Run container:

```zsh
docker run -d --name web1 -p 8080:8080 ddd:nodeweb1
# returns container id
```

Cleanup example:

```zsh
docker rm web1 -f
docker rmi ddd:nodeweb
docker rmi ddd:nodeweb1
```

Notes: building directly from a private git URL may require credentials; example failure:

```
docker build -t ddd:nodeweb https://github.com/rangasam/psweb.git#main
# ERROR: fatal: could not read Username for 'https://github.com': terminal prompts disabled
```

Workaround: use a public repo or build from a local clone where credentials are available to git.


## multi-stage lab (commands & outputs)

Build:

```zsh
cd multi-stage
docker build -t multi:stage .
```

Trimmed build output:

```
[+] Building 30.3s (15/15) FINISHED
 => naming to docker.io/library/multi:stage
```

History (to inspect layers and sizes):

```
docker history multi:stage
# trimmed example output:
IMAGE          CREATED              CREATED BY                          SIZE      COMMENT
01e0fc5220eb   About a minute ago   ENTRYPOINT ["/bin/server"]          0B        buildkit.dockerfile.v0
<missing>      About a minute ago   COPY /bin/server /bin/ # buildkit   7.92MB    buildkit.dockerfile.v0
<missing>      About a minute ago   COPY /bin/client /bin/ # buildkit   7.99MB    buildkit.dockerfile.v0
```

Inspect (metadata):

```
docker inspect multi:stage
# example fields:
"RepoTags": ["multi:stage"],
"Config": {"WorkingDir":"/","Entrypoint":["/bin/server"]},
"Size": 9105460
```

## Image cleanup examples (dangling images and forcing removal)

During the session the following steps were demonstrated to remove dangling / orphaned images and reclaim space:

1) List dangling images (untagged):

```zsh
docker images -f "dangling=true"
```

2) If an image is referenced by a running container, stop/remove the container first (example used container id `e70e949a061a`):

```zsh
docker ps -a --filter "ancestor=e2ad35612109" --format 'table {{.ID}}\t{{.Image}}\t{{.Status}}'
docker stop e70e949a061a
docker rm e70e949a061a
```

3) Remove the image:

```zsh
docker rmi e2ad35612109
# or force (use with care):
docker rmi -f e2ad35612109
```

4) Global cleanup (use with caution - destructive):

```zsh
docker image prune -a
# or
sudo docker system prune --all --volumes
```

Notes and troubleshooting
- `docker rmi` will fail if any container references the image. Use `docker ps -a --filter ancestor=<image>` to find referencing containers.
- `docker build` from a remote git repo will prompt for credentials if the repo is private; CI/build runners should use SSH auth or access tokens configured securely.

---

If you'd like, I can merge the important snippets above back into `PROJECT-GUIDE.md` in the appropriate sections (compose, node-app, multi-stage) so the master guide contains these exact session outputs. Say "merge lab outputs" and I'll integrate them and mark the todo progress accordingly.

---

## Git / GitHub quick commands (copy/paste)

Use these commands during the lab to verify status, commit and push changes to GitHub. Replace messages and branch names as needed.

```zsh
# quick status and branch
git status --porcelain
git branch --show-current
git remote -v

# recent commits
git log --oneline -n 5

# stage all changes and commit
git add -A
git commit -m "docs: update READMEs with lab outputs"

# push current branch to origin (push main as example)
git push origin main

# confirm current commit
git rev-parse --short HEAD
```

Handling an accidentally added nested repository (gitlink)

```zsh
# remove nested repo from index but keep local files
git rm --cached gsd
git commit -m "chore: remove embedded repo from index"
git push origin main

# or add it as a proper submodule (if intended)
# git submodule add <url> gsd
# git commit -m "chore: add gsd as submodule"
# git push origin main
```

Notes:
- Avoid committing secrets. Add sensitive files to `.gitignore` first.
- Use small, focused commits with clear messages.
