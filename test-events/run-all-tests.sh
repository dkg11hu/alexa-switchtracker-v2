#!/bin/bash

echo "🔍 Running Alexa Smart Home test payloads..."

for file in test-events/*.json; do
  name=$(basename "$file" .json)
  echo "🧪 Testing: $name"
  aws lambda invoke \
    --function-name SwitchTracker \
    --payload file://"$file" \
    "response-$name.json" \
    --output text
  echo "✅ Response saved to response-$name.json"
  echo "----------------------------------------"
done

echo "🎉 All tests completed."
