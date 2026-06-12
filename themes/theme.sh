#!/usr/bin/env bash
# theme.sh — Theme pack loader for tmkit
#
# Deployed to: ~/.config/tmkit/theme.sh
# Sourced by:  ~/.bashrc  (provides the `theme` shell command)
# Also sourced by install.sh during setup
#
# Pack format (each themes/*.sh file must provide):
#   THEME_NAME="..."          display name
#   THEME_STYLE="dark|light"  for listing
#   theme_apply_yazi()        (optional)
#   theme_apply_lazygit()     (optional)
#   theme_apply_starship()    (optional)
#   theme_apply_taskwarrior() (optional)

# Default theme directory — can be overridden before sourcing this file
TMKIT_THEME_DIR="${TMKIT_THEME_DIR:-$HOME/.config/tmkit/themes}"
TMKIT_CURRENT_FILE="$HOME/.config/tmkit/current-theme"

# ==============================================================================
# Output helpers (prefixed to avoid clashing with install.sh's ok/info/warn)
# ==============================================================================
_theme_ok()   { echo -e "\033[1;32m✓\033[0m $1"; }
_theme_info() { echo -e "\033[0;36m→\033[0m $1"; }
_theme_warn() { echo -e "\033[1;33m!\033[0m $1"; }

# ==============================================================================
# Shared helper: merge a lazygit theme YAML block into the user's config
# Usage: _theme_merge_lazygit <config_path> <theme_file_path>
# ==============================================================================
_theme_merge_lazygit() {
  local cfg="$1" theme_file="$2"
  if [ -f "$cfg" ]; then
    python3 - "$cfg" "$theme_file" << 'PYEOF'
import sys, re, os
cfg_path, theme_path = sys.argv[1], sys.argv[2]
cfg = open(cfg_path).read() if os.path.exists(cfg_path) else ''
theme = open(theme_path).read()
# Remove any existing gui: block (theme colors live there)
cfg = re.sub(r'\ngui:\n(  .*\n)+', '\n', cfg)
open(cfg_path, 'w').write(cfg.rstrip() + '\n' + theme + '\n')
PYEOF
  else
    cp "$theme_file" "$cfg"
  fi
}

# ==============================================================================
# Shared helper: replace the starship palette in starship.toml
# Usage: _theme_set_starship_palette <palette_name> <toml_path> <palette_toml_file>
# ==============================================================================
_theme_set_starship_palette() {
  local palette_name="$1" toml="$2" palette_file="$3"
  python3 - "$toml" "$palette_name" "$palette_file" << 'PYEOF'
import sys, re
toml_path, palette_name, palette_file = sys.argv[1], sys.argv[2], sys.argv[3]
content = open(toml_path).read()
palette_content = open(palette_file).read()
# Remove existing top-level palette = "..." setting
content = re.sub(r'(?m)^palette = "[^"]*"\n?', '', content)
# Remove existing [palettes.*] sections (and their content)
content = re.sub(r'\[palettes\.[^\]]*\].*?(?=\n\[|\Z)', '', content, flags=re.DOTALL)
content = content.rstrip()
content += (
    f'\n\npalette = "{palette_name}"\n\n'
    f'[palettes.{palette_name}]\n'
    f'{palette_content.rstrip()}\n'
)
open(toml_path, 'w').write(content)
PYEOF
}

# ==============================================================================
# Shared helper: set key=value color pairs in ~/.taskrc
# Usage: _theme_set_taskrc "key=value" "key=value" ...
# ==============================================================================
_theme_set_taskrc() {
  local taskrc="$HOME/.taskrc"
  touch "$taskrc"
  for setting in "$@"; do
    local key="${setting%%=*}"
    if grep -q "^$key=" "$taskrc" 2>/dev/null; then
      sed -i "s|^$key=.*|$setting|" "$taskrc"
    else
      echo "$setting" >> "$taskrc"
    fi
  done
}

