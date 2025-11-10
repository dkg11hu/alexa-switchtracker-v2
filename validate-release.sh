#!/bin/bash
set -euo pipefail

echo "📦 Validating release snapshot"

# Latest tag
latest_tag=$(git describe --tags --abbrev=0)
echo "🔖 Latest tag: $latest_tag"

# Last commit
last_commit=$(git log -1 --pretty=format:"%h %s (%cd)")
echo "📝 Last commit: $last_commit"

# Lambda last modified
last_modified=$(aws lambda get-function-configuration \
  --function-name SwitchTracker \
  --query 'LastModified' --output text)
echo "🕒 Lambda last modified: $last_modified"

echo "✅ Release snapshot complete"
