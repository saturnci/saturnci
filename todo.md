## Bugs
- Can't cancel test suite runs
- Flash message shows up in Settings even when it has nothing to do with settings
- Don't allow adding same repo twice
- If you're on the Overview tab when the test suite run finishes, the Overview tab doesn't update

## Defects
- Fix data model that connects GitHub accounts and users
- When you scroll up on the logs, it should stop auto-scrolling you
- Precompile happens for every deployment
- In the beginning of a test suite, the horizontal scroll bar gets pushed down in an ugly way

## Missing features
- User that triggered a test suite run should get an email once it finishes
- Put repository name in HTML title
- Flash message after settings change
- Tab with concatenated system logs and test output
- Some sort of immediate feedback when a test suite run is started
- Typeahead for branch filtering
- On each runner's tab, show an icon for whether it's running or finished
- Test suite runs should link to the GitHub page for that commit so the changes can easily be seen

## Refactoring
- TestRunOrchestrationCheck is stupid

## Infrastructure
- Monitoring and alerts for test runner fleet

## Administration
- Send email when a new user signs up

## Performance
- Clicking among test suite runs is too slow

## Setup
- Ability to run SaturnCI env locally without modifying config/database.yml

## Test runner management
- Easy way to see error for a test runner
- Ability to manipulate test runner pool via CLI

## Misc
- Ability to delete/archive repositories (put in Settings)
- In system log or something, list runner name and id

----------------------------------------------------------------

## Finished
- Impersonation doesn't work if user's GitHub token is expired
