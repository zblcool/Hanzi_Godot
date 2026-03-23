#!/usr/bin/env bash
set -euo pipefail

BRANCH="${VERCEL_GIT_COMMIT_REF:-}"

if [[ -z "$BRANCH" ]]; then
  echo "No VERCEL_GIT_COMMIT_REF detected. Allowing build."
  exit 1
fi

case "$BRANCH" in
  main|staging)
    echo "Allowing Vercel build for ${BRANCH}."
    exit 1
    ;;
  *)
    echo "Skipping Vercel build for ${BRANCH}. Only staging and main auto-deploy."
    exit 0
    ;;
esac
