#!/usr/bin/env bash

# ==============================================================================
# Script Name: generate_screenshots.sh
# Description: Orchestrator – generates store screenshot suite for BLoC Blueprint
#              by delegating to modular per-feature generators.
# Supports:
#   android/phone     (1080 x 2400)  -> Medium_Phone
#   android/tablet_7  (800 x 1280)   -> Small_Tablet  (7")
#   android/tablet_10 (2560 x 1600)  -> Medium_Tablet (10")
# Usage:
#   ./scripts/screenshots/generate_screenshots.sh [target|device] [device|locale] [locale]
#   Examples:
#     ./scripts/screenshots/generate_screenshots.sh phone
#     ./scripts/screenshots/generate_screenshots.sh phone pl
#     ./scripts/screenshots/generate_screenshots.sh all en
#     ./scripts/screenshots/generate_screenshots.sh todos phone pl
#     ./scripts/screenshots/generate_screenshots.sh settings phone
# ==============================================================================

set -euo pipefail

GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[0;33m'
RED='\033[0;31m'
NC='\033[0m'

log_info() {
    echo -e "${BLUE}ℹ️  [INFO]${NC} $1"
}

log_step() {
    echo -e "\n${YELLOW}⚙️  [STEP]${NC} $1"
}

log_success() {
    echo -e "${GREEN}✅ [SUCCESS]${NC} $1"
}

log_error() {
    echo -e "${RED}❌ [ERROR]${NC} $1"
}

DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

FEATURE_SCRIPTS=(
    "generate_todos.sh"
    "generate_settings.sh"
)

ARG1="${1:-phone}"
ARG2="${2:-}"
ARG3="${3:-}"

if [[ "$ARG1" == "-h" || "$ARG1" == "--help" ]]; then
    echo "Usage: $0 [target|device] [device|locale] [locale]"
    echo ""
    echo "Generates Google Play Store screenshot suite for BLoC Blueprint."
    echo "Suites:"
    echo "  - todos    (Todo List, Add Todo Dialog, Completed states)"
    echo "  - settings (Settings Screen, Licenses Screen, Theme Dialog)"
    echo ""
    echo "Arguments:"
    echo "  target  all|todos|settings       (optional, default: all features)"
    echo "  device  phone|tablet_7|tablet_10|all  (default: phone)"
    echo "  locale  en|pl                    (default: all supported)"
    echo ""
    echo "Examples:"
    echo "  $0 phone"
    echo "  $0 phone pl"
    echo "  $0 all en"
    echo "  $0 todos phone pl"
    echo "  $0 settings phone"
    exit 0
fi

# Detect whether $ARG1 is a feature target or device
SPECIFIC_TARGET=""
case "$ARG1" in
    todos|settings)
        SPECIFIC_TARGET="$ARG1"
        DEVICE_INPUT="${ARG2:-phone}"
        LOCALE_FILTER="${ARG3:-}"
        ;;
    all)
        if [[ -n "$ARG2" && ("$ARG2" == "phone" || "$ARG2" == "tablet_7" || "$ARG2" == "tablet_10" || "$ARG2" == "all") ]]; then
            DEVICE_INPUT="$ARG2"
            LOCALE_FILTER="$ARG3"
        else
            DEVICE_INPUT="all"
            LOCALE_FILTER="$ARG2"
        fi
        ;;
    *)
        DEVICE_INPUT="$ARG1"
        LOCALE_FILTER="$ARG2"
        ;;
esac

case "$DEVICE_INPUT" in
    phone|tablet_7|tablet_10|all) ;;
    *)
        log_error "Unknown device: $DEVICE_INPUT (expected: phone|tablet_7|tablet_10|all)"
        echo "Usage: $0 [target|device] [device|locale] [locale]"
        exit 1
        ;;
esac

if [[ -n "$LOCALE_FILTER" ]]; then
    case "$LOCALE_FILTER" in
        en|pl) ;;
        *)
            log_error "Unknown locale: $LOCALE_FILTER (expected: en|pl)"
            exit 1
            ;;
    esac
fi

START_TIME=$(date +%s)

log_info "Starting Screenshot Suite..."
log_info "Target: ${SPECIFIC_TARGET:-all} | Devices: $DEVICE_INPUT | Locale: ${LOCALE_FILTER:-all}"

if [[ -n "$SPECIFIC_TARGET" ]]; then
    TARGET_SCRIPT="generate_${SPECIFIC_TARGET}.sh"
    log_step "Feature target: $TARGET_SCRIPT ($DEVICE_INPUT / ${LOCALE_FILTER:-all})"
    if [[ ! -x "$DIR/$TARGET_SCRIPT" ]]; then
        chmod +x "$DIR/$TARGET_SCRIPT"
    fi
    "$DIR/$TARGET_SCRIPT" "$DEVICE_INPUT" "${LOCALE_FILTER:-}"
else
    # In template where one comprehensive test suite captures the full app, run once per device selection:
    "$DIR/run_screenshot_target.sh" "integration_test/app_screenshots_test.dart" "$DEVICE_INPUT" "${LOCALE_FILTER:-}"
fi

# Global verification
log_step "Global Verification (all devices)..."
TOTAL_ALL=$(find screenshots/android -type f -name "*.png" 2>/dev/null | wc -l | tr -d ' ' || echo "0")
log_success "Total Android screenshots across all devices: $TOTAL_ALL"

if [[ -d "screenshots/android" ]]; then
    echo ""
    log_info "Captured screenshots preview:"
    find screenshots/android -type f -name "*.png" | sort | head -n 25
    if [[ "$TOTAL_ALL" -gt 25 ]]; then
        echo "... ($TOTAL_ALL total, truncated)"
    fi
    echo ""
    log_info "Per-device breakdown:"
    for D in phone tablet_7 tablet_10; do
        if [[ -d "screenshots/android/$D" ]]; then
            COUNT=$(find "screenshots/android/$D" -type f -name "*.png" 2>/dev/null | wc -l | tr -d ' ' || echo "0")
            echo "  android/$D: $COUNT"
        fi
    done
fi

END_TIME=$(date +%s)
DURATION=$((END_TIME - START_TIME))

echo -e "\n=============================================================================="
log_success "Full screenshots suite completed in ${DURATION}s (devices: $DEVICE_INPUT, locale: ${LOCALE_FILTER:-all})"
echo -e "=============================================================================="