# ==============================================================================
# theme list  — show all available packs
# ==============================================================================
_theme_list_all() {
  local found=0
  for pack in "$TMKIT_THEME_DIR"/*.sh; do
    [ -f "$pack" ] || continue
    local slug name style
    slug=$(basename "$pack" .sh)
    # Source in subshell to read metadata safely
    name=$(bash -c "source '$pack' 2>/dev/null; echo \"\$THEME_NAME\"")
    style=$(bash -c "source '$pack' 2>/dev/null; echo \"\$THEME_STYLE\"")
    local current=""
    [ -f "$TMKIT_CURRENT_FILE" ] && [ "$(cat "$TMKIT_CURRENT_FILE" 2>/dev/null)" = "$slug" ] && current=" ← current"
    printf "  \033[0;36m%-22s\033[0m  %-30s  %s%s\n" "$slug" "${name:-$slug}" "${style:-dark}" "$current"
    ((found++)) || true
  done
  [ "$found" -eq 0 ] && echo "  No themes found in $TMKIT_THEME_DIR"
}

# ==============================================================================
# theme apply <slug>  — source the pack and call its apply functions
# ==============================================================================
_theme_apply() {
  local slug="$1"
  if [ -z "$slug" ]; then
    echo "Usage: theme apply <slug>"
    echo "Run 'theme list' to see available themes."
    return 1
  fi

  local pack="$TMKIT_THEME_DIR/${slug}.sh"
  if [ ! -f "$pack" ]; then
    _theme_warn "Theme '$slug' not found in $TMKIT_THEME_DIR"
    echo "Run 'theme list' to see available themes."
    return 1
  fi

  # Source the pack — defines THEME_NAME, THEME_STYLE, theme_apply_* functions
  # shellcheck disable=SC1090
  source "$pack"

  _theme_info "Applying ${THEME_NAME:-$slug}..."
  echo ""

  local app
  for app in yazi lazygit starship taskwarrior; do
    if declare -f "theme_apply_$app" >/dev/null 2>&1; then
      "theme_apply_$app"
    fi
  done

  mkdir -p "$(dirname "$TMKIT_CURRENT_FILE")"
  echo "$slug" > "$TMKIT_CURRENT_FILE"

  echo ""
  _theme_ok "Theme '${THEME_NAME:-$slug}' applied. Open a new terminal to see the full effect."
  echo -e "  \033[2mNeovim: add the matching colorscheme plugin to your Lazy config.\033[0m"
}

# ==============================================================================
# theme current  — show what's applied
# ==============================================================================
_theme_current() {
  if [ -f "$TMKIT_CURRENT_FILE" ]; then
    local slug
    slug=$(cat "$TMKIT_CURRENT_FILE" 2>/dev/null)
    local pack="$TMKIT_THEME_DIR/${slug}.sh"
    local name="$slug"
    [ -f "$pack" ] && name=$(bash -c "source '$pack' 2>/dev/null; echo \"\$THEME_NAME\"")
    echo "  Current theme: ${name:-$slug}  (slug: $slug)"
  else
    echo "  No theme applied yet. Run 'theme list' to see options."
  fi
}

# ==============================================================================
# theme  — main command (sourced into the shell via .bashrc)
# ==============================================================================
theme() {
  local _b="\033[1m" _r="\033[0m" _c="\033[0;36m"
  case "${1:-}" in
    list|ls)
      echo ""
      echo -e "  ${_b}Available themes:${_r}"
      echo ""
      _theme_list_all
      echo ""
      echo -e "  Apply with: ${_c}theme apply <slug>${_r}"
      echo ""
      ;;
    apply)
      _theme_apply "${2:-}"
      ;;
    current)
      echo ""
      _theme_current
      echo ""
      ;;
    ""|-h|--help|help)
      echo ""
      echo -e "  ${_b}theme${_r} — consistent color theme across all terminal apps"
      echo ""
      echo -e "  ${_c}theme list${_r}           show available themes"
      echo -e "  ${_c}theme apply <slug>${_r}   apply a theme"
      echo -e "  ${_c}theme current${_r}        show currently applied theme"
      echo ""
      _theme_current
      echo ""
      ;;
    *)
      echo "Unknown command: $1"
      echo "Run 'theme help' for usage."
      return 1
      ;;
  esac
}

# When run as a script (not sourced), forward args to theme()
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
  theme "$@"
fi
