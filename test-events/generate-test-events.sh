#!/bin/bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
mkdir -p "$SCRIPT_DIR"

echo "🧪 Generating Alexa test payloads..."

# ModeController payloads
for mode in waiting coming leaving away home travel; do
  cat > "$SCRIPT_DIR/setmode-${mode}.json" <<EOF
{
  "directive": {
    "header": {
      "namespace": "Alexa.ModeController",
      "name": "SetMode",
      "instance": "TravelState",
      "messageId": "msg-${mode}",
      "correlationToken": "token-xyz",
      "payloadVersion": "3"
    },
    "endpoint": {
      "endpointId": "switchtracker-device-id"
    },
    "payload": {
      "mode": "${mode^}"
    }
  }
}
EOF
  echo "✅ Created: setmode-${mode}.json"
done

# Discovery payload
cat > "$SCRIPT_DIR/discovery.json" <<EOF
{
  "directive": {
    "header": {
      "namespace": "Alexa.Discovery",
      "name": "Discover",
      "messageId": "msg-discovery",
      "payloadVersion": "3"
    },
    "payload": {
      "scope": {
        "type": "BearerToken",
        "token": "access-token-from-skill"
      }
    }
  }
}
EOF
echo "✅ Created: discovery.json"

# TurnOn payload
cat > "$SCRIPT_DIR/turnon.json" <<EOF
{
  "directive": {
    "header": {
      "namespace": "Alexa.PowerController",
      "name": "TurnOn",
      "messageId": "msg-turnon",
      "correlationToken": "token-xyz",
      "payloadVersion": "3"
    },
    "endpoint": {
      "endpointId": "switchtracker-device-id"
    },
    "payload": {}
  }
}
EOF
echo "✅ Created: turnon.json"

echo "🎉 All test payloads generated in $SCRIPT_DIR"
