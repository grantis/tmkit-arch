# Arch Linux - Getting Started

Arch gives you nothing but a terminal and a package manager.
This guide gets you to the point where you can run `install.sh`.

---

## Install Arch (VirtualBox)

### 1. Boot the ISO

Download the ISO from https://archlinux.org/download/
In VirtualBox: New VM > Linux > Arch Linux 64-bit > 2GB RAM > 20GB disk

### 2. Connect to the internet

```bash
# Wired (usually auto-works in VirtualBox)
ping archlinux.org

# WiFi (if needed)
iwctl
  device list
  station wlan0 scan
  station wlan0 get-networks
  station wlan0 connect "NetworkName"
  exit
```

### 3. Run the guided installer (easiest for beginners)

```bash
archinstall
```

This is a TUI installer added in 2021. Go through the menus:
- Language: English
- Mirrors: your region
- Disk: use the whole disk, ext4 is fine
- Bootloader: GRUB
- Profile: **Minimal** (no desktop - we're building a terminal setup)
- Audio: skip
- Network: NetworkManager
- Extra packages: `git curl`
- Root password: set one
- User account: create one, give it sudo

Let it install and reboot.

---

## After first boot

You'll land at a login prompt. Log in with your user account.

### Check internet

```bash
ping -c 3 archlinux.org
```

If no internet, start NetworkManager:

```bash
sudo systemctl enable --now NetworkManager
nmcli device status
nmcli device connect eth0    # or your interface name
```

### Update the system first

```bash
sudo pacman -Syu
```

Always do this before installing anything on a fresh Arch install.

---

## Run Terminal Kit

```bash
# Clone and run
git clone https://github.com/YOUR_USERNAME/terminal-kit.git
cd terminal-kit
bash install.sh
```

If git isn't available yet:

```bash
sudo pacman -S git
git clone https://github.com/YOUR_USERNAME/terminal-kit.git
cd terminal-kit
bash install.sh
```

---

## What the install script adds on Arch

Everything via `pacman` - no PPAs, no external repos needed for the core tools:

```
starship        from pacman (not the install script)
fzf             pacman
htop            pacman
tree            pacman
unzip           pacman
tealdeer        pacman (tldr)
bat             pacman
neovim          pacman
lazygit         pacman
task            pacman (taskwarrior)
fontconfig      pacman (for font installs)
```

Arch's package manager is one of the best parts of using it - nearly everything
is available and up to date, no PPAs or weird workarounds needed.

---

## AUR (Arch User Repository)

The AUR has packages not in the main repos. You need an AUR helper:

```bash
# Install yay (most popular AUR helper)
sudo pacman -S --needed base-devel
git clone https://aur.archlinux.org/yay.git
cd yay
makepkg -si
```

Then use `yay` exactly like `pacman`:

```bash
yay -S some-aur-package
```

---

## Useful Arch commands

```bash
sudo pacman -Syu              update everything
sudo pacman -S <package>      install
sudo pacman -R <package>      remove
sudo pacman -Rs <package>     remove + unused dependencies
pacman -Ss <search>           search packages
pacman -Qi <package>          info about installed package
pacman -Ql <package>          list files installed by package
sudo pacman -Sc               clear package cache
```

---

## If you want a GUI later

The video uses i3. After terminal kit is set up:

```bash
sudo pacman -S xorg-server i3 alacritty rofi picom feh
# See docs/i3.md for full setup
```

Or a lightweight desktop environment:

```bash
# XFCE (very light, good for older hardware)
sudo pacman -S xfce4 xfce4-goodies lightdm lightdm-gtk-greeter
sudo systemctl enable lightdm

# Or just i3 (even lighter, keyboard driven)
sudo pacman -S i3 xorg lightdm lightdm-gtk-greeter
sudo systemctl enable lightdm
```
