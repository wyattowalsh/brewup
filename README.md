# BrewUp

**Production-grade system software maintenance for macOS**

A flexible, performant, secure, robust, and efficient zsh function for safely updating your macOS system software via Homebrew and related package managers.

---

## Features

| Category | Capabilities |
|----------|-------------|
| **Safety** | Dry-run mode, confirmation prompts, pre-upgrade snapshots, concurrent execution lock |
| **Performance** | Single-pass JSON inventory, batch upgrades, bounded retry with backoff |
| **Scope** | Homebrew formulae/casks, npm globals, pip/pipx, gem, Mac App Store[^1] |
| **Configuration** | CLI flags > environment variables > config file (in precedence order) |
| **Logging** | Human-readable logs + structured JSONL events, configurable retention |
| **Output** | Multiple themes (emoji, classic, minimal, none), quiet/verbose modes |
| **macOS** | Quarantine/Gatekeeper pre-flight checks, App Management awareness |
| **Automation** | `--yes`, `--json`, `--quiet` flags for CI/scripted use |

[^1]: Requires `mas` CLI for App Store updates: `brew install mas`

---

## Quick Start

```bash
# Preview what would be upgraded
brewup plan

# Full maintenance run (update → upgrade → cleanup)
brewup

# Fast batch upgrade without prompts
brewup --batch -y

# Include all package managers
brewup --all
```

---

## Installation

<details>
<summary><strong>Step 1: Create the functions directory</strong></summary>

```bash
mkdir -p ~/.zsh/functions
```

</details>

<details>
<summary><strong>Step 2: Download brewup</strong></summary>

**Option A: Direct download**
```bash
curl -fsSL https://raw.githubusercontent.com/wyattowalsh/brewup/main/brewup \
  -o ~/.zsh/functions/brewup
```

**Option B: Clone repository**
```bash
git clone https://github.com/wyattowalsh/brewup.git
cp brewup/brewup ~/.zsh/functions/
```

</details>

<details>
<summary><strong>Step 3: Add to your .zshrc</strong></summary>

```zsh
# Ensure functions directory is in fpath
fpath=(~/.zsh/functions $fpath)

# Autoload the brewup function
if [[ -f ~/.zsh/functions/brewup ]]; then
    autoload -Uz brewup

    # Optional aliases
    alias bu='brewup'
    alias brewplan='brewup plan'
    alias brewfast='brewup --batch -y'
fi
```

</details>

<details>
<summary><strong>Step 4: Reload shell</strong></summary>

```bash
source ~/.zshrc
# or
exec zsh
```

</details>

<details>
<summary><strong>Step 5: Verify installation</strong></summary>

```bash
brewup --help
```

</details>

---

## Usage

### Subcommands

| Subcommand | Description |
|------------|-------------|
| `plan` | Show what would be upgraded (dry-run) |
| `run` | Full maintenance: update → upgrade → cleanup → summary **(default)** |
| `update` | Only run `brew update` |
| `upgrade` | Only upgrade packages (skip brew update) |
| `doctor` | Run `brew doctor` |
| `summary` | Show path to last log + recent entries |
| `report` | Generate formatted report (md/text/json) |
| `config` | Show current configuration |
| `rollback` | Rollback a package to previous version |

### Common Workflows

<details>
<summary><strong>Preview Changes (Safe Mode)</strong></summary>

```bash
brewup plan
# or
brewup --dry-run
```

Shows exactly what would be upgraded without making changes.

</details>

<details>
<summary><strong>Standard Maintenance Run</strong></summary>

```bash
brewup
```

Performs the complete maintenance flow:
1. Collect inventory of outdated packages
2. Display upgrade plan
3. Prompt for confirmation
4. Create pre-upgrade snapshot
5. Upgrade formulae and casks
6. Run cleanup
7. Display summary

</details>

<details>
<summary><strong>Fast Unattended Upgrade</strong></summary>

```bash
brewup --batch -y
```

Uses Homebrew's batch upgrade mode (single command) and skips confirmation.

</details>

<details>
<summary><strong>Include All Package Managers</strong></summary>

```bash
brewup --all
```

Updates Homebrew packages plus npm globals, pipx, gems, and App Store apps.

</details>

<details>
<summary><strong>Interactive Selection</strong></summary>

