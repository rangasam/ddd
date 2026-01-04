# Zsh command logger for VS Code terminal
# Logs only successful commands (exit code 0) executed inside the repo to
# .vscode/terminal_commands.log with fields: ISO_TIMESTAMP\tRELATIVE_CWD\tCOMMAND
#
# Install instructions are in .vscode/command-logger-setup.md

# Avoid re-defining if already defined
if [[ -n ${__vscode_cmd_logger_loaded-} ]]; then
  return
fi
__vscode_cmd_logger_loaded=1

# Path to log file (repo-relative)
LOG_DIR="${ZSH_LOG_DIR:-.vscode}"
LOG_FILE="$LOG_DIR/terminal_commands.log"

# Ensure directory exists
mkdir -p "$LOG_DIR"

# Capture command before execution
preexec() {
  # Zsh passes original command line as $1
  __vscode_last_cmd="$1"
}

# After command finishes, precmd runs before prompt is drawn
precmd() {
  local exit_status=$?
  # Only log successful commands
  if [[ $exit_status -ne 0 ]]; then
    return
  fi
  # Skip empty commands
  if [[ -z "${__vscode_last_cmd:-}" ]]; then
    return
  fi

  # Get ISO timestamp
  local ts
  ts=$(date +"%Y-%m-%dT%H:%M:%S%z")

  # Repo-relative cwd (if inside repo), otherwise full cwd
  local cwd
  cwd="$PWD"
  # If inside a git repo, make path relative to repo root
  if git rev-parse --show-toplevel >/dev/null 2>&1; then
    local repo_root
    repo_root=$(git rev-parse --show-toplevel)
    if [[ "$cwd" == "$repo_root"* ]]; then
      cwd=".${cwd#$repo_root}"
    fi
  fi

  # Sanitize command to single-line (tabs/newlines removed)
  local cmd
  cmd=$(printf '%s' "$__vscode_last_cmd" | tr -d '\n' | sed -e 's/\t/    /g')

  # Avoid logging the logger itself or generator runs
  case "$cmd" in
    *command_logger.zsh*|*generate_lab_docs.py*|*terminal_commands.log*)
      return
      ;;
  esac

  printf '%s\t%s\t%s\n' "$ts" "$cwd" "$cmd" >> "$LOG_FILE"
}

# Export functions for interactive shells
export -f preexec precmd
