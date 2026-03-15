# How to Merge Claude Branches into Main

## Current Branch

**Branch:** `claude/review-detection-mechanism-O35UP`

**Changes:**
- Removed unused `_annotatedImageBytes` field and `dart:typed_data` import in `unified_detection_screen.dart`
- Removed unused `screenHeight` variable in `step_three_screen.dart`

---

## Merge Steps

```bash
# 1. Fetch the latest main branch from remote
git fetch origin main

# 2. Fetch the Claude feature branch from remote
git fetch origin claude/review-detection-mechanism-O35UP

# 3. Switch to your local main branch
git checkout main

# 4. Pull the latest main so you're up to date
git pull origin main

# 5. Merge the Claude branch into main
git merge origin/claude/review-detection-mechanism-O35UP

# 6. Push the updated main to remote
git push origin main
```

---

## What Each Command Does

| Command | What It Does |
|---------|-------------|
| `git fetch origin main` | Downloads the latest `main` from GitHub without changing your local files |
| `git fetch origin claude/...` | Downloads the latest Claude feature branch from GitHub |
| `git checkout main` | Switches your working directory to the `main` branch |
| `git pull origin main` | Updates your local `main` with any new commits from remote |
| `git merge origin/claude/...` | Merges the Claude branch commits into your current branch (`main`) |
| `git push origin main` | Uploads your updated `main` branch to GitHub |

---

## If There Are Merge Conflicts

```bash
# See which files have conflicts
git status

# Open conflicting files, resolve the <<<< ==== >>>> markers
# Then:
git add <resolved-files>
git commit -m "Merge claude branch with conflict resolution"
git push origin main
```

---

## Cleanup (Optional)

After merging, delete the feature branch if you no longer need it:

```bash
# Delete local branch
git branch -d claude/review-detection-mechanism-O35UP

# Delete remote branch
git push origin --delete claude/review-detection-mechanism-O35UP
```

---

## Previous Branches

| Branch | Description |
|--------|-------------|
| `claude/email-system-documentation-01SQSwtB1tC5U2Y8sWGN885E` | Email system fix - updated API endpoint domain |
| `claude/review-detection-mechanism-O35UP` | Lint fixes - removed unused fields and variables |
