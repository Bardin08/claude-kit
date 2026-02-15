---
name: gh-plan
description: Sync plan files to GitHub Issues and Projects using the gh CLI. Creates an epic issue with sub-issues for each task. Used as a tracker adapter by /plan.
---

# GitHub Plan Adapter

Sync a plan file to GitHub Issues (and optionally a GitHub Project). This skill is invoked as a sub-agent by `/plan` — it is not user-invocable directly.

## Prerequisites

- `gh` CLI authenticated (`gh auth status` succeeds)
- Current directory is a git repo with a GitHub remote
- Plan file exists at the path provided in the prompt

## Inputs (provided in sub-agent prompt)

- `PLAN_FILE`: absolute path to the plan file (epic for complex, single file for simple)
- `PROJECT_NUMBER` (optional): GitHub Project number to add issues to

For complex plans, a sibling directory with the same name (minus `.md`) contains detailed task files:
```
.claude/plans/2fa-authentication.md        ← PLAN_FILE (epic)
.claude/plans/2fa-authentication/           ← task directory
    01-okta-sdk-setup.md
    02-keychain-service.md
    ...
```

## Workflow

### 1. Parse the plan file

Read the plan file. Extract from frontmatter:
- `feature` — used as the epic issue title
- `type` — `simple` or `complex`

### 2. Determine repo

```bash
gh repo view --json nameWithOwner -q '.nameWithOwner'
```

### 3. Ensure labels exist

```bash
gh label create epic --description "Parent issue tracking a feature" --color "3B82F6" 2>/dev/null || true
gh label create task --description "Implementation task from a plan" --color "10B981" 2>/dev/null || true
```

### 4. Create the epic issue

Build the epic issue body from the plan file content.

```bash
gh issue create --title "<feature>" --body "<plan body>" --label "epic"
```

Store the returned issue number as `EPIC_NUMBER`.

Get the epic's node ID (needed for the sub-issue API):

```bash
EPIC_NODE_ID=$(gh issue view $EPIC_NUMBER --json id -q '.id')
```

### 5. Create task issues and attach as sub-issues (complex plans only)

Derive the task directory path from PLAN_FILE: strip `.md` extension.

```bash
TASK_DIR="${PLAN_FILE%.md}"
ls "$TASK_DIR"/*.md
```

Read each task file in order (filenames are `NN-slug.md`). For each task:

**a) Create the issue:**

```bash
gh issue create \
  --title "<task title from frontmatter>" \
  --body "<full task file content + dependency info>" \
  --label "task"
```

Include in the body:
- The full task file content (objective, approach, files, acceptance criteria)
- `Parent: #<EPIC_NUMBER>`
- `Depends on: #<issue>, #<issue>` (map task numbers from the frontmatter `depends_on` field to the corresponding created issue numbers)

Store the returned issue number. Get its node ID:

```bash
TASK_NODE_ID=$(gh issue view $TASK_NUMBER --json id -q '.id')
```

**b) Attach as a native sub-issue of the epic:**

```bash
gh api graphql \
  -H "GraphQL-Features: sub_issues" \
  -f query='
    mutation($parentId: ID!, $childId: ID!) {
      addSubIssue(input: { issueId: $parentId, subIssueId: $childId }) {
        subIssue { number title }
      }
    }' \
  -f parentId="$EPIC_NODE_ID" \
  -f childId="$TASK_NODE_ID"
```

This creates a proper parent-child relationship visible in GitHub's UI (the "Sub-issues" section on the epic), not just a `#reference` mention.

**c) Repeat for all task files**, preserving creation order so sub-issues appear in build order.

### 6. Update the epic body with task links

After all sub-issues are attached, update the epic body to include a reference checklist:

```bash
gh issue edit $EPIC_NUMBER --body "<updated body with issue links>"
```

The checklist serves as a readable summary alongside the native sub-issues panel:
```markdown
## Tasks
- [ ] #<issue1> — <task title>
- [ ] #<issue2> — <task title>
```

### 7. Add to GitHub Project (optional)

If `PROJECT_NUMBER` is provided:

```bash
# Get project ID
PROJECT_ID=$(gh api graphql -f query='
  query($owner: String!, $number: Int!) {
    user(login: $owner) {
      projectV2(number: $number) { id }
    }
  }' -f owner="$(gh api user -q '.login')" -F number=$PROJECT_NUMBER -q '.data.user.projectV2.id' 2>/dev/null || \
  gh api graphql -f query='
  query($owner: String!, $number: Int!) {
    organization(login: $owner) {
      projectV2(number: $number) { id }
    }
  }' -f owner="$(echo $REPO | cut -d/ -f1)" -F number=$PROJECT_NUMBER -q '.data.organization.projectV2.id')

# Add epic
gh api graphql -f query='
  mutation($project: ID!, $content: ID!) {
    addProjectV2ItemById(input: {projectId: $project, contentId: $content}) {
      item { id }
    }
  }' -f project="$PROJECT_ID" -f content="$(gh issue view $EPIC_NUMBER --json id -q '.id')"
```

Add each sub-issue to the project as well.

### 8. Delete the plan file and task directory

Only after all issues are created successfully:

```bash
rm "<PLAN_FILE>"
rm -rf "${PLAN_FILE%.md}"   # task directory (complex plans only, if it exists)
```

If any step failed, do NOT delete anything. Report the error and leave files intact so the user can retry.

### 9. Report

Output a summary:
- Epic issue: `#<number>` with link
- Sub-issues created: list with numbers and links
- Project: added to project `#<number>` (or "no project specified")
- Plan file: deleted (or "retained due to errors")
