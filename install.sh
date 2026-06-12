#!/usr/bin/env bash
# install.sh - Terminal Kit installer
# Supports: Arch, Ubuntu/Debian, Fedora/RHEL, and derivatives
# Handles root vs non-root, missing sudo, missing git, bare installs
# Usage: bash install.sh

# ------------------------------------------------------------------------------
# Safety: don't use set -e globally - we handle errors ourselves so one
# failed optional install doesn't abort the whole script
# ------------------------------------------------------------------------------

# ==============================================================================
# Colors
# ==============================================================================
_b="\033[1m"
_r="\033[0m"
_g="\033[1;32m"
_c="\033[0;36m"
_y="\033[1;33m"
_red="\033[0;31m"

ok()   { echo -e "${_g}✓${_r} $1"; }
info() { echo -e "${_c}→${_r} $1"; }
warn() { echo -e "${_y}!${_r} $1"; }
fail() { echo -e "${_red}✘${_r} $1"; exit 1; }
ask()  { echo -e "\n${_y}?${_r} $1"; }
header() { echo -e "\n${_b}$1${_r}"; }

# ==============================================================================
# Privilege helper
# On bare Arch you may be root. On Ubuntu you're a normal user with sudo.
# This wrapper handles both without hardcoding sudo everywhere.
# ==============================================================================
PRIV=""
setup_priv() {
  if [ "$(id -u)" -eq 0 ]; then
    PRIV=""
    ok "Running as root"
  elif command -v sudo >/dev/null 2>&1; then
    PRIV="sudo"
    ok "sudo available"
  elif command -v doas >/dev/null 2>&1; then
    PRIV="doas"
    ok "doas available"
  else
    warn "No sudo or doas found and not root."
    warn "Some installs may fail. Consider running as root or installing sudo first."
    warn "  pacman -S sudo   OR   su -c 'bash install.sh'"
    PRIV=""
  fi
}

# ==============================================================================
# Detect distro + set package manager vars
# ==============================================================================
PKG_MANAGER=""
PKG_INSTALL=""
PKG_UPDATE=""

detect_distro() {
  if command -v pacman >/dev/null 2>&1; then
    PKG_MANAGER="pacman"
    PKG_UPDATE="$PRIV pacman -Sy --noconfirm"
    PKG_INSTALL="$PRIV pacman -S --noconfirm --needed"

  elif command -v apt >/dev/null 2>&1; then
    PKG_MANAGER="apt"
    PKG_UPDATE="$PRIV apt update -y"
    PKG_INSTALL="$PRIV apt install -y"

  elif command -v dnf >/dev/null 2>&1; then
    PKG_MANAGER="dnf"
    PKG_UPDATE="$PRIV dnf check-update; true"
    PKG_INSTALL="$PRIV dnf install -y"

  elif command -v zypper >/dev/null 2>&1; then
    PKG_MANAGER="zypper"
    PKG_UPDATE="$PRIV zypper refresh"
    PKG_INSTALL="$PRIV zypper install -y"

  else
    fail "Could not detect a package manager (pacman, apt, dnf, zypper). Exiting."
  fi

  # Read distro name nicely
  DISTRO_NAME="Unknown"
  if [ -f /etc/os-release ]; then
    DISTRO_NAME=$(grep ^PRETTY_NAME /etc/os-release | cut -d= -f2 | tr -d '"')
  fi

  ok "Distro: $DISTRO_NAME"
  ok "Package manager: $PKG_MANAGER"
}

# ==============================================================================
# Package name mapping
# Different distros use different names for the same tool.
# Usage: pkg_name <canonical_name>
# Returns the right package name for the current distro.
# ==============================================================================
pkg_name() {
  local tool="$1"
  case "$PKG_MANAGER" in
    pacman)
      case "$tool" in
        tldr)        echo "tealdeer" ;;
        taskwarrior) echo "task" ;;
        fd)          echo "fd" ;;
        bat)         echo "bat" ;;
        ripgrep)     echo "ripgrep" ;;
        *)           echo "$tool" ;;
      esac
      ;;
    apt)
      case "$tool" in
        tldr)        echo "tldr" ;;
        taskwarrior) echo "taskwarrior" ;;
        fd)          echo "fd-find" ;;
        bat)         echo "bat" ;;
        ripgrep)     echo "ripgrep" ;;
        *)           echo "$tool" ;;
      esac
      ;;
    dnf)
      case "$tool" in
        tldr)        echo "tealdeer" ;;
        taskwarrior) echo "task" ;;
        fd)          echo "fd-find" ;;
        bat)         echo "bat" ;;
        ripgrep)     echo "ripgrep" ;;
        *)           echo "$tool" ;;
      esac
      ;;
    *)
      echo "$tool"
      ;;
  esac
}

