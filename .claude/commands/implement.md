---
description: Implement changes
allowed-tools: Read, Write, Edit, MultiEdit, Bash, TodoWrite, Grep
---

# Implement $ARGUMENTS

## Phase 1: Understand the request

Search for relevant tests, which serve as executable specifications, to see if they can help you understand the request.

1. If there are any ambiguities in the request, ask the user to clarify.
2. Repeat the request back to the user in your own words and ask if you have the right understanding.
3. If no, repeat from step 1. If yes, proceed.

## Phase 2: Implement the change using TDD

1. Decide on the specifications. (Then check with the user.)
2. Encode the specifications in a test. (Then check with the user.)
3. Run the test and observe the failure.
4. Write just enough code to make the failure go away (NOT enough code to necessarily make the test pass). (Then check with the user.)
5. Repeat from step 3 until the test passes.
6. Check your work. Is there any code that could be removed while still keeping the tests in a passing state? If so, remove it and run the test again.

Always check relevant CLAUDE.md files for patterns and examples.
