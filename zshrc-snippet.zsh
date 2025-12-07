# ==============================================================================
# BrewUp — Safe Homebrew Maintenance
# ==============================================================================
# Add this snippet to your ~/.zshrc
#
# Prerequisites:
#   1. Save brewup to ~/.zsh/functions/brewup (no extension)
#   2. Ensure ~/.zsh/functions exists: mkdir -p ~/.zsh/functions
#
# Optional dependencies:
#   - jq: brew install jq      (faster inventory collection)
#   - fzf: brew install fzf    (interactive mode)
# ==============================================================================

# Ensure the functions directory is in fpath (add before compinit if using OMZ)
# Note: If using Oh-My-Zsh, add this BEFORE sourcing $ZSH/oh-my-zsh.sh
if [[ -d ~/.zsh/functions ]]; then
    fpath=(~/.zsh/functions $fpath)
fi

# Autoload brewup with error handling
if [[ -f ~/.zsh/functions/brewup ]]; then
    autoload -Uz brewup

    # ──────────────────────────────────────────────────────────────────────────
    # Convenience Aliases (optional, uncomment as desired)
    # ──────────────────────────────────────────────────────────────────────────

    # Short alias
    alias bu='brewup'

    # Quick commands
    alias brewplan='brewup plan'                    # Preview upgrades
    alias brewfast='brewup --batch -y'              # Fast unattended upgrade
    alias brewsafe='brewup --dry-run'               # Dry-run mode
    alias brewdoc='brewup doctor'                   # Run brew doctor
    alias brewlog='brewup summary'                  # Show recent log

    # ──────────────────────────────────────────────────────────────────────────
    # Environment Configuration (optional, uncomment to customize)
    # ──────────────────────────────────────────────────────────────────────────

    # Visual theme: emoji | classic | minimal | none
    # export BREWUP_THEME="emoji"

    # Skip casks that auto-update themselves (e.g., Chrome, Firefox)
    # export BREWUP_SKIP_AUTO_UPDATE="1"

    # Use batch mode by default (faster, single brew call)
    # export BREWUP_BATCH="1"

    # Quiet mode (minimal output)
    # export BREWUP_QUIET="1"

    # Log retention in days (default: 30)
    # export BREWUP_LOG_RETENTION="14"

    # Custom log directory
    # export BREWUP_LOG_DIR="$HOME/.local/state/brewup"

    # ──────────────────────────────────────────────────────────────────────────
    # Scheduled Maintenance Reminder (optional)
    # ──────────────────────────────────────────────────────────────────────────
    # Uncomment to show a reminder if brewup hasn't run in 7+ days

    # __brewup_check_last_run() {
    #     local log_dir="${BREWUP_LOG_DIR:-$HOME/Library/Logs/brewup}"
    #     local last_log threshold_days=7
    #
    #     [[ ! -d "$log_dir" ]] && return
    #
    #     last_log=$(ls -t "$log_dir"/*.log 2>/dev/null | head -n1)
    #     [[ -z "$last_log" ]] && return
    #
    #     local last_mtime now days_ago
    #     last_mtime=$(stat -f %m "$last_log" 2>/dev/null)
    #     now=$(date +%s)
    #     days_ago=$(( (now - last_mtime) / 86400 ))
    #
    #     if (( days_ago >= threshold_days )); then
    #         print -P "%F{yellow}💡 Homebrew packages haven't been updated in ${days_ago} days.%f"
    #         print -P "%F{yellow}   Run 'brewup' or 'brewup plan' to check for updates.%f"
    #     fi
    # }
    # __brewup_check_last_run

else
    # Warn if brewup is missing
    print -u2 "Warning: brewup not found at ~/.zsh/functions/brewup"
    print -u2 "Install: curl -fsSL <url> -o ~/.zsh/functions/brewup"
fi