# ==============================================================================
# Install a single package
# Usage: install_pkg <canonical_name> [display_label] [check_binary]
# check_binary lets you override what binary to check for (e.g. fd vs fdfind)
# ==============================================================================
install_pkg() {
  local tool="$1"
  local label="${2:-$tool}"
  local check_bin="${3:-$tool}"
  local pkg
  pkg=$(pkg_name "$tool")

  if command -v "$check_bin" >/dev/null 2>&1; then
    ok "$label already installed"
    return 0
  fi

  info "Installing $label..."
  if $PKG_INSTALL "$pkg" >/dev/null 2>&1; then
    ok "$label installed"
  else
    warn "Could not install $label - skipping (you can install it later: $PKG_INSTALL $pkg)"
    return 1
  fi
}

# ==============================================================================
# Bootstrap: ensure bare minimum exists before anything else
# On a fresh Arch install you may not even have git or curl
# ==============================================================================
bootstrap() {
  header "Bootstrap"

  # Ensure package list is fresh first
  info "Syncing package lists..."
  $PKG_UPDATE >/dev/null 2>&1 && ok "Package lists synced" || warn "Package sync failed - continuing anyway"

  # curl is needed for starship and font installs
  install_pkg curl "curl"

  # git is needed to clone the kit if they don't have it
  install_pkg git "git"

  # bash-completion improves tab completion significantly
  if [ "$PKG_MANAGER" = "pacman" ]; then
    install_pkg bash-completion "bash-completion" bash-completion || true
  else
    install_pkg bash-completion "bash-completion" bash-completion || true
  fi
}

# ==============================================================================
# Core tools
# ==============================================================================
install_core() {
  header "Core tools"

  install_pkg fzf   "fzf (fuzzy search)"
  install_pkg htop  "htop (process monitor)"
  install_pkg tree  "tree (directory viewer)"
  install_pkg unzip "unzip"

  # tldr - plain english man pages
  local tldr_pkg
  tldr_pkg=$(pkg_name tldr)
  if ! command -v tldr >/dev/null 2>&1 && ! command -v tealdeer >/dev/null 2>&1; then
    info "Installing tldr (plain-english man pages)..."
    $PKG_INSTALL "$tldr_pkg" >/dev/null 2>&1 && ok "tldr installed" || warn "tldr unavailable - skip"
  else
    ok "tldr already installed"
  fi

  # bat - better cat with syntax highlighting (nice for beginners)
  install_pkg bat "bat (better cat)" bat || true
}

# ==============================================================================
# Starship prompt
# ==============================================================================
install_starship() {
  header "Starship prompt"

  if command -v starship >/dev/null 2>&1; then
    ok "Starship already installed ($(starship --version 2>/dev/null | head -1))"
    return
  fi

  # Prefer pacman on Arch - keeps it in the package manager
  if [ "$PKG_MANAGER" = "pacman" ]; then
    info "Installing Starship via pacman..."
    $PKG_INSTALL starship >/dev/null 2>&1 && ok "Starship installed" && return
  fi

  # Fallback: official install script (works everywhere with curl)
  info "Installing Starship via install script..."
  if curl -sS https://starship.rs/install.sh | sh -s -- -y >/dev/null 2>&1; then
    ok "Starship installed"
  else
    warn "Starship install failed. Install manually: https://starship.rs"
  fi
}

# ==============================================================================
# Deploy config files
# ==============================================================================
deploy_configs() {
  header "Config files"

  local script_dir
  script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

  # .bashrc
  if [ -f "$script_dir/configs/.bashrc" ]; then
    if [ -f "$HOME/.bashrc" ]; then
      local bak="$HOME/.bashrc.bak.$(date +%s)"
      cp "$HOME/.bashrc" "$bak"
      warn "Existing .bashrc backed up to $bak"
    fi
    cp "$script_dir/configs/.bashrc" "$HOME/.bashrc"
    ok "~/.bashrc deployed"
  else
    warn "configs/.bashrc not found - skipping"
  fi

  # starship.toml
  mkdir -p "$HOME/.config"
  if [ -f "$script_dir/configs/starship.toml" ]; then
    cp "$script_dir/configs/starship.toml" "$HOME/.config/starship.toml"
    ok "~/.config/starship.toml deployed"
  else
    warn "configs/starship.toml not found - skipping"
  fi
}

