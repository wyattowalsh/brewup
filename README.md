# BrewUp

**Production-grade Homebrew maintenance for macOS 26+**

[![zsh](https://img.shields.io/badge/shell-zsh%205.8+-blue.svg)](https://www.zsh.org/)
[![Homebrew](https://img.shields.io/badge/homebrew-5.0+-orange.svg)](https://brew.sh/)
[![macOS](https://img.shields.io/badge/macOS-13+-lightgrey.svg)](https://www.apple.com/macos/)
[![License](https://img.shields.io/badge/license-MIT-green.svg)](LICENSE)

A flexible, performant, secure, robust, and efficient zsh function for safely updating your macOS system software via Homebrew.

## Features

- **🔒 Safe by Default** — Dry-run mode, confirmation prompts, pre-upgrade snapshots
- **⚡ Performance Optimized** — Single-pass JSON inventory, batch upgrades, parallel downloads
- **🛡️ Robust Execution** — Concurrent execution lock, bounded retry with backoff, graceful error handling
- **🎛️ Highly Configurable** — CLI flags, environment variables, config file (in that precedence order)
- **📊 Comprehensive Logging** — Human-readable logs + structured JSONL events
- **🎨 Beautiful Output** — Multiple themes (emoji, classic, minimal, none)
- **🔧 macOS 26+ Ready** — Quarantine/Gatekeeper pre-flight checks, App Management awareness
- **🤖 CI/Automation Friendly** — `--yes`, `--json`, `--quiet` flags for scripted use

## Quick Start

```bash
# Preview what would be upgraded
brewup plan

# Full maintenance run (update → upgrade → cleanup)
brewup

# Fast batch upgrade without prompts
brewup --batch -y
```

## Installation

### 1. Create the functions directory

```bash
mkdir -p ~/.zsh/functions
```

### 2. Download brewup

```bash
curl -fsSL https://raw.githubusercontent.com/your-username/brewup/main/brewup \
  -o ~/.zsh/functions/brewup
```

Or clone the repository:

```bash
git clone https://github.com/your-username/brewup.git
cp brewup/brewup ~/.zsh/functions/
```

### 3. Add to your `.zshrc`

```zsh
# ──────────────────────────────────────────────────────────────────────────────
# BrewUp — Safe Homebrew maintenance
# ──────────────────────────────────────────────────────────────────────────────
# Ensure functions directory is in fpath
fpath=(~/.zsh/functions $fpath)

# Autoload the brewup function
if [[ -f ~/.zsh/functions/brewup ]]; then
    autoload -Uz brewup
    
    # Optional: short alias
    alias bu='brewup'
    
    # Optional: quick commands
    alias brewplan='brewup plan'
    alias brewfast='brewup --batch -y'
fi
```

### 4. Reload your shell

```bash
source ~/.zshrc
# or
exec zsh
```

### 5. Verify installation

```bash
brewup --version
# brewup 2.0.0

brewup --help
```

## Usage

### Subcommands

| Subcommand | Description |
|------------|-------------|
| `plan` | Show what would be upgraded (dry-run) |
| `run` | Full maintenance: update → upgrade → cleanup → summary (**default**) |
| `update` | Only run `brew update` |
| `upgrade` | Only upgrade packages (skip brew update) |
| `doctor` | Run `brew doctor` |
| `summary` | Show path to last log + recent entries |
| `report` | Generate formatted report (md/text/json) |
| `config` | Show current configuration |
| `version` | Show version |

### Common Workflows

#### Preview Changes (Safe Mode)

```bash
brewup plan
# or
brewup --dry-run
```

#### Standard Maintenance Run

```bash
brewup
```

This will:
1. Collect inventory of outdated packages
2. Display upgrade plan
3. Prompt for confirmation
4. Create pre-upgrade snapshot
5. Upgrade formulae and casks
6. Run cleanup
7. Display summary

#### Fast Unattended Upgrade

```bash
brewup --batch -y
```

Uses Homebrew's batch upgrade mode (single command) and skips confirmation.

#### Formulae Only

```bash
brewup --formula-only
```

#### Casks Only (Skip Auto-Updating Apps)

```bash
brewup --cask-only --skip-auto-update
```

#### Interactive Selection

Requires [fzf](https://github.com/junegunn/fzf):

```bash
brewup -i
# or
brewup --interactive
```

#### Upgrade Pinned Formulae

```bash
brewup --upgrade-pinned
# To upgrade and leave unpinned:
brewup --upgrade-pinned --leave-unpinned
```

### All Flags

```
Package Selection
  --formula-only          Only upgrade formulae
  --cask-only             Only upgrade casks
  --no-greedy             Don't use --greedy for cask upgrades
  --skip-auto-update      Skip casks with auto_updates: true
  --upgrade-pinned        Temporarily unpin → upgrade → re-pin
  --leave-unpinned        Don't re-pin after upgrading pinned

Behavior
  --no-cleanup            Skip 'brew cleanup' after upgrade
  --doctor                Run 'brew doctor' at the end
  --dry-run               Plan only; do not perform upgrades
  --batch                 Use batch upgrade (single brew call)
  --interactive, -i       Select packages interactively (requires fzf)
  --force-update          Force 'brew update' (normally implicit)
  --no-lock               Skip concurrent execution lock

Output
  --json                  Emit JSONL event log to stdout
  --theme=<t>             emoji | classic | minimal | none
  --report=<fmt>          md | text | json
  --verbose, -v           Verbose output
  --quiet, -q             Minimal output
  --no-color              Disable ANSI colors

Logging
  --log-dir=<path>        Override log directory
  --log-retention=<days>  Days to keep old logs (default: 30)

Other
  --yes, -y               Don't prompt for confirmation
  -h, --help              Show help
  --version               Show version
```

## Configuration

BrewUp loads configuration from three sources (highest precedence first):

1. **CLI flags** — Always override everything
2. **Environment variables** — Prefix with `BREWUP_`
3. **Config file** — `~/.config/brewup/config`

### Config File

Create `~/.config/brewup/config`:

```ini
# BrewUp Configuration
# All options are optional; shown values are defaults

# Visual theme: emoji | classic | minimal | none
theme = emoji

# Log retention in days
log_retention = 30

# Custom log directory (default: ~/Library/Logs/brewup)
# log_dir = /path/to/logs

# Skip casks that have auto_updates: true
skip_auto_update = false

# Don't use --greedy for cask upgrades
no_greedy = false

# Use batch upgrade mode (faster, less granular)
batch = false

# Always skip confirmation prompts
# yes = false

# Run brew doctor after upgrades
# doctor = false

# Verbose output
# verbose = false

# Quiet mode (minimal output)
# quiet = false
```

### Environment Variables

```bash
# In ~/.zshrc or ~/.zshenv
export BREWUP_THEME="minimal"
export BREWUP_LOG_RETENTION="14"
export BREWUP_SKIP_AUTO_UPDATE="1"
export BREWUP_BATCH="1"
export BREWUP_YES="1"  # Skip prompts
export BREWUP_QUIET="1"
```

## Logging

### Log Locations

| Platform | Default Location |
|----------|-----------------|
| macOS | `~/Library/Logs/brewup/` |
| XDG-compliant | `$XDG_STATE_HOME/brewup/` |
| Fallback | `~/.local/state/brewup/` |

### Log Files

Each run creates timestamped files:

```
~/Library/Logs/brewup/
├── 2025-12-07_14-30-00.log      # Human-readable log
├── 2025-12-07_14-30-00.jsonl    # Structured events (JSONL)
└── 2025-12-07_14-30-00.snapshot # Pre-upgrade package versions
```

### JSONL Event Format

```json
{"ts":"2025-12-07T14:30:00-0500","event":"session_start","version":"2.0.0"}
{"ts":"2025-12-07T14:30:05-0500","type":"formula","name":"node","action":"upgraded"}
{"ts":"2025-12-07T14:30:10-0500","type":"cask","name":"firefox","action":"upgraded"}
{"ts":"2025-12-07T14:30:15-0500","type":"formula","name":"python@3.12","action":"skip","reason":"pinned"}
{"ts":"2025-12-07T14:30:20-0500","event":"session_end","upgraded":2,"failed":0}
```

### Viewing Logs

```bash
# Show recent log entries
brewup summary

# Generate markdown report
brewup report --report=md > report.md

# Generate JSON report
brewup report --report=json | jq .

# Tail live logs
tail -f ~/Library/Logs/brewup/*.log
```

### Log Retention

Old logs are automatically pruned based on `log_retention` setting (default: 30 days).

## Pre-flight Checks

BrewUp performs several safety checks before upgrading:

### Concurrent Execution Lock

Prevents multiple brewup instances from running simultaneously, avoiding race conditions.

```bash
# Bypass if needed (not recommended)
brewup --no-lock
```

### Quarantine Support (macOS 26+)

Checks if your terminal has the required permissions for cask upgrades:

```
⚠️  Quarantine support may be limited.
    If cask upgrades fail, grant 'App Management' permission to Terminal in:
    System Settings → Privacy & Security → App Management
```

### Disk Space

Warns if available disk space is below 2GB.

## Pre-upgrade Snapshots

Before any upgrades, brewup saves the current state:

```bash
# View snapshot
cat ~/Library/Logs/brewup/2025-12-07_14-30-00.snapshot
```

Example snapshot:

```
# BrewUp Pre-Upgrade Snapshot
# Generated: 2025-12-07T14:30:00-0500

## Installed Formulae
node 21.4.0
python@3.12 3.12.1
...

## Installed Casks
firefox 121.0
visual-studio-code 1.85.0
...
```

Use this to identify what changed or to manually rollback:

```bash
brew install node@21.4.0
```

## Themes

### Emoji (default)

```
✅ node upgraded
⚠️  python@3.12 pinned → skipping
❌ rust upgrade failed
```

### Classic

```
✔ node upgraded
⚠ python@3.12 pinned → skipping
✖ rust upgrade failed
```

### Minimal

```
[OK] node upgraded
[!] python@3.12 pinned → skipping
[FAIL] rust upgrade failed
```

### None

No icons, just text.

## CI/CD Integration

### GitHub Actions

```yaml
name: Update Homebrew Packages

on:
  schedule:
    - cron: '0 6 * * 1'  # Weekly on Monday at 6 AM
  workflow_dispatch:

jobs:
  update:
    runs-on: macos-latest
    steps:
      - name: Install brewup
        run: |
          mkdir -p ~/.zsh/functions
          curl -fsSL https://raw.githubusercontent.com/your-username/brewup/main/brewup \
            -o ~/.zsh/functions/brewup

      - name: Run brewup
        run: |
          source ~/.zsh/functions/brewup
          brewup --batch -y --json --quiet
```

### Cron Job

```bash
# Add to crontab -e
0 6 * * * /bin/zsh -c 'source ~/.zsh/functions/brewup && brewup --batch -y --quiet' >> ~/Library/Logs/brewup-cron.log 2>&1
```

## Troubleshooting

### "Another brewup instance is running"

```bash
# Check for stale lock
ls -la /tmp/brewup.lock

# Remove if stale
rm /tmp/brewup.lock

# Or bypass lock (use cautiously)
brewup --no-lock
```

### Cask Upgrade Fails with Quarantine Error

1. Open **System Settings → Privacy & Security → App Management**
2. Add your terminal app (Terminal, iTerm2, etc.)
3. Retry: `brewup --cask-only`

### "jq not found" Warning

Install jq for better inventory performance:

```bash
brew install jq
```

BrewUp works without jq but uses less efficient text parsing.

### Interactive Mode Not Working

Install fzf:

```bash
brew install fzf
```

## Dependencies

### Required

- **zsh 5.8+** — Uses `zsh/datetime`, `zsh/system` modules
- **Homebrew 5.0+** — Recommended for full compatibility
- **macOS 13+** — Optimized for macOS 26 (Tahoe)

### Optional

- **jq** — Faster JSON-based inventory collection
- **fzf** — Interactive package selection mode

## Comparison with Alternatives

| Feature | brewup | `brew upgrade` | brew-cask-upgrade |
|---------|--------|----------------|-------------------|
| Dry-run preview | ✅ | ❌ | ✅ |
| Batch mode | ✅ | ✅ | ❌ |
| Skip auto-update casks | ✅ | ❌ | ✅ |
| Pinned formula handling | ✅ | ❌ | N/A |
| Interactive selection | ✅ | ❌ | ❌ |
| JSONL logging | ✅ | ❌ | ❌ |
| Pre-upgrade snapshots | ✅ | ❌ | ❌ |
| Concurrent lock | ✅ | ❌ | ❌ |
| Config file | ✅ | ❌ | ❌ |
| Retry with backoff | ✅ | ❌ | ❌ |

## Contributing

Contributions are welcome! Please:

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

### Development

```bash
# Clone
git clone https://github.com/your-username/brewup.git
cd brewup

# Test locally
source ./brewup
brewup --help

# Run with verbose output
brewup --verbose plan
```

## Changelog

### v2.0.0

- Complete rewrite with focus on performance and robustness
- Single-pass JSON inventory collection
- Concurrent execution lock
- Pre-upgrade snapshots
- Skip auto-updating casks
- Interactive mode with fzf
- Batch upgrade mode
- Config file support
- JSONL structured logging
- Bounded exponential backoff retry
- macOS 26 Gatekeeper/quarantine checks
- Multiple output themes

### v1.0.0

- Initial release

## License

MIT License — see [LICENSE](LICENSE) for details.

## Acknowledgments

- [Homebrew](https://brew.sh/) — The missing package manager for macOS
- [brew-cask-upgrade](https://github.com/buo/homebrew-cask-upgrade) — Inspiration for cask handling
- [fzf](https://github.com/junegunn/fzf) — Fuzzy finder for interactive mode
