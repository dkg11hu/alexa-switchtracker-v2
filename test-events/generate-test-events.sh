#!/bin/bash

mkdir -p test-events

# Discovery directive
cat > test-events/discovery.json <<EOF
{
  "directive": {
    "header": {
      "namespace": "Alexa.Discovery",
      "name": "Discover",
      "payloadVersion": "3",
      "messageId": "abc-123"
    },
    "payload": {}
  }
}
EOF

# SetMode directive (Away)
cat > test-events/setmode-away.json <<EOF
{
  "directive": {
    "header": {
      "namespace": "Alexa.ModeController",
      "name": "SetMode",
      "payloadVersion": "3",
      "messageId": "abc-456",
      "correlationToken": "token-xyz"
    },
    "endpoint": {
      "scope": {
        "type": "BearerToken",
        "token": "access-token-from-skill"
      },
      "endpointId": "switchtracker-device-id"
    },
    "payload": {
      "mode": "Away"
    }
  }
}
EOF

# ReportState directive
cat > test-events/reportstate.json <<EOF
{
  "directive": {
    "header": {
      "namespace": "Alexa",
      "name": "ReportState",
      "payloadVersion": "3",
      "messageId": "abc-789",
      "correlationToken": "token-xyz"
    },
    "endpoint": {
      "scope": {
        "type": "BearerToken",
        "token": "access-token-from-skill"
      },
      "endpointId": "switchtracker-device-id"
    },
    "payload": {}
  }
}
EOF

# TurnOn directive
cat > test-events/turnon.json <<EOF
{
  "directive": {
    "header": {
      "namespace": "Alexa.PowerController",
      "name": "TurnOn",
      "payloadVersion": "3",
      "messageId": "abc-321",
      "correlationToken": "token-xyz"
    },
    "endpoint": {
      "scope": {
        "type": "BearerToken",
        "token": "access-token-from-skill"
      },
      "endpointId": "switchtracker-device-id"
    },
    "payload": {}
  }
}
EOF

echo "✅ Test event files created in ./test-events/"
