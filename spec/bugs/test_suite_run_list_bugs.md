# Test suite run list bugs

Facts:

1. If I delete a test suite run and then refresh the page, sometimes
   the just-deleted test suite run reappears in the list. The
   reappeared test suite run will only disappear permanently after
   multiple refreshes.
2. Upon refresh, a recently-finished test suite run's status will
   sometimes briefly switch back to "Running" and then back to
   "Passed". The "Passed" status only sticks after 2+ refreshes.
3. Sometimes, when loading the page, even a test suite run that
   finished a very long time ago will show a status of "Running".
   Refreshing the page >= 1 time restores the status to Passed.
