# Terminal Prompt Configuration Guide

This guide explains how to configure your terminal prompt to display only the current directory name instead of the full path (PWD). Instructions are provided for both macOS and Ubuntu Linux.

## Goal

Transform your terminal prompt from showing the full path to showing only the current directory name:

**Before:**
```
~/Developer/github/rangasam/ddd main ❯
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

## Platform-Specific Setup

Choose the appropriate section based on your operating system:
- [macOS Configuration](#macos-configuration)
- [Ubuntu Linux VM Configuration](#ubuntu-linux-vm-configuration)

---

## macOS Configuration

### Configuration Steps

### macOS Step 1: Backup Your Current Configuration

Always create a backup before making changes:

```bash
cp ~/.p10k.zsh ~/.p10k.zsh.backup
```

### macOS Step 2: Locate the Directory Configuration

The directory display settings are typically around line 98 in `~/.p10k.zsh`:

```bash
# View the current configuration
sed -n '98,102p' ~/.p10k.zsh
```

You should see:
```bash
typeset -g POWERLEVEL9K_DIR_FOREGROUND=$blue
```

### macOS Step 3: Add Directory Shortening Configuration

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

### macOS Step 4: Apply the Changes

Reload your zsh configuration:

```bash
# Option 1: Source the configuration
source ~/.p10k.zsh

# Option 2: Restart zsh
exec zsh

# Option 3: Open a new terminal window
```

### macOS Step 5: Verify the Configuration

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

## macOS VS Code Integration

If using VS Code integrated terminal on macOS, ensure your settings include:

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

---

## Ubuntu Linux VM Configuration

### Installation Steps for Ubuntu

These instructions are for setting up Powerlevel10k on Ubuntu Linux VM (including on MacBook Pro M1 with ARM).

#### Ubuntu Step 1: Install Prerequisites

```bash
# Update package list
sudo apt update

# Install zsh
sudo apt install zsh -y

# Install git and curl (if not already installed)
sudo apt install git curl -y
```

#### Ubuntu Step 2: Install Oh My Zsh

```bash
sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
```

When prompted, confirm that you want to change your default shell to zsh.

#### Ubuntu Step 3: Install Powerlevel10k Theme

```bash
git clone --depth=1 https://github.com/romkatv/powerlevel10k.git ${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/themes/powerlevel10k
```

#### Ubuntu Step 4: Set Powerlevel10k as Your Theme

Edit your `~/.zshrc` file:

```bash
nano ~/.zshrc
```

Find the line with `ZSH_THEME` and change it to:

```bash
ZSH_THEME="powerlevel10k/powerlevel10k"
```

Save the file (Ctrl+O, Enter, Ctrl+X).

#### Ubuntu Step 5: Install MesloLGS NF Fonts

```bash
# Create fonts directory if it doesn't exist
mkdir -p ~/.local/share/fonts

# Download fonts
cd ~/.local/share/fonts
curl -fLo "MesloLGS NF Regular.ttf" https://github.com/romkatv/powerlevel10k-media/raw/master/MesloLGS%20NF%20Regular.ttf
curl -fLo "MesloLGS NF Bold.ttf" https://github.com/romkatv/powerlevel10k-media/raw/master/MesloLGS%20NF%20Bold.ttf
curl -fLo "MesloLGS NF Italic.ttf" https://github.com/romkatv/powerlevel10k-media/raw/master/MesloLGS%20NF%20Italic.ttf
curl -fLo "MesloLGS NF Bold Italic.ttf" https://github.com/romkatv/powerlevel10k-media/raw/master/MesloLGS%20NF%20Bold%20Italic.ttf

