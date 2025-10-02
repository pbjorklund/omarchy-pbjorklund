---
description: Create logical commits with clear messages
agent: build
---

# Current Git State

**Current branch:**
!`git branch --show-current`

**Status:**
!`git status`

**Unstaged changes:**
!`git diff`

**Staged changes:**
!`git diff --cached`

---

Create logical, atomic commits following these guidelines:

**Tasks:**
- [ ] Review the git state above to understand changes
- [ ] Check current branch - if on master/main, ask user if they want to:
  - Create a new feature branch (recommended)
  - Commit directly to master/main (only for hotfixes)
- [ ] If creating new branch, ensure name follows conventions (feature/*, fix/*, refactor/*, docs/*)
- [ ] Group related changes into logical commits
- [ ] Write clear commit messages (imperative, <50 chars, specific)
- [ ] Stage and commit each logical group
- [ ] Push commits to remote

**Branch Strategy:**
- **On master/main?** → Ask user preference:
  - "Create feature branch?" (recommended for new features)
  - "Commit to master?" (only for hotfixes/urgent changes)
- **Branch naming:** feature/description, fix/issue-name, refactor/component, docs/topic

**Commit Message Rules:**
- Imperative verb + what + where/context
- Under 50 characters
- No periods, articles ("the", "a"), or filler words
- Be specific, not generic
- Focus on the change, not the reason (save WHY for PR description)

**Commit Message Examples:**
✅ `add dark mode toggle to settings`
✅ `fix memory leak in file parser`
✅ `remove deprecated auth methods`
✅ `update webpack config for hot reload`
✅ `fix race condition in api client`
✅ `add user profile validation`
✅ `improve query performance`
✅ `update deps for security patches`

❌ `Update the configuration file`
❌ `Fix some issues`
❌ `Add new feature`
❌ `Improve code quality`
❌ `Various improvements`
❌ `fix bug`
