## Bugs
- New commits don't always show up at the top of the list
- Flash message shows up in Settings even when it has nothing to do with settings
- Don't allow adding same repo twice
- If you're on the Overview tab when the test suite run finishes, the Overview tab doesn't update
- Newer test suite runs sometimes show up behind older ones
- Sometimes, in the system logs, autoscrolling mysteriously stops working
- Each deploy causes a 503 blip
- When restarting a retry, it should only run the retry's tests, but instead it runs all the tests
- Retry limit missing or not working

## Defects
- Precompile happens for every deployment
- In the beginning of a test suite, the horizontal scroll bar gets pushed down in an ugly way
- Raw errors don't show up on the Overview tab

## Missing features
- User that triggered a test suite run should get an email once it finishes
- Put repository name in HTML title
- Flash message after settings change
- Tab with concatenated system logs and test output
- Some sort of immediate feedback when a test suite run is started
- Typeahead for branch filtering
- On each tasks's tab, show an icon for whether it's running or finished
- Test suite runs should link to the GitHub page for that commit so the changes can easily be seen
- When a test suite run says "Failed" it should say e.g. "Failed (2)"
- When on a list (such as test suite runs or test cases), up and down keys should move the cursor to the next/previous item
- On each task tab, list somewhere how many test cases it has
- When a task has finished running, show the elapsed time

## Infrastructure
- Monitoring and alerts for worker fleet
- Monitoring for registry disk space
- Replace "saturn" with "saturnci" in Kubernetes deployment files (deployment.yaml, secrets.yaml, service.yaml, etc.)

## Administration
- Send email when a new user signs up

## Performance
- Clicking among test suite runs is too slow

## Setup
- Ability to run SaturnCI env locally without modifying config/database.yml
- Documentation for how to run SaturnCI env locally

## Test runner management
- Easy way to see error for a test runner
- Ability to manipulate test runner pool via CLI

## Development environment
- Linting

## Misc
- Ability to delete/archive repositories (put in Settings)
- In system log or something, list runner name and id

----------------------------------------------------------------

## Finished
- Impersonation doesn't work if user's GitHub token is expired
- When you scroll up on the logs, it should stop auto-scrolling you
