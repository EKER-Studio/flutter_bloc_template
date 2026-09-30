#!/usr/bin/env bash
set -euo pipefail
DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
"$DIR/run_screenshot_target.sh" "integration_test/app_screenshots_test.dart" "${1:-phone}" "${2:-}"