Requires [fzf](https://github.com/junegunn/fzf):

```bash
brewup -i
# or
brewup --interactive
```

Select which packages to upgrade using fuzzy finder.

</details>

<details>
<summary><strong>Rollback a Package</strong></summary>

```bash
brewup --rollback=node
```

Interactive prompt to rollback a specific package to a previous version.

</details>

### CLI Reference

<details>
<summary><strong>Package Selection Flags</strong></summary>

| Flag | Description |
|------|-------------|
| `--formula-only` | Only upgrade formulae |
| `--cask-only` | Only upgrade casks |
| `--brew-only` | Only Homebrew (skip npm/pip/gem/mas) |
| `--npm`, `--with-npm` | Include npm global packages |
| `--pip`, `--with-pip` | Include pip/pipx packages |
| `--gem`, `--with-gem` | Include gem packages |
| `--mas`, `--with-mas` | Include Mac App Store apps |
| `--all`, `-a` | Include all package managers |

</details>

<details>
<summary><strong>Homebrew Options</strong></summary>

| Flag | Description |
|------|-------------|
| `--no-greedy` | Don't use `--greedy` for cask upgrades |
| `--skip-auto-update` | Skip casks with `auto_updates: true` |
| `--upgrade-pinned` | Temporarily unpin → upgrade → re-pin |
| `--leave-unpinned` | Don't re-pin after upgrading pinned |

</details>

<details>
<summary><strong>Behavior Flags</strong></summary>

| Flag | Description |
|------|-------------|
| `--no-cleanup` | Skip `brew cleanup` after upgrade |
| `--doctor` | Run `brew doctor` at the end |
| `--dry-run` | Plan only; do not perform upgrades |
| `--batch` | Use batch upgrade (single brew call) |
| `--interactive`, `-i` | Select packages interactively (requires fzf) |
| `--force-update` | Force `brew update` (normally implicit) |
| `--no-lock` | Skip concurrent execution lock |
| `--no-parallel` | Disable parallel operations |
| `--no-health-check` | Skip pre-flight health checks |

</details>

<details>
<summary><strong>Output Flags</strong></summary>

| Flag | Description |
|------|-------------|
| `--json` | Emit JSONL event log to stdout |
| `--theme=<t>` | `emoji` \| `classic` \| `minimal` \| `none` |
| `--report=<fmt>` | `md` \| `text` \| `json` |
| `--verbose`, `-v` | Verbose output |
| `--quiet`, `-q` | Minimal output |
| `--no-color` | Disable ANSI colors |

</details>

<details>
<summary><strong>Other Flags</strong></summary>

| Flag | Description |
|------|-------------|
| `--yes`, `-y` | Don't prompt for confirmation |
| `--rollback=<pkg>` | Rollback a specific package |
| `--log-dir=<path>` | Override log directory |
| `--log-retention=<days>` | Days to keep old logs (default: 30) |
| `-h`, `--help` | Show help |

</details>

---

## Configuration

BrewUp loads configuration from three sources (highest precedence first):

| Priority | Source | Example |
|----------|--------|---------|
| 1 | CLI flags | `brewup --theme=minimal` |
| 2 | Environment variables | `export BREWUP_THEME="minimal"` |
| 3 | Config file | `~/.config/brewup/config` |

### Config File

Create `~/.config/brewup/config`:

```ini
# Visual theme: emoji | classic | minimal | none
theme = emoji

# Log retention in days
log_retention = 30

# Skip casks that have auto_updates: true
skip_auto_update = true

# Use batch upgrade mode
batch = false

# Include additional package managers
npm = false
pip = false
gem = false
mas = false

# Or enable all at once
# all = true
```

### Environment Variables

```bash
# In ~/.zshrc or ~/.zshenv
export BREWUP_THEME="minimal"
export BREWUP_SKIP_AUTO_UPDATE="1"
export BREWUP_ALL="1"      # Include all package managers
export BREWUP_YES="1"      # Skip prompts
export BREWUP_QUIET="1"    # Minimal output
```

<details>
<summary><strong>All Environment Variables</strong></summary>

| Variable | Description |
|----------|-------------|
| `BREWUP_THEME` | Output theme |
| `BREWUP_LOG_DIR` | Custom log directory |
| `BREWUP_LOG_RETENTION` | Days to keep logs |
| `BREWUP_NO_GREEDY` | Disable greedy cask upgrades |
| `BREWUP_SKIP_AUTO_UPDATE` | Skip auto-updating casks |
| `BREWUP_BATCH` | Use batch mode |
| `BREWUP_VERBOSE` | Verbose output |
| `BREWUP_QUIET` | Minimal output |
| `BREWUP_NO_COLOR` | Disable colors |
| `BREWUP_YES` | Skip confirmations |
| `BREWUP_NPM` | Include npm globals |
| `BREWUP_PIP` | Include pip/pipx |
| `BREWUP_GEM` | Include gems |
| `BREWUP_MAS` | Include App Store |
| `BREWUP_ALL` | Include all managers |

</details>

---

## Logging

### Log Locations

| Platform | Default Location |
|----------|------------------|
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

<details>
<summary><strong>JSONL Event Format</strong></summary>

```json
{"ts":"2025-12-07T14:30:00-0500","event":"session_start"}
{"ts":"2025-12-07T14:30:05-0500","type":"formula","name":"node","action":"upgraded"}
{"ts":"2025-12-07T14:30:10-0500","type":"cask","name":"firefox","action":"upgraded"}
{"ts":"2025-12-07T14:30:15-0500","type":"formula","name":"python@3.12","action":"skip","reason":"pinned"}
{"ts":"2025-12-07T14:30:20-0500","event":"session_end","upgraded":2,"failed":0}
```

</details>

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

---

## Pre-flight Checks

BrewUp performs safety checks before upgrading:

| Check | Description |
|-------|-------------|
| **Concurrent Lock** | Prevents multiple brewup instances from running simultaneously |
| **Disk Space** | Warns if available space is below 1GB |
| **Network** | Verifies connectivity to github.com |
| **Permissions** | Checks if Homebrew Cellar is writable |
| **Quarantine** | macOS 13+: Notes App Management permission requirements |

Bypass health checks with `--no-health-check` (not recommended).

---

## Pre-upgrade Snapshots

Before any upgrades, brewup saves the current state:

```bash
cat ~/Library/Logs/brewup/2025-12-07_14-30-00.snapshot
```

Use this to identify changes or manually rollback:

```bash
brew install node@21.4.0
```

---

## Themes

| Theme | Example Output |
|-------|----------------|
| **emoji** (default) | `[ok] node upgraded` |
| **classic** | `[+] node upgraded` |
| **minimal** | `[OK] node upgraded` |
| **none** | `node upgraded` |

---

## CI/CD Integration

<details>
<summary><strong>GitHub Actions</strong></summary>

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
          curl -fsSL https://raw.githubusercontent.com/wyattowalsh/brewup/main/brewup \
            -o ~/.zsh/functions/brewup

      - name: Run brewup
        run: |
          source ~/.zsh/functions/brewup
          brewup --batch -y --json --quiet
```

</details>

<details>
<summary><strong>Cron Job</strong></summary>

```bash
# Add to crontab -e
0 6 * * * /bin/zsh -c 'source ~/.zsh/functions/brewup && brewup --batch -y --quiet' >> ~/Library/Logs/brewup-cron.log 2>&1
```

</details>

---

## Troubleshooting

<details>
<summary><strong>"Another brewup instance is running"</strong></summary>

```bash
# Check for stale lock
ls -la /tmp/brewup.lock

# Remove if stale
rm /tmp/brewup.lock

# Or bypass lock (use cautiously)
brewup --no-lock
```

</details>

<details>
<summary><strong>Cask upgrade fails with quarantine error</strong></summary>

1. Open **System Settings → Privacy & Security → App Management**
2. Add your terminal app (Terminal, iTerm2, etc.)
3. Retry: `brewup --cask-only`

</details>

<details>
<summary><strong>"jq not found" warning</strong></summary>

Install jq for better inventory performance:

```bash
brew install jq
```

BrewUp works without jq but uses less efficient text parsing.

</details>

<details>
<summary><strong>Interactive mode not working</strong></summary>

Install fzf:

```bash
brew install fzf
```

</details>

---

## Requirements

| Requirement | Notes |
|-------------|-------|
| **zsh 5.8+** | Uses `zsh/datetime`, `zsh/system` modules |
| **Homebrew 4.0+** | Recommended for full compatibility |
| **macOS 13+** | Optimized for macOS 26 (Tahoe) |

### Optional Dependencies

| Package | Purpose |
|---------|---------|
| `jq` | Faster JSON-based inventory collection |
| `fzf` | Interactive package selection mode |
| `mas` | Mac App Store updates |
| `pipx` | Python package management (preferred over pip) |

---

## Comparison

| Feature | brewup | `brew upgrade` | brew-cask-upgrade |
|---------|--------|----------------|-------------------|
| Dry-run preview | Yes | No | Yes |
| Batch mode | Yes | Yes | No |
| Skip auto-update casks | Yes | No | Yes |
| Pinned formula handling | Yes | No | N/A |
| Interactive selection | Yes | No | No |
| JSONL logging | Yes | No | No |
| Pre-upgrade snapshots | Yes | No | No |
| Concurrent lock | Yes | No | No |
| Config file | Yes | No | No |
| Retry with backoff | Yes | No | No |
| npm/pip/gem/mas | Yes | No | No |

---

## Development

```bash
# Clone
git clone https://github.com/wyattowalsh/brewup.git
cd brewup

# Test locally
source ./brewup
brewup --help

# Run with verbose output
brewup --verbose plan
```

---

## License

MIT License — see [LICENSE](LICENSE) for details.

---

## Acknowledgments

- [Homebrew](https://brew.sh/) — The missing package manager for macOS
- [brew-cask-upgrade](https://github.com/buo/homebrew-cask-upgrade) — Inspiration for cask handling
- [fzf](https://github.com/junegunn/fzf) — Fuzzy finder for interactive mode
- [mas](https://github.com/mas-cli/mas) — Mac App Store CLI
