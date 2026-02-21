<!-- highway:start -->
## Model Routing Policy (managed by highway)

When using the **Task tool**, ALWAYS set the `model` parameter based on task complexity.
Never omit it. Default to `sonnet` when uncertain.

| Complexity | Model    | Use for |
|------------|----------|---------|
| Low        | `haiku`  | File searches, grep, glob, status checks, counting, simple reads, listing |
| Medium     | `sonnet` | Code implementation, debugging, refactoring, API design, test writing, explanations |
| High       | `opus`   | System architecture, security review, complex trade-offs, long-term strategy, multi-system design |

### Examples

```
Task(model="haiku")  → "Find all TypeScript files that import from utils/"
Task(model="haiku")  → "What does the current git status show?"
Task(model="sonnet") → "Implement JWT authentication middleware"
Task(model="sonnet") → "Debug why this API endpoint returns 403"
Task(model="opus")   → "Design the microservices boundary strategy for this monolith migration"
Task(model="opus")   → "Identify all security risks in this authentication system"
```
<!-- highway:end -->
