#!/bin/bash
set -euo pipefail

echo "🔧 Packaging Python Lambda from ../switch_tracker/app..."

# Resolve absolute path to repo root
ROOT_DIR="$(cd "$(dirname "$0")" && pwd)"
LAMBDA_DIR="$ROOT_DIR/../switch_tracker"
APP_DIR="$LAMBDA_DIR/app"
PACKAGE_DIR="$LAMBDA_DIR/package"
ZIP_FILE="$LAMBDA_DIR/lambda.zip"

# Clean previous build
rm -rf "$PACKAGE_DIR" "$ZIP_FILE"
mkdir -p "$PACKAGE_DIR"

# Use current .venv (already activated)
echo "📦 Installing dependencies into $PACKAGE_DIR..."
pip install -r "$LAMBDA_DIR/requirements.txt" --target "$PACKAGE_DIR"

# Copy source files
echo "📁 Copying source files from $APP_DIR..."
cp -r "$APP_DIR" "$PACKAGE_DIR/"

# Remove __pycache__ and .pyc files
echo "🧹 Cleaning up __pycache__ and .pyc files..."
find "$PACKAGE_DIR" -type d -name "__pycache__" -exec rm -rf {} +
find "$PACKAGE_DIR" -type f -name "*.pyc" -delete


# Zip contents
echo "🗜️ Creating zip at $ZIP_FILE..."
cd "$PACKAGE_DIR"
zip -r9 "$ZIP_FILE" .
cd "$ROOT_DIR"
zip -r9 "$ZIP_FILE" . -x "**/__pycache__/*" "**/*.pyc"


echo "✅ Lambda package created at $ZIP_FILE"

