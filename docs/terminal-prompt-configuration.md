# Terminal Prompt Configuration Guide

This guide explains how to configure your terminal prompt to display only the current directory name instead of the full path (PWD).

## Goal

Transform your terminal prompt from showing the full path to showing only the current directory name:

**Before:**
```
~/Library/Mobile Documents/com~apple~CloudDocs/Data/Programs/Projects/Docker/ddd main ❯
~/Music/Logic ❯
```

**After:**
```
ddd main ❯
Logic ❯
```

## Prerequisites

- **Powerlevel10k** theme installed for zsh
- **Oh My Zsh** (recommended)
- **MesloLGS NF** fonts installed
- **VS Code** (if using integrated terminal)

## Configuration Steps

### Step 1: Backup Your Current Configuration

Always create a backup before making changes:

```bash
cp ~/.p10k.zsh ~/.p10k.zsh.backup
```

### Step 2: Locate the Directory Configuration

The directory display settings are typically around line 98 in `~/.p10k.zsh`:

```bash
# View the current configuration
sed -n '98,102p' ~/.p10k.zsh
```

You should see:
```bash
typeset -g POWERLEVEL9K_DIR_FOREGROUND=$blue
```

### Step 3: Add Directory Shortening Configuration

Add the following lines right after the `POWERLEVEL9K_DIR_FOREGROUND` setting:

```bash
sed -i '' '98 a\
  # Show only the last directory name (basename)\
  typeset -g POWERLEVEL9K_SHORTEN_STRATEGY=truncate_to_last\
  typeset -g POWERLEVEL9K_SHORTEN_DELIMITER=""
' ~/.p10k.zsh
```

**Or manually edit** `~/.p10k.zsh` and add:

```bash
# Blue current directory.
typeset -g POWERLEVEL9K_DIR_FOREGROUND=$blue
# Show only the last directory name (basename)
typeset -g POWERLEVEL9K_SHORTEN_STRATEGY=truncate_to_last
typeset -g POWERLEVEL9K_SHORTEN_DELIMITER=""
```

### Step 4: Apply the Changes

Reload your zsh configuration:

```bash
# Option 1: Source the configuration
source ~/.p10k.zsh

# Option 2: Restart zsh
exec zsh

# Option 3: Open a new terminal window
```

### Step 5: Verify the Configuration

Test in different directories:

```bash
# Test 1: Home directory
cd ~
# Expected prompt: ~ ❯

# Test 2: Nested directory
cd ~/Music/Logic
# Expected prompt: Logic ❯

# Test 3: Git repository
cd ~/path/to/your/repo
# Expected prompt: repo main ❯  (with branch name)
```

## VS Code Integration

If using VS Code integrated terminal, ensure your settings include:

**Location:** `~/Library/Application Support/Code/User/settings.json`

```json
{
    "terminal.integrated.defaultProfile.osx": "zsh",
    "terminal.integrated.profiles.osx": {
        "zsh": {
            "path": "/bin/zsh",
            "args": ["-l"]
        }
    },
    "terminal.integrated.fontFamily": "MesloLGS NF",
    "terminal.integrated.fontSize": 13,
    "terminal.integrated.shellIntegration.enabled": true
}
```

After updating VS Code settings:
1. Press `Cmd+Shift+P`
2. Type "Reload Window"
3. Press Enter
4. Open new terminal with `` Ctrl+` ``

## Configuration Options

### Different Shortening Strategies

You can use different strategies for displaying directories:

```bash
# Show only last directory (current setting)
typeset -g POWERLEVEL9K_SHORTEN_STRATEGY=truncate_to_last

# Show first and last directory
typeset -g POWERLEVEL9K_SHORTEN_STRATEGY=truncate_from_right
typeset -g POWERLEVEL9K_SHORTEN_DIR_LENGTH=1

# Show last 2 directories
typeset -g POWERLEVEL9K_SHORTEN_STRATEGY=truncate_to_last
typeset -g POWERLEVEL9K_SHORTEN_DIR_LENGTH=2

# Show up to 3 directories with middle truncation
typeset -g POWERLEVEL9K_SHORTEN_STRATEGY=truncate_middle
typeset -g POWERLEVEL9K_SHORTEN_DIR_LENGTH=3
```

### Custom Delimiter

If you want to show path separators:

```bash
# Show with slash (e.g., ~/Music/Logic becomes Music/Logic)
typeset -g POWERLEVEL9K_SHORTEN_DELIMITER="/"

