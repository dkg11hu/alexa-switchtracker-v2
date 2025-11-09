#!/bin/bash
set -euo pipefail

echo "📦 Restructuring Alexa SwitchTracker project..."

# Define paths
ROOT_DIR="$(pwd)"
ALEXA_DIR="$ROOT_DIR/alexa-skill"
BACKEND_DIR="$ROOT_DIR/switch-tracker"
FRONTEND_DIR="$ROOT_DIR/switchtracker-ui"

# Create module folders
mkdir -p "$ALEXA_DIR" "$BACKEND_DIR" "$FRONTEND_DIR"

# Move Alexa skill files
mv skill-package "$ALEXA_DIR/"
mv ask-resources.json "$ALEXA_DIR/"
[ -d .ask ] && mv .ask "$ALEXA_DIR/"

# Move backend files
mv lambda_handler.py "$BACKEND_DIR/"
mv utils "$BACKEND_DIR/"
mv requirements.txt "$BACKEND_DIR/"
[ -d .venv ] && mv .venv "$BACKEND_DIR/"
[ -f package-lambda.sh ] && mv package-lambda.sh "$BACKEND_DIR/"

# Move frontend files (if any)
[ -d frontend ] && mv frontend/* "$FRONTEND_DIR/" && rmdir frontend

# Confirm structure
echo "✅ New structure:"
tree -L 2 -I '.git|node_modules|__pycache__'

echo "🧹 Done. Please update your ci.yml, README.md, and CONTRIBUTING.md to reflect the new paths."
