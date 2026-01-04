#!/usr/bin/env python3
"""
Parse .vscode/terminal_commands.log and update per-directory README.md files with
an auto-generated "Terminal commands used" section.

Format of log (tab-separated):
TIMESTAMP\tCWD\tCOMMAND

Rules:
- Only successful commands are logged (logger enforces this).
- Commands are grouped by CWD (relative path) and written into that folder's
  README.md under a heading "## Terminal commands used (auto-generated)".
- Duplicates are removed and ordered by first occurrence.
- A heuristic maps commands to suggested use-cases (editable by user).

Usage:
  python3 tools/generate_lab_docs.py

"""
from pathlib import Path
import sys
import re
from collections import OrderedDict

REPO_ROOT = Path(__file__).resolve().parents[1]
LOG_PATH = REPO_ROOT / '.vscode' / 'terminal_commands.log'

USE_CASE_HINTS = [
    (re.compile(r'^docker build'), 'Build Docker image'),
    (re.compile(r'^docker run'), 'Run Docker container'),
    (re.compile(r'^docker compose|^docker-compose'), 'Start multi-container Compose stack'),
    (re.compile(r'^docker stack deploy'), 'Deploy stack to Swarm'),
    (re.compile(r'^git '), 'Git operation (commit/push/pull)'),
    (re.compile(r'^go build|^go run'), 'Build or run Go application'),
    (re.compile(r'^npm install|^yarn'), 'Install JavaScript dependencies'),
    (re.compile(r'^python'), 'Run Python interpreter/script'),
    (re.compile(r'^make'), 'Build via Makefile'),
]

HEADING = '## Terminal commands used (auto-generated)'


def read_log(path: Path):
    if not path.exists():
        print(f'Log file not found: {path}', file=sys.stderr)
        return []
    entries = []
    with path.open('r', encoding='utf-8') as f:
        for line in f:
            line = line.rstrip('\n')
            if not line:
                continue
            parts = line.split('\t', 2)
            if len(parts) != 3:
                continue
            ts, cwd, cmd = parts
            entries.append((ts, cwd, cmd))
    return entries


def suggest_use_case(cmd: str) -> str:
    for pattern, hint in USE_CASE_HINTS:
        if pattern.search(cmd):
            return hint
    return 'General / other'


def aggregate_by_cwd(entries):
    # OrderedDict to preserve first-seen order
    agg = OrderedDict()
    for ts, cwd, cmd in entries:
        # Normalize cwd: '.' -> repo root
        target_dir = (REPO_ROOT / cwd.lstrip('./')).resolve() if cwd != '.' else REPO_ROOT
        try:
            rel = target_dir.relative_to(REPO_ROOT)
            rel_str = '.' if str(rel) == '.' else f'./{rel}'
        except Exception:
            rel_str = cwd
        if rel_str not in agg:
            agg[rel_str] = OrderedDict()
        if cmd not in agg[rel_str]:
            agg[rel_str][cmd] = ts
    return agg


def generate_markdown_for_dir(dir_path: Path, commands: OrderedDict):
    lines = []
    lines.append('\n')
    lines.append(HEADING)
    lines.append('\n')
    lines.append('| Command | First seen | Suggested use case |')
    lines.append('|---|---:|---|')
    for cmd, ts in commands.items():
        use_case = suggest_use_case(cmd)
        lines.append(f'| `{cmd}` | {ts} | {use_case} |')
    lines.append('\n')
    lines.append('> Note: This section is auto-generated from the VS Code terminal log. You can edit the suggested use case or add more details below each command to explain the exact lab step.')
    lines.append('\n')
    return '\n'.join(lines)


def update_readme_for_dir(dir_rel: str, commands: OrderedDict):
    # dir_rel is like '.' or './compose' etc.
    target_dir = (REPO_ROOT / dir_rel.lstrip('./')).resolve() if dir_rel != '.' else REPO_ROOT
    readme = target_dir / 'README.md'
    if not readme.exists():
        # Create a basic README if missing
        readme.write_text(f'# {target_dir.name}\n\n')
    content = readme.read_text(encoding='utf-8')
    # Remove existing auto-generated section if any
    if HEADING in content:
        content = content.split(HEADING, 1)[0].rstrip() + '\n\n'
    md_section = generate_markdown_for_dir(target_dir, commands)
    new_content = content + md_section
    readme.write_text(new_content, encoding='utf-8')
    print(f'Updated {readme}')


def main():
    entries = read_log(LOG_PATH)
    if not entries:
        print('No log entries found. Start using the terminal (in VS Code) after sourcing the logger.', file=sys.stderr)
        return
    agg = aggregate_by_cwd(entries)
    for dir_rel, cmds in agg.items():
        update_readme_for_dir(dir_rel, cmds)


if __name__ == '__main__':
    main()
