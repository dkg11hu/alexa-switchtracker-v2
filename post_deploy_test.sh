#!/bin/bash
set -euo pipefail

echo "🧪 Running post-deploy test for SwitchTracker backend"

# Step 1: Seed DynamoDB with known state
bash ./seed-dynamodb.sh

# Step 2: Run ReportState test
echo "🚀 Invoking Lambda with ReportState test payload..."
python -m switch_tracker.app.lambda_function \
  switch_tracker/app/test_payloads/report/event-reportstate.json

# Step 3: Run SetMode test (change to 'travel')
echo "🛠️ Invoking Lambda with SetMode test payload (mode: travel)..."
python -m switch_tracker.app.lambda_function \
  switch_tracker/app/test_payloads/set/event-setmode-travel.json

# Step 4: Re-run ReportState to confirm mode change
echo "🔁 Re-invoking Lambda with ReportState to confirm mode update..."
python -m switch_tracker.app.lambda_function \
  switch_tracker/app/test_payloads/report/event-reportstate.json

echo "✅ Post-deploy test complete"

# Step 5: SetMode to 'home'
echo "🛠️ Invoking Lambda with SetMode test payload (mode: home)..."
python -m switch_tracker.app.lambda_function \
  switch_tracker/app/test_payloads/set/event-setmode-home.json

# Step 6: Confirm mode is 'home'
echo "🔁 Re-invoking Lambda with ReportState to confirm mode update..."
python -m switch_tracker.app.lambda_function \
  switch_tracker/app/test_payloads/report/event-reportstate.json

# Step 7: SetMode to 'waiting'
echo "🛠️ Invoking Lambda with SetMode test payload (mode: waiting)..."
python -m switch_tracker.app.lambda_function \
  switch_tracker/app/test_payloads/set/event-setmode-waiting.json

# Step 8: Confirm mode is 'waiting'
echo "🔁 Re-invoking Lambda with ReportState to confirm mode update..."
python -m switch_tracker.app.lambda_function \
  switch_tracker/app/test_payloads/report/event-reportstate.json

