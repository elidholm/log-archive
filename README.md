# 📁 Log Archive Tool

A simple command-line utility for archiving log files with timestamp-based naming and compression.

## 🌟 Features

- Archive logs from any directory with date and time stamps
- Compress logs into tar.gz format for efficient storage
- Maintain a log history of all archiving operations
- Configure retention policies to automatically clean up old archives
- Save your configuration for repeated use

## 🛠️ Installation

### Prerequisites

- Bash shell environment (Linux/Unix/macOS)

### Installation Steps

#### Download Only the Script

1. Download the script:
   ```bash
   curl -O https://raw.githubusercontent.com/elidholm/log-archive/main/src/log-archive
   ```
2. Make the script executable:
   ```bash
   chmod +x log-archive
   ```

#### Download Repo

1. Clone the repository:
   ```bash
   git clone https://github.com/elidholm/log-archive.git
   cd log-archive
   ```

2. Make the script executable:
   ```bash
   chmod +x src/log-archive
   ```

3. Make test scripts executable (optional):
   ```bash
   chmod +x tests/test_archive.sh
   ```

4. Install it to your system path (optional):
   ```bash
   sudo ln -s $(pwd)/src/log-archive /usr/local/bin/log-archive
   ```

## 📋 Usage

### Basic Usage

```bash
log-archive /var/log
```

This will archive the `/var/log` directory to `~/.local/share/log-archives/logs_archive_YYYYMMDD_HHMMSS.tar.gz`.

### Options

```
Usage: log-archive [OPTIONS] <log-directory>

Archive logs with timestamp.

Options:
  -h, --help            Show this help message and exit
  -a DIR                Directory to store archives (default: ~/.local/share/log-archives)
  -r DAYS               Number of days to keep local archives (default: 30)
  -e PATTERN            Exclude files matching pattern
  -c FILE               Use custom config file (default: ~/.config/log-archive.conf)
  -s, --save-config     Save current configuration as default config
```

### Example Commands

Archive logs with a custom destination directory:
```bash
log-archive -a /backup/logs /var/log
```

Archive logs with a 60-day retention policy:
```bash
log-archive -r 60 /var/log
```

Exclude certain files from the archive:
```bash
log-archive -e "*.tmp" /var/log
```

Save your configuration for future use:
```bash
log-archive -a /backup/logs --save-config /var/log
```

## ⚙️ Configuration

The tool can be configured using a configuration file. By default, the configuration file is located at `~/.config/log-archive.conf`.

Create a configuration file:
```bash
log-archive --save-config [other options] <log-directory>
```

Use a custom configuration file:
```bash
log-archive --config /path/to/config.conf <log-directory>
```

## 🔄 Scheduling with Cron

To run the tool automatically on a schedule, add an entry to your crontab:

```bash
crontab -e
```

Add a line like the following to run the tool daily at 2 AM:

```
0 2 * * * /usr/local/bin/log-archive /var/log
```

## 🔍 Examples

### Basic Log Archiving

```bash
log-archive /var/log
```

This will:
1. Create a compressed archive named `logs_archive_YYYYMMDD_HHMMSS.tar.gz`
2. Store it in `~/.local/share/log-archives/`
3. Record the archive operation in `~/.local/share/log-archives/archive_log.aof`

### Archive with Custom Retention

```bash
log-archive -r 90 /var/log
```

This performs the basic archiving operation and cleans up archives older than 90 days.

## 📦 Project Structure

```
log-archive/
├── .github/             # GitHub-specific files
│   └── workflows/       # GitHub Actions workflows
├── src/                 # Source code directory
│   └── log-archive      # Main script
├── tests/               # Test scripts
│   └── test_archive.sh  # Test cases
├── README.md            # This file
└── LICENSE              # License information
```

## 📜 License

This project is licensed under the Apache License 2.0. See the [LICENSE](LICENSE) file for details.

## 🔗 Project URL

<https://roadmap.sh/projects/log-archive-tool>

## 🤝 Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'feat: Add some amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request
