## Bugs
- Don't allow adding same repo twice
- Flash message shows up in Settings even when it has nothing to do with settings
- Impersonation doesn't work if user's GitHub token is expired

## Defects
- Fix data model that connects GitHub accounts and users
- When you scroll up on the logs, it should stop auto-scrolling you
- Precompile happens for every deployment
- In the beginning of a test suite, the horizontal scroll bar gets pushed down in an ugly way

## Missing features
- Put repository name in HTML title
- Flash message after settings change
- Tab with concatenated system logs and test output
- Some sort of immediate feedback when a test suite run is started

## Administration
- Send email when a new user signs up

## Performance
- Performance improvement: clicking among test suite runs

## Setup
- Ability to run SaturnCI env locally without modifying config/database.yml

## Test runner management
- Easy way to see error for a test runner
- Ability to manipulate test runner pool via CLI

## Misc
- Ability to delete/archive repositories (put in Settings)
- In system log or something, list runner name and id
