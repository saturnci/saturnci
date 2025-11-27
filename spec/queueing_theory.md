|---------------------------|--------------|-----------------|----------------|--------------|-------------|-------------|
| Current Name              | Desired Name | Queueing Theory | GitHub Actions | GitLab CI    | Jenkins     | TeamCity    |
|---------------------------|--------------|-----------------|----------------|--------------|-------------|-------------|
| Test runner               | Worker       | Server / Worker | Runner         | Runner       | Agent       | Agent       |
| Run                       | Job          | Job             | Job            | Job          | Build       | Build       |
| Unassigned Runs           | Queue        | Queue           | Queue          | Queue        | Queue       | Queue       |
| Test Runner Fleet         | WorkerPool   | Server Pool     | Runner Group   | Runner Group | Node Pool   | Agent Pool  |
| Dispatcher                | Dispatcher   | Dispatcher      | -              | -            | -           | -           |
| Test Runner Assignment    | Dispatch?    | Dispatch        | -              | -            | -           | -           |
| Available Test Runners    | Idle Workers | Idle Servers    | Idle Runners   | Idle Runners | Idle Agents | Idle Agents |
| TestRunOrchestrationCheck | ?            | Queue State     | -              | -            | -           | -           |
| Orphaned Assignment       | -            | Dead Letter     | -              | -            | -           | -           |
|---------------------------|--------------|-----------------|----------------|--------------|-------------|-------------|
