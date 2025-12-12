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
   - Kaniko (no daemon, no privileged access — ideal for multi-tenant)
   - Host Docker socket mounting (security risk)

   **Decision**: Kaniko via osscontainertools/kaniko fork (the original GoogleContainerTools
   repo was archived June 2025). Kaniko is the only option that doesn't require relaxing
   seccomp/AppArmor, which is critical since worker pods from different customers share
   the same cluster.

2. **Privileged operations**: Current agent uses sudo extensively

3. **Process model change**: Worker agent currently polls; K8s Jobs receive assignment at startup via env vars

### Existing K8s infrastructure we can leverage

- DOKS cluster already running Rails app
- Private Docker registry in-cluster (registry.digitalocean.com/saturnci)
- Secrets management via K8s Secrets
- Deploy scripts in ops/

## Architecture decision: separate clusters

Workers will run in a **separate K8s cluster** from the web app. Reasons:

- Workers can't starve web app of resources
- Different scaling needs (web = consistent, workers = bursty)
- Can use different node sizes optimized for each workload
- Isolation limits blast radius if something goes wrong

## Migration steps

### Phase 1: Set up worker cluster

1. Create new DOKS cluster for workers
2. Configure kubectl context for new cluster
3. Set up container registry access
4. Add cluster config to Terraform

### Phase 2: Build worker container image

1. Containerize worker_agent
2. Solve Docker-in-Docker (using Kaniko via osscontainertools fork)
3. Push to registry
4. Test locally with docker-compose

### Phase 3: Create K8s Job template

1. Define Job spec with worker container
2. Pass assignment data via env vars
3. Mount necessary secrets
4. Test creating Jobs manually via kubectl

### Phase 4: Rails integration

1. Add kubernetes-client gem or use K8s API directly
2. Create `KubernetesWorker` class to create Jobs
3. Update Task creation to spawn K8s Job instead of assigning to Worker
4. Keep Dispatcher path working as fallback

### Phase 5: Cutover

1. Run both paths in parallel, gradually shift traffic
2. Monitor and compare
3. Deprecate droplet-based Workers
4. Remove Dispatcher, WorkerPool, droplet provisioning code