# ==============================================================================
# Optional installs
# ==============================================================================

install_neovim() {
  if command -v nvim >/dev/null 2>&1; then
    ok "Neovim already installed"
    return
  fi
  info "Installing Neovim..."
  if $PKG_INSTALL neovim >/dev/null 2>&1; then
    ok "Neovim installed"
    ask "Install LazyVim config? (recommended for beginners - gives you a VS Code-like setup) [y/N]"
    read -r choice
    if [[ "$choice" =~ ^[Yy]$ ]]; then
      [ -d "$HOME/.config/nvim" ] && mv "$HOME/.config/nvim" "$HOME/.config/nvim.bak.$(date +%s)"
      git clone --depth 1 https://github.com/LazyVim/starter "$HOME/.config/nvim" >/dev/null 2>&1 \
        && rm -rf "$HOME/.config/nvim/.git" \
        && ok "LazyVim installed - run 'nvim' and wait for plugins to install" \
        || warn "LazyVim clone failed - run nvim manually to set up"
    fi
  else
    warn "Neovim install failed"
  fi
}

install_taskwarrior() {
  if command -v task >/dev/null 2>&1; then
    ok "Taskwarrior already installed"
    return
  fi
  local pkg
  pkg=$(pkg_name taskwarrior)
  info "Installing Taskwarrior..."
  $PKG_INSTALL "$pkg" >/dev/null 2>&1 && ok "Taskwarrior installed" || warn "Taskwarrior install failed"
}

install_lazygit() {
  if command -v lazygit >/dev/null 2>&1; then
    ok "Lazygit already installed"
    return
  fi

  if [ "$PKG_MANAGER" = "pacman" ]; then
    info "Installing Lazygit via pacman..."
    $PKG_INSTALL lazygit >/dev/null 2>&1 && ok "Lazygit installed" && return
  fi

  # Binary install for apt/dnf
  info "Installing Lazygit from GitHub releases..."
  local version
  version=$(curl -s https://api.github.com/repos/jesseduffield/lazygit/releases/latest \
    | grep tag_name | cut -d'"' -f4 | tr -d v)
  if [ -z "$version" ]; then
    warn "Could not fetch Lazygit version - skipping"
    return
  fi
  local url="https://github.com/jesseduffield/lazygit/releases/download/v${version}/lazygit_${version}_Linux_x86_64.tar.gz"
  local tmp
  tmp=$(mktemp -d)
  curl -sLo "$tmp/lg.tar.gz" "$url" \
    && tar -xf "$tmp/lg.tar.gz" -C "$tmp" lazygit \
    && $PRIV install "$tmp/lazygit" -D -t /usr/local/bin/ \
    && ok "Lazygit installed" \
    || warn "Lazygit install failed"
  rm -rf "$tmp"
}

install_nvm() {
  if [ -d "$HOME/.nvm" ]; then
    ok "NVM already installed"
    return
  fi
  info "Installing NVM..."
  curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.7/install.sh | bash >/dev/null 2>&1 \
    && ok "NVM installed - run 'nvm install --lts' after reloading shell" \
    || warn "NVM install failed"
}

install_font() {
  if fc-list 2>/dev/null | grep -qi "JetBrainsMono"; then
    ok "JetBrains Mono Nerd Font already installed"
    return
  fi

  # fontconfig might not exist on a bare install
  if ! command -v fc-cache >/dev/null 2>&1; then
    if [ "$PKG_MANAGER" = "pacman" ]; then
      $PKG_INSTALL fontconfig >/dev/null 2>&1
    else
      $PKG_INSTALL fontconfig >/dev/null 2>&1
    fi
  fi

  info "Downloading JetBrains Mono Nerd Font..."
  local font_dir="$HOME/.local/share/fonts/JetBrainsMono"
  mkdir -p "$font_dir"
  local tmp
  tmp=$(mktemp -d)
  curl -sL "https://github.com/ryanoasis/nerd-fonts/releases/latest/download/JetBrainsMono.zip" \
    -o "$tmp/JetBrainsMono.zip" \
    && unzip -q "$tmp/JetBrainsMono.zip" -d "$tmp/fonts" \
    && find "$tmp/fonts" -name "*.ttf" -exec cp {} "$font_dir/" \; \
    && fc-cache -fq \
    && ok "JetBrains Mono Nerd Font installed" \
    || warn "Font install failed - get it manually: https://www.nerdfonts.com"
  rm -rf "$tmp"
}

