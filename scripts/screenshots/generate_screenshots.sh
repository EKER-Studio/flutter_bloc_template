#!/usr/bin/env bash

# ==============================================================================
# Script Name: generate_screenshots.sh
# Description: Generates screenshots by delegating to run_screenshot_target.sh
# Usage: ./scripts/screenshots/generate_screenshots.sh [phone|tablet_7|tablet_10|all] [locale]
# ==============================================================================

set -euo pipefail

GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[0;33m'
RED='\033[0;31m'
NC='\033[0m'

DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TEST_TARGET="integration_test/app_screenshots_test.dart"

DEVICE_INPUT="${1:-phone}"
LOCALE_FILTER="${2:-}"

echo -e "${BLUE}ℹ️  [INFO] Generating screenshots for $TEST_TARGET (device: $DEVICE_INPUT, locale: ${LOCALE_FILTER:-all})${NC}"

chmod +x "$DIR/run_screenshot_target.sh"
"$DIR/run_screenshot_target.sh" "$TEST_TARGET" "$DEVICE_INPUT" "${LOCALE_FILTER:-}"

echo -e "${GREEN}✅ [SUCCESS] Screenshot generation complete.${NC}"
