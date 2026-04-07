# How to Merge Claude Branches into Main

## Current Branch

**Branch:** `claude/complete-mobile-flutter-roadmap-Mtlsz`

**Changes:**
- Fixed home screen "Recent Reports" — now orders accepted reports by `reviewedAt` (acceptance date) instead of `reportedAt` (submission date), so recently accepted reports always appear first
- Removed the 7-day in-memory filter that was hiding reports accepted long after submission

---

## Merge Steps

```bash
# 1. Fetch the latest main branch from remote
git fetch origin main

# 2. Fetch the Claude feature branch from remote
git fetch origin claude/complete-mobile-flutter-roadmap-Mtlsz

# 3. Switch to your local main branch
git checkout main

# 4. Pull the latest main so you're up to date
git pull origin main

# 5. Merge the Claude branch into main
git merge origin/claude/complete-mobile-flutter-roadmap-Mtlsz

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
git branch -d claude/complete-mobile-flutter-roadmap-Mtlsz

# Delete remote branch
git push origin --delete claude/complete-mobile-flutter-roadmap-Mtlsz
```

---

## Previous Branches (already merged or pending)

| Branch | Description |
|--------|-------------|
| `claude/email-system-documentation-01SQSwtB1tC5U2Y8sWGN885E` | Email system fix - updated API endpoint domain |
| `claude/review-detection-mechanism-O35UP` | Lint fixes, model switch to unified model, removed legacy models |
| `claude/annotation-confidence-display-qCMDU` | Always mask detection confidence with fake 10-30% values |
