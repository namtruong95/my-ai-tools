---
description: Run TDD workflow — write failing tests, implement, verify. For bugs, use the Prove-It pattern. Report in Vietnamese to specs/tests/<title>.md
argument-hint: <title or short description of what to test>
---

Invoke the lisa:test-driven-development skill.

## Fixed rules (never override)

- **Always Vietnamese.** Write the test report and the chat summary in Vietnamese (test descriptions, expected behavior, results, Prove-It notes), whatever language the spec, the arguments or the conversation use. Code, test identifiers, file paths, commands and quoted error strings stay verbatim.
- **Never run plannotator.** Do not call `/plannotator`, `/plannotator-annotate`, `/plannotator-last` or the `plannotator` tool, and do not offer them.
- **Fixed output file.** Resolve the repo root with `git rev-parse --show-toplevel` (fall back to the current directory), create `<repo-root>/specs/tests/` if missing, and write the report to:

```
<repo-root>/specs/tests/<title>.md
```

- `<title>` is a short kebab-case slug of `$ARGUMENTS` (lowercase, ASCII, words joined by `-`, no more than about 50 characters). If `$ARGUMENTS` is empty or too vague to name the work, ask for a title first.
- If that file already exists, ask whether to revise it, pick a different title, or abort. Never silently overwrite.
- The report lists: scope, test cases (what each verifies), red/green results, and regressions checked.

## Steps

For new features:
1. Write tests that describe the expected behavior (they should FAIL)
2. Implement the code to make them pass
3. Refactor while keeping tests green

For bug fixes (Prove-It pattern):
1. Write a test that reproduces the bug (must FAIL)
2. Confirm the test fails
3. Implement the fix
4. Confirm the test passes
5. Run the full test suite for regressions

For browser-related issues, also invoke lisa:browser-testing-with-devtools to verify with Chrome DevTools MCP.

Finish by writing the report to `specs/tests/<title>.md` and reporting its path in Vietnamese.
