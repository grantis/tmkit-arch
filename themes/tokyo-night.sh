#!/usr/bin/env bash
# Tokyo Night — dark blue/purple theme
# https://github.com/enkia/tokyo-night-vscode-theme

THEME_NAME="Tokyo Night"
THEME_STYLE="dark"

theme_apply_yazi() {
  mkdir -p "$HOME/.config/yazi"
  _theme_info "yazi: Tokyo Night..."
  # Try official community pack first; fall back to inline minimal version
  curl -sL "https://raw.githubusercontent.com/BennyOe/tokyo-night.yazi/main/theme.toml" \
    -o "$HOME/.config/yazi/theme.toml" 2>/dev/null
  if [ -s "$HOME/.config/yazi/theme.toml" ]; then
    _theme_ok "yazi: Tokyo Night applied"
  else
    # Minimal inline fallback
    cat > "$HOME/.config/yazi/theme.toml" << 'YAZIEOF'
[manager]
cwd = { fg = "#7dcfff" }
hovered = { fg = "#c0caf5", bg = "#283457", bold = true }
preview_hovered = { underline = true }
count_copied = { fg = "#9ece6a", bold = true }
count_cut = { fg = "#f7768e", bold = true }
count_selected = { fg = "#e0af68", bold = true }

[status]
overall_progress = { fg = "#7aa2f7" }
current_name = { fg = "#c0caf5", bold = true }
permissions_r = { fg = "#9ece6a" }
permissions_w = { fg = "#f7768e" }
permissions_x = { fg = "#e0af68", bold = true }
permissions_s = { fg = "#bb9af7" }

[input]
border = { fg = "#7aa2f7" }
title  = { fg = "#7dcfff" }
value  = { fg = "#c0caf5" }
selected = { reversed = true }

[select]
border   = { fg = "#7aa2f7" }
active   = { fg = "#7aa2f7", bold = true }
inactive = { fg = "#565f89" }

[which]
cols = 3
mask        = { bg = "#1a1b26" }
cand        = { fg = "#7aa2f7" }
rest        = { fg = "#565f89" }
desc        = { fg = "#c0caf5" }
separator   = "  "
separator_style = { fg = "#3b4261" }
YAZIEOF
    _theme_ok "yazi: Tokyo Night applied (minimal inline)"
  fi
}

theme_apply_lazygit() {
  command -v lazygit >/dev/null 2>&1 || { _theme_warn "lazygit: not installed — skipping"; return; }
  mkdir -p "$HOME/.config/lazygit"
  _theme_info "lazygit: Tokyo Night..."
  local tmp
  tmp=$(mktemp)
  cat > "$tmp" << 'LGEOF'
gui:
  theme:
    activeBorderColor:
      - '#7aa2f7'
      - bold
    inactiveBorderColor:
      - '#565f89'
    searchingActiveBorderColor:
      - '#7aa2f7'
      - bold
    optionsTextColor:
      - '#7dcfff'
    selectedLineBgColor:
      - '#283457'
    cherryPickedCommitBgColor:
      - '#394b70'
    cherryPickedCommitFgColor:
      - '#7aa2f7'
    markedBaseCommitBgColor:
      - '#394b70'
    markedBaseCommitFgColor:
      - '#e0af68'
    unstagedChangesColor:
      - '#f7768e'
    defaultFgColor:
      - '#c0caf5'
LGEOF
  _theme_merge_lazygit "$HOME/.config/lazygit/config.yml" "$tmp"
  rm -f "$tmp"
  _theme_ok "lazygit: Tokyo Night applied"
}

theme_apply_starship() {
  local toml="$HOME/.config/starship.toml"
  [ ! -f "$toml" ] && _theme_warn "starship: starship.toml not found — skipping" && return
  _theme_info "starship: Tokyo Night palette..."
  local tmp
  tmp=$(mktemp)
  cat > "$tmp" << 'PALETTE'
blue     = "#7aa2f7"
cyan     = "#7dcfff"
green    = "#9ece6a"
purple   = "#bb9af7"
red      = "#f7768e"
orange   = "#ff9e64"
yellow   = "#e0af68"
teal     = "#73daca"
magenta  = "#bb9af7"
white    = "#c0caf5"
black    = "#1a1b26"
gray     = "#565f89"
PALETTE
  _theme_set_starship_palette "tokyo_night" "$toml" "$tmp"
  rm -f "$tmp"
  _theme_ok "starship: Tokyo Night palette set"
}

theme_apply_taskwarrior() {
  command -v task >/dev/null 2>&1 || { _theme_warn "taskwarrior: not installed — skipping"; return; }
  _theme_info "taskwarrior: Tokyo Night..."
  _theme_set_taskrc \
    "color.due=color209" \
    "color.due.today=color196" \
    "color.overdue=color196" \
    "color.pri.H=color209" \
    "color.pri.M=color226" \
    "color.pri.L=color71" \
    "color.active=color111" \
    "color.completed=color240" \
    "color.header=color075" \
    "color.footnote=color245"
  _theme_ok "taskwarrior: Tokyo Night applied"
}
