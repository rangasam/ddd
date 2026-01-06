# Multi-stage builds

This example is based on the [Docker sample buildme repo](https://github.com/dockersamples/buildme) and contains a simple client/server app written in Go.

## App code

The app code is in the `cmd` directory but you don't need to interact with the app code or be a Go programmer to run the lab — the README below contains build / history / inspect examples captured during a session.

---

Lab: build, history & inspect (example session)

1) Build the multi-stage image

```zsh
cd multi-stage
docker build -t multi:stage .
```

Example trimmed build trace (lab):

```
[+] Building 30.3s (15/15) FINISHED
 => naming to docker.io/library/multi:stage
```

2) Examine the image history (useful to see which steps added size)

```zsh
docker history multi:stage
```

Trimmed example output from the session:

```
IMAGE          CREATED              CREATED BY                          SIZE      COMMENT
01e0fc5220eb   About a minute ago   ENTRYPOINT ["/bin/server"]          0B        buildkit.dockerfile.v0
<missing>      About a minute ago   COPY /bin/server /bin/ # buildkit   7.92MB    buildkit.dockerfile.v0
<missing>      About a minute ago   COPY /bin/client /bin/ # buildkit   7.99MB    buildkit.dockerfile.v0
```

3) Inspect image metadata

```zsh
docker inspect multi:stage
```

Example trimmed JSON fields (lab):

```
"RepoTags": ["multi:stage"],
"Config": {"WorkingDir":"/","Entrypoint":["/bin/server"]},
"Size": 9105460
```

Notes and teaching points
- Multi-stage builds let you compile in a larger image and copy only the artifacts you need into a small final image.
- Use `docker history` to verify large files or build tools were left behind in earlier stages and did not make it into the final image.
- For fastest iteration, consider building the binary locally and copying it into a tiny runtime image for testing.

Exercises
- Modify the `Dockerfile` to use `scratch` or `distroless` for the final stage and compare `docker images` sizes.


