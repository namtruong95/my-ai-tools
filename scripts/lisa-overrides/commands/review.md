---
description: Conduct a five-axis code review in Vietnamese — correctness, readability, architecture, security, performance
---

Invoke the lisa:code-review-and-quality skill.

## Fixed rules (never override)

- **Always Vietnamese.** Write the whole review in Vietnamese, whatever language the code, the diff, the arguments or the conversation use. Code, file paths, identifiers, commands and quoted error strings stay verbatim.
- **Never run plannotator.** Do not call `/plannotator`, `/plannotator-annotate`, `/plannotator-last` or the `plannotator` tool, and do not offer them.

## Steps

Review the current changes (staged or recent commits) across all five axes:

1. **Correctness (Tính đúng đắn)** — Does it match the spec? Edge cases handled? Tests adequate?
2. **Readability (Khả năng đọc)** — Clear names? Straightforward logic? Well-organized?
3. **Architecture (Kiến trúc)** — Follows existing patterns? Clean boundaries? Right abstraction level?
4. **Security (Bảo mật)** — Input validated? Secrets safe? Auth checked? (Use security-and-hardening skill)
5. **Performance (Hiệu năng)** — No N+1 queries? No unbounded ops? (Use performance-optimization skill)

Categorize findings as **Nghiêm trọng** (Critical), **Quan trọng** (Important), or **Gợi ý** (Suggestion).
Output a structured review in Vietnamese with specific file:line references and fix recommendations.
