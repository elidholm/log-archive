#!/usr/bin/env bash

# log-arhive - A tool to archive logs from CLI with date- and timestamps
# Author: Edvin Lidholm
# Date: 2025-04-25

set -euo pipefail

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
  -h, --help                    Show this help message and exit
  -a, --archive-dir DIR         Directory to store archives (default: ${DEFAULT_ARCHIVE_DIR})
  -c, --compress-level LEVEL    Compression level (1-9, default: 6)
  --retention DAYS              Number of days to keep local archives (default: 30)
  --exclude PATTERN             Exclude files matching pattern
  --config FILE                 Use custom config file (default: ${DEFAULT_CONFIG_FILE})
  --save-config                 Save current configuration as default config

Examples:
  ${0##*/} -a /backup/logs /var/log
  ${0##*/} --retention 60 /var/log

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

