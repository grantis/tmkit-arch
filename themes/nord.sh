#!/usr/bin/env bash
# Nord — arctic, blue-tinted dark theme
# https://www.nordtheme.com

THEME_NAME="Nord"
THEME_STYLE="dark"

theme_apply_yazi() {
  mkdir -p "$HOME/.config/yazi"
  _theme_info "yazi: Nord..."
  cat > "$HOME/.config/yazi/theme.toml" << 'YAZIEOF'
[manager]
cwd = { fg = "#88c0d0" }
hovered = { fg = "#eceff4", bg = "#3b4252", bold = true }
preview_hovered = { underline = true }
count_copied = { fg = "#a3be8c", bold = true }
count_cut = { fg = "#bf616a", bold = true }
count_selected = { fg = "#ebcb8b", bold = true }

[status]
overall_progress = { fg = "#81a1c1" }
current_name = { fg = "#eceff4", bold = true }
permissions_r = { fg = "#a3be8c" }
permissions_w = { fg = "#bf616a" }
permissions_x = { fg = "#ebcb8b", bold = true }
permissions_s = { fg = "#b48ead" }

[input]
border = { fg = "#81a1c1" }
title  = { fg = "#88c0d0" }
value  = { fg = "#eceff4" }
selected = { reversed = true }

[select]
border   = { fg = "#81a1c1" }
active   = { fg = "#88c0d0", bold = true }
inactive = { fg = "#4c566a" }

[which]
cols = 3
mask        = { bg = "#2e3440" }
cand        = { fg = "#81a1c1" }
rest        = { fg = "#4c566a" }
desc        = { fg = "#d8dee9" }
separator   = "  "
separator_style = { fg = "#434c5e" }
YAZIEOF
  _theme_ok "yazi: Nord applied"
}

theme_apply_lazygit() {
  command -v lazygit >/dev/null 2>&1 || { _theme_warn "lazygit: not installed — skipping"; return; }
  mkdir -p "$HOME/.config/lazygit"
  _theme_info "lazygit: Nord..."
  local tmp
  tmp=$(mktemp)
  cat > "$tmp" << 'LGEOF'
gui:
  theme:
    activeBorderColor:
      - '#88c0d0'
      - bold
    inactiveBorderColor:
      - '#4c566a'
    searchingActiveBorderColor:
      - '#88c0d0'
      - bold
    optionsTextColor:
      - '#81a1c1'
    selectedLineBgColor:
      - '#3b4252'
    cherryPickedCommitBgColor:
      - '#434c5e'
    cherryPickedCommitFgColor:
      - '#88c0d0'
    markedBaseCommitBgColor:
      - '#434c5e'
    markedBaseCommitFgColor:
      - '#ebcb8b'
    unstagedChangesColor:
      - '#bf616a'
    defaultFgColor:
      - '#d8dee9'
LGEOF
  _theme_merge_lazygit "$HOME/.config/lazygit/config.yml" "$tmp"
  rm -f "$tmp"
  _theme_ok "lazygit: Nord applied"
}

theme_apply_starship() {
  local toml="$HOME/.config/starship.toml"
  [ ! -f "$toml" ] && _theme_warn "starship: starship.toml not found — skipping" && return
  _theme_info "starship: Nord palette..."
  local tmp
  tmp=$(mktemp)
  cat > "$tmp" << 'PALETTE'
blue     = "#81a1c1"
cyan     = "#88c0d0"
green    = "#a3be8c"
purple   = "#b48ead"
red      = "#bf616a"
orange   = "#d08770"
yellow   = "#ebcb8b"
teal     = "#8fbcbb"
magenta  = "#b48ead"
white    = "#eceff4"
black    = "#2e3440"
gray     = "#4c566a"
PALETTE
  _theme_set_starship_palette "nord" "$toml" "$tmp"
  rm -f "$tmp"
  _theme_ok "starship: Nord palette set"
}

theme_apply_taskwarrior() {
  command -v task >/dev/null 2>&1 || { _theme_warn "taskwarrior: not installed — skipping"; return; }
  _theme_info "taskwarrior: Nord..."
  _theme_set_taskrc \
    "color.due=color174" \
    "color.due.today=color167" \
    "color.overdue=color167" \
    "color.pri.H=color174" \
    "color.pri.M=color222" \
    "color.pri.L=color114" \
    "color.active=color110" \
    "color.completed=color242" \
    "color.header=color153" \
    "color.footnote=color247"
  _theme_ok "taskwarrior: Nord applied"
}
