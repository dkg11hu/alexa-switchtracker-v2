#!/bin/bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
LAMBDA_FUNCTION_NAME="${LAMBDA_FUNCTION_NAME:-SwitchTracker}"
mkdir -p "$SCRIPT_DIR/logs"

echo "🧪 Running post-deploy test for SwitchTracker backend"

declare -A expected_modes=(
  ["setmode-away.json"]="Away"
  ["setmode-home.json"]="Home"
  ["setmode-travel.json"]="Travel"
  ["setmode-waiting.json"]="Waiting"
)

payloads=(
  "$SCRIPT_DIR/test-events/setmode-home.json"
  "$SCRIPT_DIR/test-events/reportstate.json"
  "$SCRIPT_DIR/test-events/setmode-travel.json"
  "$SCRIPT_DIR/test-events/reportstate.json"
  "$SCRIPT_DIR/test-events/setmode-waiting.json"
  "$SCRIPT_DIR/test-events/reportstate.json"
  "$SCRIPT_DIR/test-events/setmode-away.json"
  "$SCRIPT_DIR/test-events/reportstate.json"
  "$SCRIPT_DIR/test-events/discovery.json"
  "$SCRIPT_DIR/test-events/turnon.json"
)

last_set_mode=""
final_reported_mode=""

for payload in "${payloads[@]}"; do
  timestamp=$(date +"%Y%m%d-%H%M%S")
  filename=$(basename "$payload")
  expected="${expected_modes[$filename]:-}"

  echo "📨 Invoking Lambda $LAMBDA_FUNCTION_NAME with payload: $payload"
  if [[ ! -f "$payload" ]]; then
    echo "❌ Payload not found: $payload"
    continue
  fi

  aws lambda invoke \
    --function-name "$LAMBDA_FUNCTION_NAME" \
    --payload file://"$payload" \
    --cli-binary-format raw-in-base64-out \
    response.json | tee /dev/null

  jq '.' response.json || echo "⚠️ jq failed to parse response"
  echo "--------------------------------------"

  mode=$(jq -r '.context.properties[]? | select(.name=="mode") | .value' response.json)
  echo "🧪 Mode reported: ${mode:-<none>}"

  jq '.' response.json > "$SCRIPT_DIR/logs/response-${timestamp}-${filename%.json}-${mode:-none}.json"
  echo "$timestamp: Mode reported → ${mode:-<none>} from $payload" >> "$SCRIPT_DIR/logs/mode-summary.log"

  if [[ "$filename" == setmode-* ]]; then
    last_set_mode="$mode"
  fi

  if [[ "$filename" == reportstate.json ]]; then
    final_reported_mode="$mode"
    if [[ -n "$last_set_mode" && "$mode" != "$last_set_mode" ]]; then
      echo "❌ Mode mismatch: expected $last_set_mode, got $mode"
      exit 1
    fi
  fi

  modes=$(jq -r '.event.payload.endpoints[0].capabilities[]? | select(.interface=="Alexa.ModeController") | .configuration.supportedModes[].value' response.json)
  echo "🧪 Modes advertised in discovery: $modes"

  expected_modes=("Home" "Travel" "Waiting" "Away")
  for mode in "${expected_modes[@]}"; do
    if ! grep -q "$mode" <<< "$modes"; then
      echo "❌ Discovery missing mode: $mode"
      exit 1
    fi

done


  rm -f response.json
done

if [[ "$final_reported_mode" == "Away" ]]; then
  echo "✅ Final mode assertion passed: mode is Away"
else
  echo "❌ Final mode assertion failed: expected Away, got $final_reported_mode"
  exit 1
fi

echo "📸 Snapshotting release..."
bash "$SCRIPT_DIR/validate-release.sh"

echo "✅ Post-deploy test complete"
