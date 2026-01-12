# Docker Swarm Guide

A comprehensive guide to Docker Swarm clustering and orchestration, covering architecture, setup, management, security, and best practices.

## Table of Contents

- [Overview](#overview)
- [Architecture](#architecture)
- [Prerequisites](#prerequisites)
- [Lab Setup with Multipass](#lab-setup-with-multipass)
- [Swarm Initialization](#swarm-initialization)
- [Node Management](#node-management)
- [Security](#security)
- [Commands Reference](#commands-reference)
- [Best Practices](#best-practices)
- [Pitfalls and Troubleshooting](#pitfalls-and-troubleshooting)
- [Swarm vs Kubernetes](#swarm-vs-kubernetes)

---

## Overview

**Docker Swarm** is Docker's native clustering and orchestration solution. It turns a pool of Docker hosts into a single, virtual Docker host, providing:

- **Clustering**: Groups multiple Docker hosts together
- **Orchestration**: Manages container deployment, scaling, and networking across the cluster
- **High Availability**: Built-in leader election and fault tolerance
- **Security**: TLS mutual authentication and encryption
- **Simplicity**: Easy to set up compared to Kubernetes

### Key Features

- Native Docker integration
- Declarative service model
- Desired state reconciliation
- Multi-host networking
- Service discovery
- Load balancing
- Rolling updates
- Scaling

---

## Architecture

### Swarm Components

```
┌─────────────────────────────────────────────────────────────────┐
│                        Raft Consensus Group                     │
│  ┌──────────────────────────────────────────────────────────┐  │
│  │                     Cluster Store                        │  │
│  │  🔒  [Manager Join Token]  [Worker Join Token]           │  │
│  └──────────────────────────────────────────────────────────┘  │
│                                                                 │
│  ┌─────────────┐    ┌─────────────┐    ┌─────────────┐       │
│  │  Manager    │    │  Manager    │    │  Manager    │       │
│  │  Follower   │    │  Leader ⭐  │    │  Follower   │       │
│  │   Node1     │    │   Node2     │    │   Node3     │       │
│  └─────────────┘    └─────────────┘    └─────────────┘       │
└─────────────────────────────────────────────────────────────────┘
                              │
              ┌───────────────┴───────────────┐
              ▼                               ▼
        ┌──────────┐                   ┌──────────┐
        │  Worker  │                   │  Worker  │
        │  Node1   │                   │  Node2   │
        └──────────┘                   └──────────┘
```

### Node Types

#### Manager Nodes

- **Leader**: Performs orchestration and management tasks
- **Followers (Reachable)**: Maintain cluster state, can become leader
- Uses **Raft consensus** algorithm for distributed state management
- Recommended: 3, 5, or 7 managers (odd number for quorum)
- Can optionally run workloads (not recommended in production)

#### Worker Nodes

- Execute containers (tasks)
- Report status to managers
- Do not participate in Raft consensus
- Lightweight - optimized for running workloads

### Raft Consensus

Docker Swarm uses the Raft consensus algorithm:

- **Leader Election**: One manager is elected as leader
- **Log Replication**: Leader replicates state to followers
- **Quorum**: Majority of managers must agree on changes
- **Fault Tolerance**: Can tolerate (N-1)/2 failures

**Quorum Requirements:**

| Managers | Quorum | Fault Tolerance |
|----------|--------|-----------------|
| 1        | 1      | 0               |
| 3        | 2      | 1               |
| 5        | 3      | 2               |
| 7        | 4      | 3               |

### Cluster Store

Encrypted distributed database storing:

- Cluster configuration
- Node information
- Network configuration
- Secrets
- Join tokens

**Security:**
- Encrypted by default
- TLS certificates for node authentication
- Automatic certificate rotation

---

## Prerequisites

### System Requirements

- **Docker Engine**: 1.12+ (29.1.4 used in this guide)
- **Network**: TCP ports 2377 (cluster management), 7946 (node communication), UDP 4789 (overlay network)
- **OS**: Linux (Ubuntu 24.04 LTS in this guide), macOS (via Docker Desktop), Windows

### Hardware Recommendations

**Manager Nodes:**
- CPU: 2+ cores
- RAM: 4GB minimum, 8GB+ recommended
- Disk: 40GB+

**Worker Nodes:**
- CPU: Based on workload
- RAM: Based on workload
- Disk: 40GB+

---

## Lab Setup with Multipass

[Multipass](https://multipass.run/) provides lightweight Ubuntu VMs for local testing.

### Install Multipass

```bash
# macOS
brew install multipass

# Or download from https://multipass.run/
```

### Check Multipass Version

```bash
multipass --version
# multipass   1.16.1+mac
# multipassd  1.16.1+mac
```

### Find Available Images

```bash
multipass find
```

Output shows available Ubuntu versions and blueprints:
```
Image                       Aliases           Version          Description
22.04                       jammy             20251216         Ubuntu 22.04 LTS
24.04                       noble,lts         20251213         Ubuntu 24.04 LTS

Blueprint                   Aliases           Version          Description
docker                                        0.4              A Docker environment with Portainer
```

**⚠️ Warning**: Blueprints are deprecated! Use cloud-init instead.

### Launch Manager Nodes

```bash
# Manager 1 (will be the leader)
multipass launch docker --name mgr1

# Manager 2 (follower)
multipass launch docker --name mgr2

# Manager 3 (follower)
multipass launch docker --name mgr3
```

**Time:** ~1-2 minutes per node

**Note**: Each launch automatically:
- Creates Ubuntu 24.04 LTS VM
- Installs Docker Engine
- Mounts local directory (`~/multipass/<node-name>`)
- Assigns IP address

### Launch Worker Nodes

```bash
# Worker 1
multipass launch docker --name wkr1

# Worker 2
multipass launch docker --name wkr2
```

### List All VMs

```bash
multipass list
```

**Example Output:**
```
Name    State     IPv4             Image
mgr1    Running   192.168.2.4      Ubuntu 24.04 LTS
                  172.17.0.1
mgr2    Running   192.168.2.5      Ubuntu 24.04 LTS
                  172.17.0.1
mgr3    Running   192.168.2.6      Ubuntu 24.04 LTS
                  172.17.0.1
wkr1    Running   192.168.2.7      Ubuntu 24.04 LTS
                  172.17.0.1
wkr2    Running   192.168.2.8      Ubuntu 24.04 LTS
                  172.17.0.1
```

**IP Addresses:**
- `192.168.x.x`: Host-accessible IP (use for swarm communication)
- `172.17.0.1`: Docker bridge network (internal)

### Get VM Info

```bash
multipass info mgr1
```

**Output:**
```
Name:           mgr1
State:          Running
IPv4:           192.168.2.4
                172.17.0.1
Release:        Ubuntu 24.04.3 LTS
CPU(s):         2
Memory usage:   403.7MiB out of 3.8GiB
Disk usage:     3.0GiB out of 38.7GiB
Mounts:         /Users/guy/multipass/mgr1 => mgr1
```

### Shell into VM

```bash
multipass shell mgr1
```

You're now inside the Ubuntu VM with Docker pre-installed.

---

## Swarm Initialization

### Initialize Swarm on First Manager

From **mgr1**:

```bash
multipass shell mgr1
```

```bash
# Check Docker version
docker --version
# Docker version 29.1.4, build 0e6fee6

# Initialize swarm (MUST specify --advertise-addr)
docker swarm init --advertise-addr 192.168.2.4
```

**Output:**
```
Swarm initialized: current node (zgj7vp5xld48d4r3142rq0ksg) is now a manager.

To add a worker to this swarm, run the following command:

    docker swarm join --token SWMTKN-1-4hvh1k1zwtpqjc2ziyw32ca6gw74hctuami111desbr3dc4pp9-e1fs6ovmu609rhc1wljk2xui2 192.168.2.4:2377

To add a manager to this swarm, run 'docker swarm join-token manager' and follow the instructions.
```

**Important:**
- `--advertise-addr` specifies the IP other nodes use to connect
- Use the **host-accessible IP** (192.168.2.4), not Docker bridge (172.17.0.1)
- Node ID is automatically generated (e.g., `zgj7vp5xld48d4r3142rq0ksg`)

### Get Manager Join Token

```bash
docker swarm join-token manager
```

**Output:**
```
To add a manager to this swarm, run the following command:

    docker swarm join --token SWMTKN-1-4hvh1k1zwtpqjc2ziyw32ca6gw74hctuami111desbr3dc4pp9-846ncobq72yn9kcmzqxbr8fjx 192.168.2.4:2377
```

### Join Manager Nodes

From **mgr2**:

```bash
multipass shell mgr2
```

```bash
docker swarm join --token SWMTKN-1-4hvh1k1zwtpqjc2ziyw32ca6gw74hctuami111desbr3dc4pp9-846ncobq72yn9kcmzqxbr8fjx 192.168.2.4:2377
```

**Output:**
```
This node joined a swarm as a manager.
```

From **mgr3**:

```bash
multipass shell mgr3
docker swarm join --token SWMTKN-1-4hvh1k1zwtpqjc2ziyw32ca6gw74hctuami111desbr3dc4pp9-846ncobq72yn9kcmzqxbr8fjx 192.168.2.4:2377
```

### Verify Manager Cluster

From any manager:

```bash
docker node ls
```

**Output:**
```
ID                            HOSTNAME   STATUS    AVAILABILITY   MANAGER STATUS   ENGINE VERSION
zgj7vp5xld48d4r3142rq0ksg *   mgr1       Ready     Active         Leader           29.1.4
yrtcbg7nre7zfk86rz2cdftly     mgr2       Ready     Active         Reachable        29.1.4
bpmoi2a95nu63vz6ds2p6iodu     mgr3       Ready     Active         Reachable        29.1.4
```

**Status Meanings:**
- `*` : Current node
- `Leader` : Raft leader (one per cluster)
- `Reachable` : Follower, can become leader
- `Ready` : Node is healthy
- `Active` : Node can accept workloads

---

## Node Management

### Add Worker Nodes

#### Get Worker Join Token

From any manager:

```bash
docker swarm join-token worker
```

**Output:**
```
To add a worker to this swarm, run the following command:

    docker swarm join --token SWMTKN-1-4hvh1k1zwtpqjc2ziyw32ca6gw74hctuami111desbr3dc4pp9-e1fs6ovmu609rhc1wljk2xui2 192.168.2.4:2377
```

#### Join Workers

From **wkr1**:

```bash
multipass shell wkr1
docker swarm join --token SWMTKN-1-4hvh1k1zwtpqjc2ziyw32ca6gw74hctuami111desbr3dc4pp9-e1fs6ovmu609rhc1wljk2xui2 192.168.2.4:2377
```

From **wkr2**:

```bash
multipass shell wkr2
docker swarm join --token SWMTKN-1-4hvh1k1zwtpqjc2ziyw32ca6gw74hctuami111desbr3dc4pp9-e1fs6ovmu609rhc1wljk2xui2 192.168.2.4:2377
```

**Output:**
```
This node joined a swarm as a worker.
```

#### Verify All Nodes

From manager:

```bash
docker node ls
```

**Output:**
```
ID                            HOSTNAME   STATUS    AVAILABILITY   MANAGER STATUS   ENGINE VERSION
zgj7vp5xld48d4r3142rq0ksg *   mgr1       Ready     Active         Leader           29.1.4
yrtcbg7nre7zfk86rz2cdftly     mgr2       Ready     Active         Reachable        29.1.4
bpmoi2a95nu63vz6ds2p6iodu     mgr3       Ready     Active         Reachable        29.1.4
5nb4b0lz5mnriwubdgtnqadr2     wkr1       Ready     Active                          29.1.4
uf5ubszi11ihe885nv73sne4p     wkr2       Ready     Active                          29.1.4
```

Workers have no `MANAGER STATUS` (blank column).

### Drain Manager Nodes

**Best Practice:** Prevent managers from running workloads in production.

```bash
docker node update --availability drain mgr1
docker node update --availability drain mgr2
docker node update --availability drain mgr3
```

**Verify:**

```bash
docker node ls
```

**Output:**
```
ID                            HOSTNAME   STATUS    AVAILABILITY   MANAGER STATUS   ENGINE VERSION
zgj7vp5xld48d4r3142rq0ksg *   mgr1       Ready     Drain          Leader           29.1.4
yrtcbg7nre7zfk86rz2cdftly     mgr2       Ready     Drain          Reachable        29.1.4
bpmoi2a95nu63vz6ds2p6iodu     mgr3       Ready     Drain          Reachable        29.1.4
5nb4b0lz5mnriwubdgtnqadr2     wkr1       Ready     Active                          29.1.4
uf5ubszi11ihe885nv73sne4p     wkr2       Ready     Active                          29.1.4
```

**Availability States:**
- `Active`: Can accept tasks
- `Drain`: Cannot accept new tasks, existing tasks migrated
- `Pause`: Cannot accept new tasks, existing tasks stay

### Leave Swarm

From a worker or manager:

```bash
docker swarm leave
```

**Output:**
```
Node left the swarm.
```

**For managers**, add `--force`:

```bash
docker swarm leave --force
```

**Effect on cluster:**
- Worker leaves: Tasks redistributed to other workers
- Manager leaves: May trigger leader election
- Node shows as `Down` in `docker node ls`

**After leaving**, old node IDs remain in the cluster. Clean up:

```bash
# From a manager
docker node rm <node-id>
```

---

## Security

### Join Token Rotation

Join tokens are secrets that allow nodes to join the swarm. Rotate them regularly or after a compromise.

#### Rotate Worker Token

```bash
docker swarm join-token worker --rotate
```

**Output:**
```
Successfully rotated worker join token.

To add a worker to this swarm, run the following command:

    docker swarm join --token SWMTKN-1-...-NEW_TOKEN... 192.168.2.4:2377
```

**⚠️ Important:**
- Old tokens become **invalid immediately**
- Existing nodes are **NOT affected**
- New nodes must use the **new token**

**Pitfall Example:**

```bash
# Worker tries to rejoin with old token after rotation
docker swarm join --token SWMTKN-1-...-OLD_TOKEN... 192.168.2.4:2377
```

**Error:**
```
Error response from daemon: rpc error: code = InvalidArgument desc = A valid join token is necessary to join this cluster
```

**Solution:** Get the new token from a manager and use it.

#### Rotate Manager Token

```bash
docker swarm join-token manager --rotate
```

Same behavior as worker token rotation.

### Get Token Silently

For scripting:

```bash
docker swarm join-token worker --quiet
# SWMTKN-1-4hvh1k1zwtpqjc2ziyw32ca6gw74hctuami111desbr3dc4pp9-5abjr9hoxfhvr10iip681a2e5

docker swarm join-token manager --quiet
# SWMTKN-1-4hvh1k1zwtpqjc2ziyw32ca6gw74hctuami111desbr3dc4pp9-846ncobq72yn9kcmzqxbr8fjx
```

### Autolock Swarm

Protect cluster state with encryption key. Managers require unlock key after restart.

#### Enable Autolock

```bash
docker swarm update --autolock=true
```

**Output:**
```
Swarm updated.
To unlock a swarm manager after it restarts, run the `docker swarm unlock`
command and provide the following key:

    SWMKEY-1-idEZ+MBDfxkKG1W2e/xAWGoa2WcQAXElZJ9vtC5+xz8

Remember to store this key in a password manager, since without it you
will not be able to restart the manager.
```

**⚠️ Critical:**
- **Save the unlock key securely** (password manager, secrets vault)
- Without the key, you **cannot restart managers**
- Losing the key = losing the cluster

#### Unlock Manager After Restart

Simulate restart:

```bash
sudo service docker restart
```

Try to use Docker:

```bash
docker node ls
```

**Error:**
```
Error response from daemon: Swarm is encrypted and needs to be unlocked before it can be used. Please use "docker swarm unlock" to unlock it.
```

**Unlock:**

```bash
docker swarm unlock
```

**Prompt:**
```
Enter unlock key: [paste SWMKEY-1-idEZ+MBDfxkKG1W2e/xAWGoa2WcQAXElZJ9vtC5+xz8]
```

**Success:**

```bash
docker node ls
# Works now
```

#### Disable Autolock

```bash
docker swarm update --autolock=false
```

### TLS Certificates

Swarm uses mutual TLS authentication between nodes.

#### View Certificate

```bash
sudo openssl x509 -in /var/lib/docker/swarm/certificates/swarm-node.crt -text
```

**Output (excerpts):**
```
Certificate:
    Issuer: CN = swarm-ca
    Validity
        Not Before: Jan 11 19:19:00 2026 GMT
        Not After : Apr 11 20:19:00 2026 GMT
    Subject: O = n2w4octw769as8a2l4t996h21, OU = swarm-manager, CN = zgj7vp5xld48d4r3142rq0ksg
    X509v3 Subject Alternative Name: 
        DNS:swarm-manager, DNS:zgj7vp5xld48d4r3142rq0ksg, DNS:swarm-ca
```

**Certificate Details:**
- Issued by swarm CA
- 90-day expiry by default
- Subject CN is node ID
- Automatic rotation before expiry

#### Change Certificate Expiry

```bash
docker swarm update --cert-expiry 48h
```

**Verify:**

```bash
docker info | grep "Expiry Duration"
# Expiry Duration: 2 days
```

**Check CA Configuration:**

```bash
docker info | grep "CA Configuration" && docker info | grep "Expiry Duration"
# CA Configuration:
# Expiry Duration: 2 days
```

**Recommendations:**
- Production: 30-90 days
- High-security environments: 24-48 hours
- Lab/dev: Default (90 days)

**⚠️ Warning:** Very short expiry (< 1 hour) may cause issues if nodes can't reach the CA for rotation.

---

## Commands Reference

### Swarm Management

```bash
# Initialize swarm
docker swarm init --advertise-addr <IP>

# Join swarm
docker swarm join --token <TOKEN> <IP>:2377

# Leave swarm
docker swarm leave
docker swarm leave --force  # For managers

# Get join tokens
docker swarm join-token worker
docker swarm join-token manager
docker swarm join-token worker --quiet  # Token only
docker swarm join-token worker --rotate  # Rotate and display new

# Update swarm
docker swarm update --autolock=true
docker swarm update --autolock=false
docker swarm update --cert-expiry 48h

# Unlock swarm
docker swarm unlock

# Get unlock key
docker swarm unlock-key

# Rotate unlock key
docker swarm unlock-key --rotate
```

### Node Management

```bash
# List nodes (managers only)
docker node ls

# Inspect node
docker node inspect <node-id>
docker node inspect --pretty <node-id>

# Update node availability
docker node update --availability active <node-id>
docker node update --availability drain <node-id>
docker node update --availability pause <node-id>

# Add label to node
docker node update --label-add <key>=<value> <node-id>

# Remove label
docker node update --label-rm <key> <node-id>

# Promote worker to manager
docker node promote <node-id>

# Demote manager to worker
docker node demote <node-id>

# Remove node (must be down or drained)
docker node rm <node-id>
docker node rm --force <node-id>
```

### Service Management

```bash
# Create service
docker service create --name <name> --replicas <n> <image>

# List services
docker service ls

# Inspect service
docker service inspect <service-name>

# List tasks
docker service ps <service-name>

# Scale service
docker service scale <service-name>=<n>

# Update service
docker service update --image <new-image> <service-name>

# Remove service
docker service rm <service-name>

# View logs
docker service logs <service-name>
```

### Stack Management

```bash
# Deploy stack
docker stack deploy -c <compose-file> <stack-name>

# List stacks
docker stack ls

# List services in stack
docker stack services <stack-name>

# List tasks in stack
docker stack ps <stack-name>

# Remove stack
docker stack rm <stack-name>
```

### Information Commands

```bash
# View swarm info
docker info

# Check if swarm is active
docker info | grep "Swarm: active"

# View CA and certificate expiry
docker info | grep "CA Configuration" && docker info | grep "Expiry"

# Get current node info
docker node inspect self
```

---

## Best Practices

### High Availability

1. **Use Odd Number of Managers**: 3, 5, or 7 (for Raft quorum)
2. **Spread Managers Across Availability Zones**: Different data centers/regions
3. **Drain Manager Nodes**: `docker node update --availability drain` in production
4. **Monitor Manager Health**: Watch for split-brain scenarios

### Security

1. **Rotate Join Tokens Regularly**: After onboarding, quarterly, or on compromise
2. **Enable Autolock for Production**: Protect swarm state
3. **Use Secrets for Sensitive Data**: Not environment variables
4. **Limit Port Exposure**: Firewall ports 2377, 7946, 4789
5. **Keep Docker Updated**: Security patches and bug fixes
6. **Use Private Registry**: Don't rely on public registries for critical images

### Networking

1. **Use Overlay Networks**: For multi-host container communication
2. **Encrypt Overlay Networks**: `--opt encrypted` for sensitive data
3. **Use Ingress Network**: Built-in load balancer for published ports
4. **Assign Static IPs to Managers**: Easier to reference and troubleshoot

### Resource Management

1. **Set Resource Limits**: CPU and memory for services
2. **Use Placement Constraints**: Control where tasks run
3. **Monitor Resource Usage**: Prevent resource exhaustion
4. **Use Labels**: Organize nodes by role, region, capability

### Operational

1. **Use Descriptive Names**: For services, networks, volumes
2. **Tag Images Properly**: Avoid `:latest` in production
3. **Implement Health Checks**: Containers and services
4. **Use Rolling Updates**: `--update-parallelism`, `--update-delay`
5. **Backup Cluster State**: `/var/lib/docker/swarm/` periodically
6. **Test Disaster Recovery**: Practice restoring from backup

### Monitoring and Logging

1. **Centralized Logging**: Ship logs to central system (ELK, Splunk)
2. **Monitor Metrics**: Prometheus + Grafana
3. **Alert on Failures**: Task failures, node failures, resource issues
4. **Track Certificate Expiry**: Set alerts before expiration

---

## Pitfalls and Troubleshooting

### Common Pitfalls

#### 1. Wrong `--advertise-addr`

**Problem:**
```bash
docker swarm init
# Error: could not choose an IP address to advertise
```

**Solution:**
```bash
docker swarm init --advertise-addr 192.168.2.4
```

**Why:** Multi-homed hosts need explicit IP specification.

#### 2. Using Old Join Token After Rotation

**Problem:**
```bash
docker swarm join --token OLD_TOKEN 192.168.2.4:2377
# Error: A valid join token is necessary to join this cluster
```

**Solution:** Get current token from manager:
```bash
docker swarm join-token worker
```

#### 3. Node Already in Swarm

**Problem:**
```bash
docker swarm join --token TOKEN 192.168.2.4:2377
# Error: This node is already part of a swarm
```

**Solution:**
```bash
docker swarm leave
docker swarm join --token TOKEN 192.168.2.4:2377
```

#### 4. Locked Swarm After Restart

**Problem:**
```bash
docker node ls
# Error: Swarm is encrypted and needs to be unlocked
```

**Solution:**
```bash
docker swarm unlock
# Enter unlock key
```

**Prevention:** Store unlock key securely.

#### 5. Lost Quorum

**Problem:** More than (N-1)/2 managers failed.

**Symptoms:**
- Cannot make cluster changes
- Leader election fails
- Services don't update

**Solution:**
1. Restore failed managers
2. Or force new cluster:
```bash
docker swarm init --force-new-cluster
```

**⚠️ Warning:** `--force-new-cluster` is destructive. Last resort only.

#### 6. Down Nodes Not Removed

**Problem:** `docker node ls` shows `Down` nodes.

**Cleanup:**
```bash
docker node rm <node-id>
# Or force
docker node rm --force <node-id>
```

#### 7. Can't Remove Manager

**Problem:**
```bash
docker node rm mgr2
# Error: node mgr2 is a cluster manager and is a member of the raft cluster
```

**Solution:** Demote first:
```bash
docker node demote mgr2
# Wait for state change
docker node rm mgr2
```

### Troubleshooting Commands

```bash
# Check swarm status
docker info | grep Swarm

# View node details
docker node inspect <node-id>

# Check service logs
docker service logs <service-name>

# View task errors
docker service ps <service-name> --no-trunc

# Check network
docker network ls
docker network inspect <network-name>

# View events
docker events --filter type=node
docker events --filter type=service

# Check ports
netstat -tuln | grep 2377
netstat -tuln | grep 7946
netstat -tuln | grep 4789

# Test connectivity
ping <manager-ip>
telnet <manager-ip> 2377
```

### Performance Issues

**Symptom:** Slow cluster operations

**Causes:**
- Network latency between managers
- Disk I/O bottleneck (Raft log writes)
- Too many nodes
- Insufficient manager resources

**Solutions:**
- Reduce manager count (max 7)
- Use SSDs for managers
- Improve network between managers
- Increase manager CPU/RAM

---

## Swarm vs Kubernetes

### Docker Swarm

**Pros:**
- ✅ **Simple**: Easy to learn and set up
- ✅ **Native Docker**: Integrated with Docker CLI
- ✅ **Low Resource**: Less overhead than Kubernetes
- ✅ **Fast Setup**: Cluster running in minutes
- ✅ **Built-in Orchestration**: No extra components

**Cons:**
- ❌ **Less Features**: Fewer advanced capabilities
- ❌ **Smaller Ecosystem**: Fewer tools and integrations
- ❌ **Limited Scaling**: Not ideal for very large clusters
- ❌ **Less Community**: Smaller user base

**Best For:**
- Small to medium deployments
- Teams familiar with Docker
- Quick prototypes
- Simple microservices architectures

### Kubernetes (K8s)

**Pros:**
- ✅ **Feature Rich**: Advanced scheduling, autoscaling, policies
- ✅ **Large Ecosystem**: Vast tooling and integrations
- ✅ **Industry Standard**: Wide adoption
- ✅ **Massive Scale**: Proven at enterprise scale

**Cons:**
- ❌ **Complex**: Steep learning curve
- ❌ **Resource Heavy**: More overhead
- ❌ **Slower Setup**: More components to configure
- ❌ **Operational Burden**: Requires dedicated ops knowledge

**Best For:**
- Large-scale deployments
- Complex microservices
- Multi-cloud environments
- Enterprises with dedicated Kubernetes teams

### Comparison Chart

| Feature              | Docker Swarm | Kubernetes |
|----------------------|--------------|------------|
| **Ease of Use**      | Simple ⭐⭐⭐⭐⭐ | Complex ⭐⭐ |
| **Setup Time**       | Minutes      | Hours/Days |
| **Resource Usage**   | Low          | High       |
| **Scaling**          | Good         | Excellent  |
| **Ecosystem**        | Small        | Vast       |
| **Auto-healing**     | Yes          | Yes        |
| **Load Balancing**   | Built-in     | Built-in   |
| **Secret Management**| Yes          | Yes        |
| **Rolling Updates**  | Yes          | Yes        |
| **Advanced Policies**| Limited      | Extensive  |
| **Community**        | Small        | Large      |

**Decision Guide:**

Choose **Docker Swarm** if:
- You need something **running quickly**
- Your team **knows Docker** already
- You have **< 100 nodes**
- You want **simplicity over features**

Choose **Kubernetes** if:
- You need **advanced features**
- You're building for **enterprise scale**
- You have **Kubernetes expertise**
- You need **extensive tooling**

---

## Lab Cleanup

### Stop All Services

```bash
# From manager
docker service rm $(docker service ls -q)
```

### Leave Swarm

```bash
# On each node
docker swarm leave --force  # Managers
docker swarm leave          # Workers
```

### Stop Multipass VMs

```bash
multipass stop mgr1 mgr2 mgr3 wkr1 wkr2
```

### Delete Multipass VMs

```bash
multipass delete mgr1 mgr2 mgr3 wkr1 wkr2
multipass purge  # Permanently remove
```

---

## Summary

Docker Swarm provides a **simple, native clustering solution** for Docker containers. Key takeaways:

1. **Easy Setup**: Initialize with one command, join with tokens
2. **High Availability**: Raft consensus with 3+ managers
3. **Security**: TLS by default, autolock for extra protection
4. **Production Ready**: Proven for small-to-medium deployments
5. **Operational Simplicity**: Less complex than Kubernetes
6. **Best Practices**: Drain managers, rotate tokens, monitor health

**Next Steps:**
1. Practice setup in lab environment
2. Deploy sample applications as services
3. Test failover scenarios
4. Implement monitoring and logging
5. Evaluate if Swarm meets your needs vs. Kubernetes

---

## Additional Resources

- **Official Docker Swarm Docs**: https://docs.docker.com/engine/swarm/
- **Swarm Tutorial**: https://docs.docker.com/engine/swarm/swarm-tutorial/
- **Raft Consensus**: https://raft.github.io/
- **Multipass**: https://multipass.run/docs
- **Docker Certified Associate**: Study guide for DCA certification

---

**Last Updated:** January 11, 2026  
**Docker Version:** 29.1.4  
**Ubuntu Version:** 24.04 LTS  
**Multipass Version:** 1.16.1
