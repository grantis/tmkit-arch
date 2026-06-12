#!/usr/bin/env bash
# Catppuccin Mocha — warm, dark theme
# https://catppuccin.com

THEME_NAME="Catppuccin Mocha"
THEME_STYLE="dark"

theme_apply_yazi() {
  mkdir -p "$HOME/.config/yazi"
  _theme_info "yazi: Catppuccin Mocha..."
  curl -sL "https://raw.githubusercontent.com/catppuccin/yazi/main/themes/mocha.toml" \
    -o "$HOME/.config/yazi/theme.toml" 2>/dev/null \
    && _theme_ok "yazi: Catppuccin Mocha applied" \
    || _theme_warn "yazi: download failed — check connection"
}

theme_apply_lazygit() {
  command -v lazygit >/dev/null 2>&1 || { _theme_warn "lazygit: not installed — skipping"; return; }
  mkdir -p "$HOME/.config/lazygit"
  _theme_info "lazygit: Catppuccin Mocha..."
  local tmp
  tmp=$(mktemp)
  curl -sL "https://raw.githubusercontent.com/catppuccin/lazygit/main/themes/mocha/blue.yml" \
    -o "$tmp" 2>/dev/null || { _theme_warn "lazygit: download failed"; rm -f "$tmp"; return; }
  _theme_merge_lazygit "$HOME/.config/lazygit/config.yml" "$tmp"
  rm -f "$tmp"
  _theme_ok "lazygit: Catppuccin Mocha applied"
}

theme_apply_starship() {
  local toml="$HOME/.config/starship.toml"
  [ ! -f "$toml" ] && _theme_warn "starship: starship.toml not found — skipping" && return
  _theme_info "starship: Catppuccin Mocha palette..."
  local tmp
  tmp=$(mktemp)
  cat > "$tmp" << 'PALETTE'
rosewater = "#f5e0dc"
flamingo  = "#f2cdcd"
pink      = "#f5c2e7"
mauve     = "#cba6f7"
red       = "#f38ba8"
maroon    = "#eba0ac"
peach     = "#fab387"
yellow    = "#f9e2af"
green     = "#a6e3a1"
teal      = "#94e2d5"
sky       = "#89dceb"
sapphire  = "#74c7ec"
blue      = "#89b4fa"
lavender  = "#b4befe"
text      = "#cdd6f4"
subtext1  = "#bac2de"
subtext0  = "#a6adc8"
overlay2  = "#9399b2"
overlay1  = "#7f849c"
overlay0  = "#6c7086"
surface2  = "#585b70"
surface1  = "#45475a"
surface0  = "#313244"
base      = "#1e1e2e"
mantle    = "#181825"
crust     = "#11111b"
PALETTE
  _theme_set_starship_palette "catppuccin_mocha" "$toml" "$tmp"
  rm -f "$tmp"
  _theme_ok "starship: Catppuccin Mocha palette set"
}

theme_apply_taskwarrior() {
  command -v task >/dev/null 2>&1 || { _theme_warn "taskwarrior: not installed — skipping"; return; }
  _theme_info "taskwarrior: Catppuccin Mocha..."
  _theme_set_taskrc \
    "color.due=color161" \
    "color.due.today=color196" \
    "color.overdue=color196" \
    "color.pri.H=color161" \
    "color.pri.M=color214" \
    "color.pri.L=color71" \
    "color.active=color081" \
    "color.completed=color240" \
    "color.header=color111" \
    "color.footnote=color245"
  _theme_ok "taskwarrior: Catppuccin Mocha applied"
}
