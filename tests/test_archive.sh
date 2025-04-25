#!/usr/bin/env bash

# test_archive.sh - Test suite for log-archive tool
# Author: Edvin Lidholm
# Date: 2025-04-25

set -o pipefail

# Colors for better readability
GREEN='\033[0;32m'
RED='\033[0;31m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Test directory setup
TEST_DIR=$(mktemp -d)
LOG_DIR="$TEST_DIR/logs"
ARCHIVE_DIR="$TEST_DIR/archives"
TEST_LOG="$TEST_DIR/test.log"
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

cleanup() {
  rm -rf "$TEST_DIR"
  echo -e "${BLUE}Test environment cleaned up${NC}"
}

print_log() {
  while IFS= read -r line; do
    echo -e "  >\t${RED}$line${NC}"
  done < "$TEST_LOG"
}

run_test() {
  local test_name="$1"
  local command="$2"
  local expected_exit_code="$3"

  echo -e "${BLUE}Running test: $test_name${NC}"

  # Execute the command and capture exit code
  eval "$command" > "$TEST_LOG" 2>&1
  exit_code=$?

  if [ "$exit_code" -eq "$expected_exit_code" ]; then
    echo -e "${GREEN}✓ Test passed: ${test_name}${NC}"
    return 0
  else
    echo -e "${RED}✗ Test failed: ${test_name}${NC}"
    echo -e "${RED}  Expected exit code ${expected_exit_code}, got ${exit_code}${NC}"
    echo -e "${RED}  Output from command:${NC}"
    print_log
    return 1
  fi
}

verify_archive() {
  local archive_dir="$1"

  # Check if archive directory exists
  if [ ! -d "$archive_dir" ]; then
    echo -e "${RED}Archive directory does not exist: $archive_dir${NC}"
    return 1
  fi

  # Check if any archives were created
  if [ -z "$(ls -A "$archive_dir" 2>/dev/null)" ]; then
    echo -e "${RED}No archives found in $archive_dir${NC}"
    return 1
  fi

  # Check for log file
  if [ ! -f "$archive_dir/archive_log.aof" ]; then
    echo -e "${RED}Archive log file not found${NC}"
    return 1
  fi

  # Find the latest archive
  latest_archive=$(find "$archive_dir" -name "logs_archive_*.tar.gz" -type f -printf "%T@ %p\n" | sort -n | tail -1 | cut -d' ' -f2-)

  # Check if archive exists
  if [ -z "$latest_archive" ]; then
    echo -e "${RED}No archive file found${NC}"
    return 1
  fi

  # Verify archive contains files
  if ! tar -tzf "$latest_archive" > /dev/null 2>&1; then
    echo -e "${RED}Invalid archive format: $latest_archive${NC}"
    return 1
  fi

  echo -e "${GREEN}✓ Archive successfully created and verified: $latest_archive${NC}"
  return 0
}

main() {
  echo -e "${BLUE}==== Starting Log Archive Tool Tests ====${NC}"

  setup_test_env

  DIR=$(dirname "$0")
  LOG_ARCHIVE_SCRIPT="${DIR}/../src/log-archive"
  chmod +x "$LOG_ARCHIVE_SCRIPT"

  # Test 1: Basic functionality
  run_test "Basic functionality" "$LOG_ARCHIVE_SCRIPT -a $ARCHIVE_DIR $LOG_DIR" 0
  verify_archive "$ARCHIVE_DIR"

  # Test 2: Invalid log directory
  run_test "Invalid log directory" "$LOG_ARCHIVE_SCRIPT -a $ARCHIVE_DIR $LOG_DIR/nonexistent" 1

  # Test 3: Save and use config
  run_test "Save config" "$LOG_ARCHIVE_SCRIPT -a $ARCHIVE_DIR -c $CONFIG_FILE --save-config $LOG_DIR" 0
  run_test "Use config" "$LOG_ARCHIVE_SCRIPT -c $CONFIG_FILE $LOG_DIR" 0

  cleanup

  echo -e "${BLUE}==== All Tests Completed ====${NC}"
}

main
