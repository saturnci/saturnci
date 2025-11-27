# Queueing Theory Mapping

| Current Concept | Queueing Theory Term |
|-----------------|---------------------|
| `Run` (unassigned) | **Job** or **Task** |
| `unassigned_runs` | **Queue** (the waiting line of jobs) |
| `TestRunner` | **Server** or **Worker** |
| `available_test_runners` | **Idle Servers** |
| `TestRunnerFleet` | **Server Pool** or **Worker Pool** |
| `TestRunnerSupervisor` | **Dispatcher** or **Scheduler** |
| `TestRunnerAssignment` | **Dispatch** (the act of assigning a job to a server) |
| `scale()` | **Auto-scaling** or **Capacity Management** |
| orphaned assignments | **Timeout** / **Dead Letter** handling |

## Possible Renames

- `TestRunnerSupervisor` -> `Dispatcher` or `Scheduler`
- `TestRunOrchestrationCheck` -> `QueueState` or `SystemState`
- `unassigned_runs` -> `job_queue` or just `queue`
- `available_test_runners` -> `idle_workers`
- `TestRunnerFleet` -> `WorkerPool`

## Architecture Note

Current system uses a **push-based dispatcher** (supervisor assigns jobs to workers).

For workers to select specific jobs, would need to change to a **pull-based model**
where workers pull jobs from the queue with filters (competing consumers pattern).