# Refresh font cache
fc-cache -fv
```

#### Ubuntu Step 6: Configure Your Terminal Emulator

Set the terminal font to **MesloLGS NF** in your terminal emulator settings:
- **GNOME Terminal:** Right-click → Preferences → Profile → Text → Custom font → MesloLGS NF
- **Terminator:** Right-click → Preferences → Profiles → Font → MesloLGS NF
- **VS Code:** See Ubuntu VS Code Integration section below

#### Ubuntu Step 7: Restart zsh and Run Configuration Wizard

```bash
exec zsh
```

This will launch the Powerlevel10k configuration wizard. Follow the interactive prompts:
1. Select your preferred prompt style (Lean, Classic, Rainbow, Pure)
2. Choose character set (Unicode recommended)
3. Configure prompt elements
4. Set your preferences for colors, icons, and layout

#### Ubuntu Step 8: Add Directory Shortening Configuration

After the wizard completes, edit `~/.p10k.zsh`:

```bash
nano ~/.p10k.zsh
```

Find the line with `POWERLEVEL9K_DIR_FOREGROUND` (around line 98) and add these lines right after it:

```bash
# Show only the last directory name (basename)
typeset -g POWERLEVEL9K_SHORTEN_STRATEGY=truncate_to_last
typeset -g POWERLEVEL9K_SHORTEN_DELIMITER=""
```

Save the file (Ctrl+O, Enter, Ctrl+X).

#### Ubuntu Step 9: Apply Changes

```bash
source ~/.p10k.zsh
```

#### Ubuntu Step 10: Make zsh Your Default Shell (if not already done)

```bash
chsh -s $(which zsh)
```

**Important:** Log out and log back in (or reboot) for the change to take full effect system-wide.

#### Ubuntu Step 11: Verify zsh is Your Default Shell

After logging back in, verify the change:

```bash
echo $SHELL
```

Expected output: `/usr/bin/zsh` or `/bin/zsh`

### Ensuring zsh Always Opens in Ubuntu Terminals

To make sure every terminal window opens with the zsh interface and Powerlevel10k theme:

#### 1. Verify .zshrc Configuration

Ensure your `~/.zshrc` contains these essential lines:

```bash
# Path to your oh-my-zsh installation
export ZSH="$HOME/.oh-my-zsh"

# Set theme to Powerlevel10k
ZSH_THEME="powerlevel10k/powerlevel10k"

# Load Oh My Zsh
source $ZSH/oh-my-zsh.sh

# Load Powerlevel10k configuration
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh
```

#### 2. Configure Terminal Emulators

**GNOME Terminal (Ubuntu default):**
- After running `chsh -s $(which zsh)`, GNOME Terminal will automatically use zsh
- No additional configuration needed

**Terminator:**
Edit `~/.config/terminator/config`:
```ini
[profiles]
  [[default]]
    font = MesloLGS NF 12
    use_system_font = False
    custom_command = /usr/bin/zsh
    use_custom_command = True
```

**Tilix:**
- Open Tilix → Preferences → Profiles → Command
- Check "Run command as a login shell"
- Custom command: `/usr/bin/zsh`

**For SSH Sessions:**
If you frequently SSH into your Ubuntu VM, add to `~/.bashrc`:

```bash
# Auto-launch zsh for interactive sessions
if [ -t 1 ]; then
  exec zsh
fi
```

This ensures that even if bash is the login shell, interactive terminals immediately switch to zsh.

#### 3. Test Multiple Terminal Scenarios

Test that zsh loads correctly in all scenarios:

```bash
# Test 1: New terminal window
# Expected: Powerlevel10k prompt appears immediately

# Test 2: Check shell
echo $SHELL
# Expected: /usr/bin/zsh

# Test 3: Non-interactive shell (should still work)
zsh -c 'echo $ZSH_VERSION'
# Expected: Version number (e.g., 5.8)

# Test 4: Login shell
zsh -l
# Expected: Powerlevel10k prompt

