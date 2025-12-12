# Active test suite run bug

I can reproduce this bug quite consistently now, at least on production. The
bug seems not to occur locally. Instructions:

1. Visit a page like
https://app.saturnci.com/runs/5962b5bc-d6e7-44aa-b076-5fb205c2e982/system_logs
but NOT a page like
https://app.saturnci.com/repositories/f60ca0ad-89c8-440e-9373-ed639d2dd662/test_suite_runs/78c1077c-26c5-466b-971a-679e1b205811

2. Select some test suite run (for example, the first or second item in the list)
3. Perform a git push
4. Let the new test suite run load (as in wait for it to appear)
5. Wait no more than about 20 seconds (could be more, I'm not sure)
6. Refresh the page
7. Observe that now no test suite run is selected

If you wait more than 10 seconds or so, the bug will not be reproducible.

A probably-related clue: when I delete a test suite run immediately after it
was created, it often reappears in the list, even though I can't actually click
it since it doesn't actually exist.

Here's another reproduction sequence:

1. Visit a page like
https://app.saturnci.com/repositories/f60ca0ad-89c8-440e-9373-ed639d2dd662/test_suite_runs/f514851d-3084-47a9-8d06-478702716f6b

2. Select some test suite run (for example, the first or second item in the list)
3. Click rerun
4. The following happens:
  1. A new test suite run appears (and it's not selected)
  2. The page refreshes
  3. The new test suite run appears selected
  4. The new test suite run appears unselected

## Notes

I can reproduce this bug quite consistently (although not always) in
production. I have NOT been able to reproduce it even a single time in
development.

The active test suite run is determined by `active_test_suite_run`.
