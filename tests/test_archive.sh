#!/usr/bin/env bash

# test_archive.sh - Test suite for log-archive tool
# Author: Edvin Lidholm
# Date: 2025-04-25

# Colors for better readability
GREEN='\033[0;32m'
RED='\033[0;31m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Test directory setup
TEST_DIR=$(mktemp -d)
LOG_DIR="$TEST_DIR/logs"
ARCHIVE_DIR="$TEST_DIR/archives"
CONFIG_FILE="$TEST_DIR/test.conf"

# Create test logs directory with sample files
setup_test_env() {
  mkdir -p "$LOG_DIR"

  # Create some sample log files
  echo "Sample log entry 1" > "$LOG_DIR/system.log"
  echo "Sample log entry 2" > "$LOG_DIR/application.log"
  echo "Sample log entry 3" > "$LOG_DIR/access.log"

  # Create subdirectory with logs
  mkdir -p "$LOG_DIR/apache"
  echo "Apache log 1" > "$LOG_DIR/apache/access.log"
  echo "Apache log 2" > "$LOG_DIR/apache/error.log"
}

main() {
  echo -e "${BLUE}==== Starting Log Archive Tool Tests ====${NC}"

  setup_test_env
}

main
