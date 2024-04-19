# Try to execute git command to get the commit hash
# If we can't do that, try to use the hash from environment variable
# If we still can't do that, use the current date as the hash
if [ -d .git ]; then
  COMMIT_HASH=$(git rev-parse --short HEAD)
  if [ -z "$COMMIT_HASH" ]; then
    COMMIT_HASH=$GIT_COMMIT_HASH
  fi
else
  COMMIT_HASH=$GIT_COMMIT_HASH
fi

if [ -z "$COMMIT_HASH" ]; then
  COMMIT_HASH=$(date +%Y%m%d%H%M%S)
fi

echo $COMMIT_HASH
