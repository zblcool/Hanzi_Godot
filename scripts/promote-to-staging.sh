#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
REMOTE="${REMOTE:-origin}"
SOURCE_BRANCH="${SOURCE_BRANCH:-develop}"
TARGET_BRANCH="${TARGET_BRANCH:-staging}"

cd "$ROOT_DIR"

if [[ -n "$(git status --porcelain --untracked-files=no)" ]]; then
  echo "Tracked worktree changes are present. Commit or stash them before promoting to ${TARGET_BRANCH}."
  exit 1
fi

ORIGINAL_BRANCH="$(git rev-parse --abbrev-ref HEAD)"

ensure_local_branch() {
  local branch="$1"
  local fallback_ref="$2"

  if git show-ref --verify --quiet "refs/heads/${branch}"; then
    return 0
  fi

  if git show-ref --verify --quiet "refs/remotes/${REMOTE}/${branch}"; then
    git branch "${branch}" "${REMOTE}/${branch}"
    return 0
  fi

  git branch "${branch}" "${fallback_ref}"
}

git fetch "$REMOTE"

ensure_local_branch "$SOURCE_BRANCH" "${REMOTE}/${SOURCE_BRANCH}"
ensure_local_branch "$TARGET_BRANCH" "$SOURCE_BRANCH"

git switch "$SOURCE_BRANCH"
git merge --ff-only "${REMOTE}/${SOURCE_BRANCH}"

git switch "$TARGET_BRANCH"
if git show-ref --verify --quiet "refs/remotes/${REMOTE}/${TARGET_BRANCH}"; then
  git merge --ff-only "${REMOTE}/${TARGET_BRANCH}"
fi

git merge --no-ff --no-edit "$SOURCE_BRANCH"
if git rev-parse --abbrev-ref "${TARGET_BRANCH}@{upstream}" >/dev/null 2>&1; then
  git push "$REMOTE" "$TARGET_BRANCH"
else
  git push -u "$REMOTE" "$TARGET_BRANCH"
fi

git switch "$ORIGINAL_BRANCH"

echo "Promoted ${SOURCE_BRANCH} into ${TARGET_BRANCH} and pushed ${REMOTE}/${TARGET_BRANCH}."
