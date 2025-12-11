# Active test suite run bug

I can reproduce this bug quite consistently now. Instructions:

1. Select some test suite run (for example, the first or second item in the list)
2. Perform a git push
3. Let the new test suite run load
4. Wait no more than about 10 seconds
5. Refresh the page
6. Observe that now no test suite run is selected

If you wait more than 10 seconds or so, the bug will not be reproducible.
