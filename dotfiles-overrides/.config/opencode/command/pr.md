---
description: Create PR with validation and concise description
agent: build
---

# Current Git State

**Current branch:**
!`git branch --show-current`

**Status:**
!`git status`

**Commits since main:**
!`git log main..HEAD --oneline`

**Changes since main:**
!`git diff main...HEAD --stat`

**Detailed diff:**
!`git diff main...HEAD`

---

Create a pull request with proper validation and concise description:

**Tasks:**
- [ ] Verify not on main/master/develop branch (check above)
- [ ] Check branch name follows conventions (feature/*, fix/*, refactor/*, docs/*)
- [ ] Ensure all changes are committed and pushed (check status above)
- [ ] Review commits and changes above
- [ ] Create short PR title following commit message format (imperative, <50 chars)
- [ ] Write concise description: WHY needed + bullet points of changes
- [ ] Link related issues if applicable (Closes #123)
- [ ] Use `gh pr create` with title and description
- [ ] Verify PR creation and share URL

**PR Title Rules:**
- Imperative verb + what + where/context
- Under 50 characters
- No periods, articles ("the", "a"), or filler words
- Be specific, not generic

**PR Title Examples:**
✅ `add user authentication system`
✅ `fix race condition in api client`
✅ `refactor database connection pool`
✅ `remove deprecated auth methods`
✅ `update webpack config for hot reload`
✅ `add dark mode toggle to settings`

❌ `Update the configuration file`
❌ `Fix some issues`
❌ `Add new feature`
❌ `Various improvements`

**Description Rules:**
- Start with WHY this change was needed (1 sentence)
- Use bullet points for overview of WHAT changed
- Keep it concise (3-5 bullets max)
- No headings (Summary, Changes, etc.)
- No obvious details or marketing language
- Casual tone for in-house team
- Example: "Fix race condition causing data corruption during concurrent updates.\n- Updated connection pool to use proper locking\n- Added retry logic for failed transactions\n- Increased timeout for slow queries"