# No delimiter (current setting)
typeset -g POWERLEVEL9K_SHORTEN_DELIMITER=""
```

## Troubleshooting

### Prompt Not Updating

**Problem:** Changes don't appear after editing config.

**Solutions:**
1. Ensure you edited the correct file: `~/.p10k.zsh`
2. Source the file: `source ~/.p10k.zsh`
3. Restart terminal or run: `exec zsh`
4. Check for syntax errors: `zsh -n ~/.p10k.zsh`

### Icons Not Displaying

**Problem:** Seeing boxes or question marks instead of icons.

**Solution:** Install MesloLGS NF fonts:

```bash
cd /tmp
curl -fLo "MesloLGS NF Regular.ttf" \
  https://github.com/romkatv/powerlevel10k-media/raw/master/MesloLGS%20NF%20Regular.ttf
curl -fLo "MesloLGS NF Bold.ttf" \
  https://github.com/romkatv/powerlevel10k-media/raw/master/MesloLGS%20NF%20Bold.ttf
curl -fLo "MesloLGS NF Italic.ttf" \
  https://github.com/romkatv/powerlevel10k-media/raw/master/MesloLGS%20NF%20Italic.ttf
curl -fLo "MesloLGS NF Bold Italic.ttf" \
  https://github.com/romkatv/powerlevel10k-media/raw/master/MesloLGS%20NF%20Bold%20Italic.ttf
mv MesloLGS*.ttf ~/Library/Fonts/
```

Restart terminal after installing fonts.

### VS Code Terminal Not Using zsh

**Problem:** VS Code terminal still shows bash prompt.

**Solution:**
1. Open VS Code settings (`Cmd+,`)
2. Search for "terminal default profile"
3. Set to "zsh"
4. Or add to `settings.json`:
   ```json
   "terminal.integrated.defaultProfile.osx": "zsh"
   ```

## Reverting Changes

If you want to restore the original configuration:

```bash
# Restore from backup
cp ~/.p10k.zsh.backup ~/.p10k.zsh

# Or remove the added lines manually
# Edit ~/.p10k.zsh and remove:
# - typeset -g POWERLEVEL9K_SHORTEN_STRATEGY=truncate_to_last
# - typeset -g POWERLEVEL9K_SHORTEN_DELIMITER=""

# Apply changes
source ~/.p10k.zsh
```

## Examples

### Example 1: Home Directory

```bash
$ cd ~
~ ❯
```

The home directory always shows as `~`.

### Example 2: Deep Nested Path

```bash
$ cd ~/Library/Mobile\ Documents/com~apple~CloudDocs/Data/Programs/Projects/Docker/ddd
ddd main ❯
```

Only shows `ddd` (the last directory) and `main` (git branch).

### Example 3: Non-Git Directory

```bash
$ cd ~/Music/Logic
Logic ❯
```

Shows only `Logic` without branch name (not a git repo).

### Example 4: Root Directory

```bash
$ cd /
/ ❯
```

Root directory shows as `/`.

## Advanced: Complete Prompt Customization

To further customize your prompt, run the Powerlevel10k configuration wizard:

```bash
p10k configure
```

This interactive wizard lets you customize:
- **Style:** Lean, Classic, Rainbow, Pure
- **Character Set:** Unicode, ASCII
- **Prompt Colors:** 256 colors, True color, 16 colors
- **Show Time:** Always, On success, On failure
- **Prompt Separators:** Angled, Vertical, Slanted, Round
- **Prompt Heads:** Sharp, Blurred, Flat, Round
- **Prompt Tails:** Flat, Blurred, Sharp, Slanted, Round
- **Prompt Height:** One line, Two lines
- **Prompt Connection:** Disconnected, Dotted, Solid
- **Prompt Frame:** No frame, Left, Full
- **Prompt Spacing:** Compact, Sparse
- **Icons:** Many, Few, None
- **Transient Prompt:** Yes, No

## Additional Resources

- **Powerlevel10k Documentation:** https://github.com/romkatv/powerlevel10k
- **Oh My Zsh:** https://ohmyz.sh/
- **Zsh Documentation:** https://zsh.sourceforge.io/Doc/

## Summary

This configuration provides a cleaner, more focused terminal prompt by showing only the essential information: the current directory name and git branch (if applicable). This is especially useful when working with deeply nested directory structures.

**Key Settings:**
```bash
typeset -g POWERLEVEL9K_SHORTEN_STRATEGY=truncate_to_last
typeset -g POWERLEVEL9K_SHORTEN_DELIMITER=""
```

**Files Modified:**
- `~/.p10k.zsh` - Powerlevel10k configuration
- `~/Library/Application Support/Code/User/settings.json` - VS Code settings (optional)

**Backup Location:**
- `~/.p10k.zsh.backup` - Original configuration backup

---

**Last Updated:** January 11, 2026  
**Tested On:** macOS with zsh, Oh My Zsh, and Powerlevel10k
