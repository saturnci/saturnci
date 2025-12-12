# Test Suite Run List Polling

As we complete items on this list, we should move them to a "finished" section.

Remember to follow the TDD instructions described in the /implement command.

We want to make these changes in small, atomic units of work while keeping all
existing features working the whole time. We'll do our work on a series of
feature branches, merging to main and deploying frequently in order to minimize
risk.

## Problem

The test suite run list uses ActionCable/Solid Cable to push updates. With multiple K8s replicas, this causes race conditions where broadcasts are delivered to the wrong page (after a redirect), causing the active selection to be lost.

## Proposed Solution

Replace the push model with periodic polling.

## Requirements

### Core Requirements

1. **New TSRs appear** - When a new test suite run is created (git push, rerun, etc.), it should appear in the list without a page refresh

2. **Status updates appear** - When a TSR changes status (Running → Passed/Failed), the list should reflect it

3. **Active selection preserved** - The currently selected TSR must stay selected after updates

4. **Filters work** - If user has branch/status filters applied, updates should respect them

5. **Scroll position preserved** - Updates shouldn't jump the user to the top

6. **Works with multiple replicas** - Must work reliably regardless of which pod handles requests

### Detailed Decisions

1. **Polling frequency**: 1 second

2. **Infinite scroll items**: Should also get updated, but start with smallest change first

3. **Deleted TSRs**: Should disappear from the list automatically

4. **Tab visibility**: Ultimately pause when hidden, but not for initial implementation

5. **Mid-scroll updates**: Ultimately defer, but not for initial implementation

### Out of Scope (for now)

- `TestSuiteRunLinkComponent.refresh` (status badge broadcasts) - separate concern
- Worker output streaming - different concern
- Tab visibility optimization
- Mid-scroll deferral