# Test 5: In a directory with git repo
cd ~/some-git-repo
# Expected: Directory name + branch name in prompt
```

### Ubuntu VS Code Integration

If using VS Code on your Ubuntu VM, configure it to use zsh and the MesloLGS NF font.

**Location (Ubuntu):** `~/.config/Code/User/settings.json`

Add or modify these settings:

```json
{
    "terminal.integrated.defaultProfile.linux": "zsh",
    "terminal.integrated.profiles.linux": {
        "zsh": {
            "path": "/usr/bin/zsh",
            "args": ["-l"]
        }
    },
    "terminal.integrated.fontFamily": "MesloLGS NF",
    "terminal.integrated.fontSize": 13,
    "terminal.integrated.shellIntegration.enabled": true
}
```

**Key differences from macOS:**
- Use `"terminal.integrated.defaultProfile.linux"` instead of `.osx`
- Use `"terminal.integrated.profiles.linux"` instead of `.osx`
- Default zsh path is `/usr/bin/zsh` instead of `/bin/zsh`
- Settings file is at `~/.config/Code/User/settings.json` instead of `~/Library/Application Support/Code/User/settings.json`

After updating settings:
1. Press `Ctrl+Shift+P`
2. Type "Reload Window"
3. Press Enter
4. Open new terminal with `` Ctrl+` ``

### Ubuntu Troubleshooting

#### Fonts Not Displaying Correctly

If you see boxes or question marks instead of icons:

1. Verify fonts are installed:
   ```bash
   fc-list | grep "MesloLGS NF"
   ```

2. If fonts are missing, reinstall them (see Ubuntu Step 5)

3. Make sure your terminal is using MesloLGS NF font

4. Restart your terminal application

#### zsh Not Available

If `exec zsh` gives an error:

```bash
# Check if zsh is installed
which zsh

# If not installed, install it
sudo apt install zsh -y
```

#### Bash Still Opens Instead of zsh

If terminals still open with bash after running `chsh`:

1. **Verify the change was applied:**
   ```bash
   echo $SHELL
   ```
   If it shows `/bin/bash`, the change hasn't taken effect yet.

2. **Log out completely and log back in** (or reboot)

3. **Check available shells:**
   ```bash
   cat /etc/shells
   ```
   Make sure `/usr/bin/zsh` or `/bin/zsh` is listed.

4. **Manually set if needed:**
   ```bash
   sudo usermod -s /usr/bin/zsh $USER
   ```

5. **As a workaround, auto-exec zsh from bash:**
   Add to the end of `~/.bashrc`:
   ```bash
   # Auto-switch to zsh for interactive sessions
   if [ -t 1 ]; then
     exec zsh
   fi
   ```

#### Powerlevel10k Not Loading

If zsh opens but looks plain without Powerlevel10k:

1. **Check if .zshrc exists and has correct content:**
   ```bash
   cat ~/.zshrc | grep -i powerlevel
   ```
   Should show: `ZSH_THEME="powerlevel10k/powerlevel10k"`

2. **Verify Oh My Zsh is installed:**
   ```bash
   ls -la ~/.oh-my-zsh
   ```

3. **Check if Powerlevel10k theme is installed:**
   ```bash
   ls -la ~/.oh-my-zsh/custom/themes/powerlevel10k
   ```

4. **Manually source the configuration:**
   ```bash
   source ~/.zshrc
   ```

5. **Re-run the configuration wizard:**
   ```bash
   p10k configure
   ```

#### Permission Issues

If you get permission errors during Oh My Zsh installation:

```bash
# Fix ownership of .oh-my-zsh directory
sudo chown -R $USER:$USER ~/.oh-my-zsh

# Fix ownership of .zshrc
sudo chown $USER:$USER ~/.zshrc
```

---

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
$ cd ~/Developer/github/rangasam/ddd
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

**Files Modified (macOS):**
- `~/.p10k.zsh` - Powerlevel10k configuration
- `~/Library/Application Support/Code/User/settings.json` - VS Code settings (optional)
- `~/.p10k.zsh.backup` - Original configuration backup

**Files Modified (Ubuntu Linux):**
- `~/.zshrc` - Zsh configuration
- `~/.p10k.zsh` - Powerlevel10k configuration
- `~/.config/Code/User/settings.json` - VS Code settings (optional)
- `~/.local/share/fonts/` - Font installation directory

---

**Last Updated:** January 31, 2026  
**Tested On:** 
- macOS with zsh, Oh My Zsh, and Powerlevel10k
- Ubuntu Linux (including ARM VMs on MacBook Pro M1) with zsh, Oh My Zsh, and Powerlevel10k
