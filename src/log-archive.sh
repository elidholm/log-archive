#!/usr/bin/env bash

# log-arhive - A tool to archive logs from CLI with date- and timestamps
# Author: Edvin Lidholm
# Date: 2025-04-25

set -eo pipefail

# Default values
DEFAULT_CONFIG_FILE="${XDG_CONFIG_HOME:-${HOME}/.config}/log-archive.conf"
DEFAULT_ARCHIVE_DIR="${XDG_DATA_HOME:-${HOME}/.local/share}/log-archives"

# Text colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

print_usage() {
  cat <<EOF

Usage: ${0##*/} [OPTIONS] <log-directory>

Options:
  -h, --help            Show this help message and exit
  -a DIR                Directory to store archives (default: ${DEFAULT_ARCHIVE_DIR})
  -c LEVEL              Compression level (1-9, default: 6)
  -r DAYS               Number of days to keep local archives (default: 30)
  -e PATTERN            Exclude files matching pattern
  -f FILE               Use custom config file (default: ${DEFAULT_CONFIG_FILE})
  -s, --save-config     Save current configuration as default config

Examples:
  ${0##*/} -a /backup/logs /var/log
  ${0##*/} -r 60 /var/log

EOF
}

print_help() {
  echo "This is a CLI for archiving logs with timestamp."
  print_usage
  exit 0
}

log_message() {
  echo -e "${BLUE}[$(date '+%Y-%m-%d %H:%M:%S')]${NC} $1"
}

success() {
  echo -e "${GREEN}[$(date '+%Y-%m-%d %H:%M:%S')] $1${NC}"
}

warning() {
  echo -e "${YELLOW}[$(date '+%Y-%m-%d %H:%M:%S')] Warning: $1${NC}" >&2
}

error() {
  echo -e "${RED}[$(date '+%Y-%m-%d %H:%M:%S')] Error: $1${NC}" >&2
  exit 1
}

load_config() {
  if [[ -f "$CONFIG_FILE" ]]; then
    # shellcheck source=/dev/null
    . "$CONFIG_FILE"
    log_message "Loaded configuration from $CONFIG_FILE"
  fi
}

save_config() {
  cat > "$CONFIG_FILE" <<EOF
# Log Archive Tool Configuration
# Generated on $(date '+%Y-%m-%d %H:%M:%S')
ARCHIVE_DIR="$ARCHIVE_DIR"
COMPRESSION_LEVEL="$COMPRESSION_LEVEL"
RETENTION_DAYS="$RETENTION_DAYS"
EXCLUDE_PATTERN="$EXCLUDE_PATTERN"
EOF
  chmod 600 "$CONFIG_FILE"
  success "Saved configuration to $CONFIG_FILE"
}

initialize_defaults() {
  ARCHIVE_DIR="$DEFAULT_ARCHIVE_DIR"
  CONFIG_FILE="$DEFAULT_CONFIG_FILE"
  COMPRESSION_LEVEL=6
  RETENTION_DAYS=30
  EXCLUDE_PATTERN=""
  SAVE_CONFIG=false
}

parse_arguments() {
  OPTSTRING=":ha:c:r:e:f:-:s"
  while getopts ${OPTSTRING} opt; do
    case ${opt} in
      h)
        print_help
        ;;
      a)
        ARCHIVE_DIR="${OPTARG}"
        ;;
      c)
        COMPRESSION_LEVEL="${OPTARG}"
        ;;
      r)
        RETENTION_DAYS="${OPTARG}"
        ;;
      e)
        EXCLUDE_PATTERN="${OPTARG}"
        ;;
      f)
        CONFIG_FILE="${OPTARG}"
        ;;
      s)
        SAVE_CONFIG=true
        ;;
      -)
        case "${OPTARG}" in
          help)
            print_help
            ;;
          save-config)
            SAVE_CONFIG=true
            ;;
          *)
            error "Invalid option: --${OPTARG}"
            ;;
        esac
        ;;
      :)
        error "Option -${OPTARG} requires an argument."
        ;;
      \?)
        error "Invalid option: -${OPTARG}"
        ;;
    esac
  done
  shift $((OPTIND - 1))

  LOG_DIR="$1"
}

validate_arguments() {
  if [ -z "$LOG_DIR" ]; then
    error "Log directory not specified. Use '${0##*/} --help' for usage information."
  fi

  if [ ! -d "$LOG_DIR" ]; then
    error "Log directory does not exist: $LOG_DIR"
  fi

  if [ "$COMPRESSION_LEVEL" -lt 1 ] || [ "$COMPRESSION_LEVEL" -gt 9 ]; then
    error "Invalid compression level: $COMPRESSION_LEVEL. Must be between 1 and 9."
  fi

  if [ "$RETENTION_DAYS" -lt 1 ]; then
    error "Invalid retention days: $RETENTION_DAYS. Must be at least 1."
  fi
}

archive_logs() {
  local log_dir="$1"
  local timestamp
  timestamp=$(date '+%Y%m%d_%H%M%S')
  local archive_file="$ARCHIVE_DIR/logs_archive_$timestamp.tar.gz"
  local log_file="$ARCHIVE_DIR/archive_log.aof"

  # Create archive directory if it doesn't exist
  mkdir -p "$ARCHIVE_DIR"

  # Check if the log file exists, if not create it
  # and add a header
  if [ ! -f "$log_file" ]; then
    touch "$log_file"
    cat > "$log_file" <<EOF
# Log Archive Tool Archive log
# Generated on $(date '+%Y-%m-%d %H:%M:%S')
# This is an append-only file. Do not edit manually.

EOF
  fi

  # Log the archiving process
  log_message "Archiving logs from $log_dir to $archive_file"
  echo "$(date '+%Y-%m-%d %H:%M:%S') - Archived $log_dir to $archive_file" >> "$log_file"

  tar -czf "$archive_file" -C "$(dirname "$log_dir")" "$(basename "$log_dir")"

  success "Archive created: $archive_file"
}

main() {
  initialize_defaults
  load_config
  parse_arguments "$@"
  validate_arguments

  if [ "$SAVE_CONFIG" = true ]; then
    save_config
  fi

  archive_logs "$LOG_DIR"
}

main "$@"
