# Terminal Kit — Arch Linux

A beginner-friendly terminal setup for a fresh Arch Linux install.
Run one script. Get a complete, beautiful, fully functional terminal environment.

Built for young people learning Linux for the first time. Everything you need to
use a computer — email, music, news, calendar, files, code — without leaving the
terminal.

---

## Quick Install

```bash
git clone https://github.com/grantis/tmkit-arch.git
cd tmkit-arch
bash install.sh
```

---

## What You Get

- Beautiful prompt with git info and system status (Starship + Nerd Font)
- Friendly built-in help system (`helpme`, `tips`, `cheat`)
- Safe file handling (`trash` instead of permanent delete)
- Smart error messages when you mistype a command
- A random tip every time you open a terminal
- `customize` command to change colors, prompt, editor, and shortcuts interactively

---

## What Gets Installed

### Core (automatic — everyone gets these)

| Tool | What it does |
|---|---|
| `starship` | Beautiful, fast prompt |
| `git` + `curl` + `wget` | Version control + downloading |
| `fzf` | Fuzzy search (makes Ctrl+R amazing) |
| `htop` | Live process monitor |
| `tree` | Visual folder structure |
| `tldr` | Plain-english man pages |
| `bat` | Better `cat` with syntax highlighting |
| `glow` | Render markdown files beautifully (`md file.md`) |
| `ncdu` | Interactive disk usage — find what's eating space |
| `rsync` | File sync and backup |
| `fastfetch` | Beautiful system info summary |
| `qalc` | Powerful calculator (`calc "15% of 80"`) |

### Development (optional)

| Tool | What it does |
|---|---|
| `neovim` | Modern text editor (optionally with LazyVim) |
| `lazygit` | Visual git interface |
| `nvm` | Node.js version manager |

### Daily Life (optional)

| Tool | What it does |
|---|---|
| `aerc` | Email client — read and send email in the terminal |
| `cmus` | Music player — plays mp3, flac, ogg and more |
| `mpv` | Video and audio player — plays almost anything |
| `yt-dlp` | Download YouTube videos or audio |
| `ncspot` | Spotify TUI |
| `newsboat` | RSS reader — follow news, blogs, YouTube channels |
| `calcurse` | Calendar and task manager |
| `yazi` | Visual file manager with image previews |
| `zathura` | PDF reader |
| `chafa` | View images directly in the terminal |

### Web Browsers (optional)

| Tool | What it does |
|---|---|
| `w3m` | Lightweight text-mode web browser |
| `lynx` | Classic text-mode web browser |
| `browsh` | Renders full web pages as colour blocks (drives Firefox) |
| `carbonyl` | Chromium in the terminal — images and video included |
| `ddgr` | DuckDuckGo search from the command line (`web <query>`) |

### Writing & Study (optional)

| Tool | What it does |
|---|---|
| `pandoc` | Convert notes: markdown → PDF / Word for assignments |
| `poppler` | `pdftotext` — read PDFs in the terminal, no GUI needed |
| `aspell` | Spell-check essays and notes |

### Security (optional)

| Tool | What it does |
|---|---|
| `pass` | Password manager — encrypted, stored locally, yours forever |
| `wl-clipboard` | Clipboard integration for Wayland (`clip` / `paste`) |

### Tasks & Fonts (optional)

| Tool | What it does |
|---|---|
| `taskwarrior` | Powerful to-do list manager |
| JetBrains Mono Nerd Font | Makes prompt icons render correctly |

---

## Shell Features

```bash
helpme                # full help index
helpme files          # navigating and managing files
helpme git            # version control basics
helpme ssh            # SSH keys and connecting to servers/GitHub
helpme network        # networking commands
helpme daily          # email, music, news, calendar, PDFs
helpme notes          # taking notes & studying in the terminal
helpme web            # browsers and searching the web
helpme packages       # installing software with pacman
helpme why            # the philosophy behind this setup

tips                  # random bash tip (also: tip)
sysinfo               # system overview
cheat <command>       # real-world examples for any command
customize             # interactive customization menu

note                  # open today's note (markdown in ~/notes)
note <title>          # open or create a note by name
notes                 # browse all notes (fzf + preview)
notes find <text>     # search inside every note

web <query>           # DuckDuckGo search, no browser needed
trash <file>          # safe delete — recoverable from ~/.trash
extract <archive>     # unzip/untar any archive format
mkcd <name>           # create a folder and enter it
please                # re-run last command with sudo

weather               # full weather forecast
wtf                   # one-line weather summary
calc "15% of 80"      # calculator
md file.md            # read a markdown file beautifully
```

---

## Your Settings Are Safe

Anything you change with `customize` — custom shortcuts, your default editor,
tip frequency — is written to `~/.config/tmkit/user.sh`, **not** `~/.bashrc`.
The installer never touches that file, so re-running `install.sh` to add new
tools won't wipe your personalisations. Your terminal grows with you.

---

## Config Files

```
configs/
  .bashrc                      → ~/.bashrc
  starship.toml                → ~/.config/starship.toml
  newsboat/urls                → ~/.newsboat/urls  (starter RSS feeds)
  aerc/accounts.conf.example  → reference for email setup
```

The installer also creates `~/.config/tmkit/user.sh` (your personal settings,
never overwritten) and your notes live in `~/notes`.

---

## Docs

```
docs/
  arch.md          Arch Linux essentials
  neovim.md        Setting up Neovim
  i3.md            Tiling window manager (for a full desktop)
  fonts.md         Installing Nerd Fonts
  taskwarrior.md   Task management
  quickref.md      Printable command reference
```

---

## Requirements

- Fresh Arch Linux install (post `archinstall`, logged in as a normal user with sudo)
- Internet connection
- That's it
