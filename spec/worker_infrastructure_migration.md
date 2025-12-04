# Worker infrastructure migration

## Problem

Right now my worker architecture is inefficient. Each task runs on its own
DigitalOcean droplet. This is expensive because:

- VMs are often underutilized (CPU sits idle during I/O: git clone, docker pull, etc.)
- Droplet provisioning adds latency
- Paying for full VM per task regardless of actual resource usage

## Current architecture

```
Job created
  → Dispatcher assigns Task to pooled Worker (DigitalOcean droplet)
  → Worker agent polls API, receives assignment
  → Agent clones repo, builds Docker image, runs tests
  → Agent reports results back to API
  → Droplet destroyed or returned to pool
```

Key components:
- `Worker` model = DigitalOcean droplet
- `WorkerPool` = pre-provisioned pool of ~20 idle droplets
- `Dispatcher` = matches unassigned Tasks to available Workers
- `worker_agent` = Ruby script that runs on droplet, polls for assignments

## Proposed architecture: Kubernetes

Instead of managing droplets, run worker pods in the existing DOKS cluster.

```
Task created
  → Rails app creates K8s Job directly (no Dispatcher, no polling)
  → Job pod starts with assignment data as env vars
  → Pod clones repo, builds image, runs tests
  → Pod reports results back to API
  → Pod terminates
```

### What this eliminates

- Droplet provisioning/deprovisioning
- Worker pool management
- Polling loop in worker_agent
- The entire `Dispatcher` model

### Key challenges

1. **Docker-in-Docker**: worker_agent builds Docker images. Options:
   - DinD sidecar container (works but security concerns)
   - Kaniko (more secure, no daemon needed)
   - Host Docker socket mounting (security risk)

2. **Privileged operations**: Current agent uses sudo extensively

3. **Process model change**: Worker agent currently polls; K8s Jobs receive assignment at startup via env vars

### Existing K8s infrastructure we can leverage

- DOKS cluster already running Rails app
- Private Docker registry in-cluster (registry.digitalocean.com/saturnci)
- Secrets management via K8s Secrets
- Deploy scripts in ops/

## Migration steps

TODO: Detail the incremental migration plan