optional_installs() {
  header "Optional installs"
  echo -e "  These are recommended but not required."

  ask "Install Neovim? (modern text editor - replaces nano) [y/N]"
  read -r choice
  [[ "$choice" =~ ^[Yy]$ ]] && install_neovim

  ask "Install Taskwarrior? (terminal to-do list) [y/N]"
  read -r choice
  [[ "$choice" =~ ^[Yy]$ ]] && install_taskwarrior

  ask "Install Lazygit? (visual git TUI - great for beginners) [y/N]"
  read -r choice
  [[ "$choice" =~ ^[Yy]$ ]] && install_lazygit

  ask "Install NVM? (Node.js version manager - needed for JS/web dev) [y/N]"
  read -r choice
  [[ "$choice" =~ ^[Yy]$ ]] && install_nvm

  ask "Install JetBrains Mono Nerd Font? (makes prompt icons render correctly) [y/N]"
  read -r choice
  [[ "$choice" =~ ^[Yy]$ ]] && install_font
}

# ==============================================================================
# Verify: quick sanity check after install
# ==============================================================================
verify() {
  header "Verification"
  local pass=0 fail=0

  check() {
    local label="$1"
    local cmd="$2"
    if command -v "$cmd" >/dev/null 2>&1; then
      ok "$label"
      ((pass++)) || true
    else
      warn "$label not found"
      ((fail++)) || true
    fi
  }

  check "bash"     "bash"
  check "curl"     "curl"
  check "git"      "git"
  check "fzf"      "fzf"
  check "htop"     "htop"
  check "starship" "starship"

  echo ""
  echo -e "  ${_g}$pass passed${_r}  ${_y}$fail missing${_r}"
}

# ==============================================================================
# Main
# ==============================================================================
main() {
  clear
  echo -e "${_b}${_g}"
  echo "  ████████╗███████╗██████╗ ███╗   ███╗██╗███╗   ██╗ █████╗ ██╗"
  echo "     ██╔══╝██╔════╝██╔══██╗████╗ ████║██║████╗  ██║██╔══██╗██║"
  echo "     ██║   █████╗  ██████╔╝██╔████╔██║██║██╔██╗ ██║███████║██║"
  echo "     ██║   ██╔══╝  ██╔══██╗██║╚██╔╝██║██║██║╚██╗██║██╔══██║██║"
  echo "     ██║   ███████╗██║  ██║██║ ╚═╝ ██║██║██║ ╚████║██║  ██║███████╗"
  echo "     ╚═╝   ╚══════╝╚═╝  ╚═╝╚═╝     ╚═╝╚═╝╚═╝  ╚═══╝╚═╝  ╚═╝╚══════╝"
  echo -e "${_r}"
  echo -e "  ${_b}Terminal Kit${_r} - Friendly Linux from scratch"
  echo -e "  A modern, beginner-friendly terminal setup for any Linux install."
  echo ""

  setup_priv
  detect_distro
  bootstrap
  install_core
  install_starship
  deploy_configs
  optional_installs
  verify

  echo ""
  echo -e "${_b}${_g}All done!${_r}"
  echo ""
  echo -e "  Reload your shell:  ${_c}source ~/.bashrc${_r}"
  echo -e "  Or open a new terminal and try:"
  echo ""
  echo -e "    ${_c}helpme${_r}        friendly help index"
  echo -e "    ${_c}tips${_r}          random bash tip"
  echo -e "    ${_c}sysinfo${_r}       system overview"
  echo -e "    ${_c}cheat tar${_r}     real-world command examples"
  echo ""

  if grep -qiE "(microsoft|wsl)" /proc/version 2>/dev/null; then
    echo -e "  ${_y}WSL:${_r} Set your font to 'JetBrainsMono Nerd Font' in Windows Terminal settings."
    echo ""
  fi
}

main "$@"
