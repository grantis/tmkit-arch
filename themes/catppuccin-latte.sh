#!/usr/bin/env bash
# Catppuccin Latte — warm, light theme
# https://catppuccin.com

THEME_NAME="Catppuccin Latte"
THEME_STYLE="light"

theme_apply_yazi() {
  mkdir -p "$HOME/.config/yazi"
  _theme_info "yazi: Catppuccin Latte..."
  curl -sL "https://raw.githubusercontent.com/catppuccin/yazi/main/themes/latte.toml" \
    -o "$HOME/.config/yazi/theme.toml" 2>/dev/null \
    && _theme_ok "yazi: Catppuccin Latte applied" \
    || _theme_warn "yazi: download failed — check connection"
}

theme_apply_lazygit() {
  command -v lazygit >/dev/null 2>&1 || { _theme_warn "lazygit: not installed — skipping"; return; }
  mkdir -p "$HOME/.config/lazygit"
  _theme_info "lazygit: Catppuccin Latte..."
  local tmp
  tmp=$(mktemp)
  curl -sL "https://raw.githubusercontent.com/catppuccin/lazygit/main/themes/latte/blue.yml" \
    -o "$tmp" 2>/dev/null || { _theme_warn "lazygit: download failed"; rm -f "$tmp"; return; }
  _theme_merge_lazygit "$HOME/.config/lazygit/config.yml" "$tmp"
  rm -f "$tmp"
  _theme_ok "lazygit: Catppuccin Latte applied"
}

theme_apply_starship() {
  local toml="$HOME/.config/starship.toml"
  [ ! -f "$toml" ] && _theme_warn "starship: starship.toml not found — skipping" && return
  _theme_info "starship: Catppuccin Latte palette..."
  local tmp
  tmp=$(mktemp)
  cat > "$tmp" << 'PALETTE'
rosewater = "#dc8a78"
flamingo  = "#dd7878"
pink      = "#ea76cb"
mauve     = "#8839ef"
red       = "#d20f39"
maroon    = "#e64553"
peach     = "#fe640b"
yellow    = "#df8e1d"
green     = "#40a02b"
teal      = "#179299"
sky       = "#04a5e5"
sapphire  = "#209fb5"
blue      = "#1e66f5"
lavender  = "#7287fd"
text      = "#4c4f69"
subtext1  = "#5c5f77"
subtext0  = "#6c6f85"
overlay2  = "#7c7f93"
overlay1  = "#8c8fa1"
overlay0  = "#9ca0b0"
surface2  = "#acb0be"
surface1  = "#bcc0cc"
surface0  = "#ccd0da"
base      = "#eff1f5"
mantle    = "#e6e9ef"
crust     = "#dce0e8"
PALETTE
  _theme_set_starship_palette "catppuccin_latte" "$toml" "$tmp"
  rm -f "$tmp"
  _theme_ok "starship: Catppuccin Latte palette set"
}

theme_apply_taskwarrior() {
  command -v task >/dev/null 2>&1 || { _theme_warn "taskwarrior: not installed — skipping"; return; }
  _theme_info "taskwarrior: Catppuccin Latte..."
  _theme_set_taskrc \
    "color.due=color168" \
    "color.due.today=color160" \
    "color.overdue=color160" \
    "color.pri.H=color168" \
    "color.pri.M=color172" \
    "color.pri.L=color64" \
    "color.active=color027" \
    "color.completed=color247" \
    "color.header=color018" \
    "color.footnote=color240"
  _theme_ok "taskwarrior: Catppuccin Latte applied"
}
