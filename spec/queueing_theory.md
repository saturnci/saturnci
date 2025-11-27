|---------------------------|-----------------------|----------------|--------------|-------------|-------------|
| Current Name              | Queueing Theory       | GitHub Actions | GitLab CI    | Jenkins     | TeamCity    |
|---------------------------|-----------------------|----------------|--------------|-------------|-------------|
| TestRunner                | Server / Worker       | Runner         | Runner       | Agent       | Agent       |
| Run                       | Job                   | Job            | Job          | Build       | Build       |
| unassigned_runs           | Queue                 | Queue          | Queue        | Queue       | Queue       |
| TestRunnerFleet           | Server Pool           | Runner Group   | Runner Group | Node Pool   | Agent Pool  |
| Dispatcher                | Dispatcher            | -              | -            | -           | -           |
| TestRunnerAssignment      | Dispatch              | -              | -            | -           | -           |
| available_test_runners    | Idle Servers          | Idle Runners   | Idle Runners | Idle Agents | Idle Agents |
| TestRunOrchestrationCheck | Queue State           | -              | -            | -           | -           |
| scale()                   | Auto-scaling          | Auto-scaling   | Auto-scaling | Auto-scaling| Auto-scaling|
| orphaned assignments      | Dead Letter / Timeout | -              | -            | -           | -           |
|---------------------------|-----------------------|----------------|--------------|-------------|-------------|
