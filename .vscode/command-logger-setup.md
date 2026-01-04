Command Logger for VS Code terminal (zsh)

Goal

- Record successful terminal commands you run inside this repository (from the VS Code integrated terminal).
- Auto-generate per-folder documentation sections listing executed commands and a suggested use case.

Files added

- `tools/command_logger.zsh` — zsh hook (preexec/precmd) that appends successful commands to `.vscode/terminal_commands.log`.
- `tools/generate_lab_docs.py` — Python script to parse the log and update per-folder `README.md` files with an "Terminal commands used" section.

Setup (one-time)

1. Open your `~/.zshrc` in your editor.
2. Add the following line near the end (adjust path if your repo is in a different location):

```zsh
# Enable VS Code terminal command logging for this repository
source "$HOME/Library/Mobile Documents/com~apple~CloudDocs/Data/Programs/Projects/Docker/ddd/tools/command_logger.zsh"
```

3. Reload your shell or restart the VS Code terminal:

```zsh
source ~/.zshrc
```

How it works

- The logger tracks each command you run and logs only successful ones (exit status 0).
- The log is saved at `.vscode/terminal_commands.log` inside the repository. Each line is:
  TIMESTAMP \t CWD \t COMMAND
- The logger avoids logging its own setup and common generator runs to prevent noise.

Generate documentation

After you've used the terminal a bit, run:

```zsh
python3 tools/generate_lab_docs.py
```

This will parse `.vscode/terminal_commands.log` and update `README.md` files in the folders where commands were run. The script:

- Adds/updates a section titled `## Terminal commands used (auto-generated)`.
- Adds a table of commands, first-seen timestamp, and a suggested use case (heuristic).
- Does not commit changes — review and commit as you prefer.

Notes & privacy

- Only commands executed after you source the logger will be recorded.
- The log file is stored in the repo; if you do not want it tracked by git, add `.vscode/terminal_commands.log` to your `.gitignore`.

Reverting

- To stop logging, remove the `source` line from your `~/.zshrc` and reload the shell.

Questions or customizations

- If you want the logger to live outside the repo, change `LOG_DIR` in `tools/command_logger.zsh` to a different path.
- If you want more advanced parsing (e.g., include command output or classify commands more precisely), I can extend `tools/generate_lab_docs.py`.
