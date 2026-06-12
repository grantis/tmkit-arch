# ~/.bashrc - Terminal Kit
# Arch Linux first, works on Ubuntu/Debian too
# github.com/grantis/tmkit-arch

case $- in *i*) ;; *) return ;; esac

# ==============================================================================
# Locale & Environment
# ==============================================================================
export LANG=en_US.UTF-8
export TERM=xterm-256color
export GPG_TTY=$(tty)
export LESS='-R'

# ==============================================================================
# History
# ==============================================================================
HISTCONTROL=ignoreboth:erasedups
HISTSIZE=10000
HISTFILESIZE=20000
HISTTIMEFORMAT="%F %T  "
shopt -s histappend
PROMPT_COMMAND='history -a; history -c; history -r; '"$PROMPT_COMMAND"

# ==============================================================================
# Shell Options
# ==============================================================================
shopt -s checkwinsize autocd cdspell extglob
bind 'set show-all-if-ambiguous on'
bind 'set completion-ignore-case on'
bind 'set completion-map-case on'
bind 'TAB:menu-complete'
bind '"\e[Z": menu-complete-backward'
bind '"\e[A": history-search-backward'
bind '"\e[B": history-search-forward'

# ==============================================================================
# Colors & ls
# ==============================================================================
if command -v dircolors >/dev/null 2>&1; then
  test -r ~/.dircolors && eval "$(dircolors -b ~/.dircolors)" || eval "$(dircolors -b)"
fi
alias ls='ls --color=auto'
alias grep='grep --color=auto'
alias fgrep='fgrep --color=auto'
alias egrep='egrep --color=auto'

# ==============================================================================
# Aliases: core
# ==============================================================================
alias ll='ls -lah'
alias la='ls -A'
alias l='ls -CF'
alias cp='cp -i'
alias mv='mv -i'
alias rm='rm -i'
alias ..='cd ..'
alias ...='cd ../..'
please() { sudo $(fc -ln -1); }                        # re-run last command with sudo
alias path='echo $PATH | tr ":" "\n"'
alias ports='ss -tulnp'
alias myip='curl -s https://ifconfig.me'
alias localip='ip route get 1 2>/dev/null | awk "{print \$7}" | head -1'
alias reload='source ~/.bashrc && echo "✓ reloaded"'
alias bashrc='${EDITOR:-nano} ~/.bashrc'
alias starshiprc='${EDITOR:-nano} ~/.config/starship.toml'
alias update='sudo pacman -Syu'
alias install='sudo pacman -S'
alias search='pacman -Ss'
alias md='glow'                                        # read markdown files beautifully
alias news='newsboat'                                  # RSS / news reader
alias music='cmus'                                     # music player
alias email='aerc'                                     # email client
alias calendar='calcurse'                              # calendar & tasks
alias files='yazi'                                     # visual file manager
alias vid='mpv'                                        # video & audio player
alias calc='qalc'                                      # calculator (e.g. calc "15% of 80")
alias weather='curl -s wttr.in'                        # full weather forecast
alias wtf='curl -s "wttr.in?format=3"'                 # one-line weather summary
alias search='ddgr --np'                               # web search (ddgr must be installed)
alias reddit='tuir'                                    # Reddit TUI
# Clipboard: auto-detect Wayland vs X11
if [ -n "$WAYLAND_DISPLAY" ]; then
  alias clip='wl-copy'
  alias paste='wl-paste'
elif command -v xclip >/dev/null 2>&1; then
  alias clip='xclip -selection clipboard'
  alias paste='xclip -selection clipboard -o'
elif command -v xsel >/dev/null 2>&1; then
  alias clip='xsel --clipboard --input'
  alias paste='xsel --clipboard --output'
fi

# ==============================================================================
# Pager
# ==============================================================================
[ -x /usr/bin/lesspipe ] && eval "$(SHELL=/bin/sh lesspipe)"

# ==============================================================================
# trash: safer delete - moves to ~/.trash instead of permanent delete
# ==============================================================================
TRASH_DIR="$HOME/.trash"
mkdir -p "$TRASH_DIR"

trash() {
  if [ $# -eq 0 ]; then
    echo "Usage: trash <file|dir> [file2 ...]"
    echo "Moves files to ~/.trash instead of deleting permanently."
    return 1
  fi
  for item in "$@"; do
    if [ ! -e "$item" ]; then
      echo "trash: '$item' not found"
      continue
    fi
    local dest="$TRASH_DIR/$(basename "$item")_$(date +%s)"
    mv "$item" "$dest"
    echo "🗑️  Trashed: $item  →  $dest"
  done
}

trash-restore() {
  echo "Contents of trash (~/.trash):"
  ls -lh "$TRASH_DIR" 2>/dev/null || echo "(empty)"
  echo ""
  echo "To restore: mv ~/.trash/<filename> ./"
}

trash-empty() {
  read -rp "Empty trash? This is permanent. [y/N] " confirm
  [[ "$confirm" =~ ^[Yy]$ ]] && rm -rf "$TRASH_DIR"/* && echo "🧹 Trash emptied." || echo "Cancelled."
}

# ==============================================================================
# mkcd: make a directory and enter it
# ==============================================================================
mkcd() {
  if [ -z "$1" ]; then echo "Usage: mkcd <dirname>"; return 1; fi
  mkdir -p "$1" && cd "$1" && echo "📁 Created and entered: $(pwd)"
}

# ==============================================================================
# extract: universal archive extractor
# ==============================================================================
extract() {
  if [ -z "$1" ]; then
    echo "Usage: extract <archive>"
    echo "Supports: .tar.gz .tar.bz2 .tar.xz .zip .gz .bz2 .rar .7z .tar"
    return 1
  fi
  if [ ! -f "$1" ]; then
    echo "extract: '$1' not found"
    return 1
  fi
  echo "📦 Extracting $1..."
  case "$1" in
    *.tar.gz|*.tgz)   tar xzf "$1"   ;;
    *.tar.bz2|*.tbz2) tar xjf "$1"   ;;
    *.tar.xz)         tar xJf "$1"   ;;
    *.tar)            tar xf  "$1"   ;;
    *.zip)            unzip   "$1"   ;;
    *.gz)             gunzip  "$1"   ;;
    *.bz2)            bunzip2 "$1"   ;;
    *.rar)            unrar x "$1"   ;;
    *.7z)             7z x    "$1"   ;;
    *)                echo "Unknown archive format: $1"; return 1 ;;
  esac
  echo "✓ Done"
}

# ==============================================================================
# sysinfo: quick system overview
# ==============================================================================
sysinfo() {
  local _b="\033[1m" _r="\033[0m" _c="\033[0;36m"
  echo ""
  echo -e "${_b}System${_r}"
  echo -e "  ${_c}OS:${_r}      $(grep PRETTY_NAME /etc/os-release 2>/dev/null | cut -d= -f2 | tr -d '"')"
  echo -e "  ${_c}Kernel:${_r}  $(uname -r)"
  echo -e "  ${_c}Host:${_r}    $HOSTNAME"
  echo -e "  ${_c}Uptime:${_r}  $(uptime -p 2>/dev/null || uptime)"
  echo -e "  ${_c}Shell:${_r}   bash $BASH_VERSION"
  echo ""
  echo -e "${_b}Resources${_r}"
  echo -e "  ${_c}CPU:${_r}     $(grep -m1 'model name' /proc/cpuinfo 2>/dev/null | cut -d: -f2 | xargs)"
  echo -e "  ${_c}Memory:${_r}  $(free -h | awk '/^Mem:/{print $3 " used / " $2 " total"}')"
  echo -e "  ${_c}Disk:${_r}    $(df -h ~ | awk 'NR==2{print $3 " used / " $2 " total (" $5 " full)"}')"
  echo ""
  echo -e "${_b}Network${_r}"
  echo -e "  ${_c}Local IP:${_r} $(ip route get 1 2>/dev/null | awk '{print $7}' | head -1)"
  echo ""
}

# ==============================================================================
# cheat: plain-english command examples via cheat.sh
# ==============================================================================
cheat() {
  if [ -z "$1" ]; then
    echo "Usage: cheat <command>"
    echo "Examples: cheat grep  |  cheat tar  |  cheat git  |  cheat curl"
    return 1
  fi
  if command -v curl >/dev/null 2>&1; then
    curl -s "https://cheat.sh/$1" | ${PAGER:-less}
  else
    echo "cheat requires curl. Install: sudo pacman -S curl"
  fi
}

# ==============================================================================
# wiki: look up anything on Wikipedia, rendered beautifully
# Usage: wiki black holes   |   wiki linux kernel   |   wiki python language
# ==============================================================================
wiki() {
  if [ -z "$1" ]; then
    echo "Usage: wiki <topic>"
    echo "Examples: wiki black holes | wiki linux | wiki python"
    return 1
  fi
  local query="${*// /_}"
  if command -v curl >/dev/null 2>&1; then
    curl -s "https://en.wikipedia.org/api/rest_v1/page/summary/${query}" \
      | python3 -c "
import sys, json
try:
    d = json.load(sys.stdin)
    title = d.get('title','')
    desc  = d.get('description','')
    extract = d.get('extract','No article found.')
    print(f'\n\033[1m{title}\033[0m  \033[2m{desc}\033[0m\n')
    print(extract)
    print()
except Exception:
    print('Could not fetch article. Try: w3m https://en.wikipedia.org/wiki/' + sys.argv[1] if len(sys.argv)>1 else '')
" "$query"
  else
    echo "wiki requires curl. Install: sudo pacman -S curl"
  fi
}

# ==============================================================================
# tips: random bash tip shown on startup and on demand
# ==============================================================================
__bash_tips=(
  "Press Ctrl+R to search your command history interactively."
  "Press Ctrl+L to clear the screen (same as typing 'clear')."
  "Press Ctrl+A to jump to the start of a line, Ctrl+E to jump to the end."
  "Press Ctrl+W to delete the last word you typed."
  "Press Ctrl+U to wipe the entire current line."
  "Run 'history' to see past commands. Run '!42' to re-run command number 42."
  "Tab autocompletes filenames and commands. Press it twice to see all options."
  "Use 'cd -' to jump back to the last directory you were in."
  "Use 'mkdir -p a/b/c' to create nested directories in one step."
  "Use '!!' to repeat the last command. Great with 'sudo !!' when you forget sudo."
  "Use 'less file.txt' to read a file page by page. Press Q to quit."
  "Ctrl+Z suspends a running process. Type 'fg' to bring it back."
  "Use '> file.txt' to save output to a file. Use '>>' to append instead."
  "Use 'which <command>' to find where a program is installed."
  "Wildcards: '*.txt' matches all .txt files. '?' matches any single character."
  "Use 'wc -l file.txt' to count lines in a file."
  "Use 'grep -r searchterm .' to search all files in the current directory."
  "Run 'cheat <command>' for real-world examples of any command."
  "Run 'helpme' to see everything this terminal can do."
  "Run 'customize' to change colors, prompt style, and more."
  "Use 'update' to update all your Arch packages in one command."
  "Use 'mkcd myproject' to create a folder and enter it in one step."
  "Use 'trash file.txt' instead of 'rm' - you can recover it later."
  "Run 'md file.md' or 'glow file.md' to read markdown files with nice formatting."
  "Run 'music' or 'cmus' to open the music player. Space = play, n = next, q = quit."
  "Run 'email' or 'aerc' to check your email right in the terminal."
  "Run 'news' or 'newsboat' to read RSS feeds and stay up to date — no browser needed."
  "Run 'calendar' or 'calcurse' to see your calendar and manage tasks."
  "Run 'files' or 'yazi' to browse your files visually with previews."
  "Run 'w3m <url>' to browse a website without leaving the terminal."
  "Run 'helpme daily' to see all the daily-life tools in this kit."
  "Run 'helpme why' to understand the philosophy behind this setup."
  "Run 'weather' to see a full forecast right in the terminal — no browser needed."
  "Run 'wtf' for a quick one-line weather summary."
  "Run 'calc \"15% of 80\"' for instant calculations. Try calc \"sqrt(144)\" too."
  "Run 'ncdu' to see what's eating your disk space interactively."
  "Run 'fastfetch' to see a beautiful summary of your system."
  "Use 'rsync -av src/ dest/' to back up or sync folders — smarter than cp."
  "Run 'vid movie.mp4' or 'mpv' to play video or audio files."
  "Run 'yt-dlp <url>' to download a YouTube video or podcast."
  "Run 'pass' to manage passwords securely — all encrypted, all yours."
  "Run 'search linux tips' to search DuckDuckGo without a browser — no tracking, no ads."
  "Run 'wiki black holes' to read a Wikipedia article right in the terminal."
  "Run 'tuir -s linux' or 'reddit' to browse Reddit without a browser."
  "Run 'apps' to see everything installed and how to launch it."
)

tips() {
  local _b="\033[1;36m" _r="\033[0m" _y="\033[1;33m"
  local idx=$(( RANDOM % ${#__bash_tips[@]} ))
  echo -e "${_y}💡 Tip:${_r} ${__bash_tips[$idx]}"
  echo -e "   ${_b}Run 'tips' anytime for another. Run 'cheat <cmd>' for examples.${_r}"
}
alias tip='tips'

# ==============================================================================
# helpme: beginner-friendly help index
# ==============================================================================
helpme() {
  local _b="\033[1m" _r="\033[0m" _g="\033[1;32m" _c="\033[0;36m" _y="\033[1;33m"
  local topic="${1:-}"

  if [ -z "$topic" ]; then
    echo ""
    echo -e "${_b}${_g}  Quick Help${_r}  —  type 'helpme <topic>' for more"
    echo ""
    echo -e "  ${_y}helpme files${_r}       navigating and managing files"
    echo -e "  ${_y}helpme search${_r}      finding files and text"
    echo -e "  ${_y}helpme git${_r}         version control basics"
    echo -e "  ${_y}helpme network${_r}     networking commands"
    echo -e "  ${_y}helpme process${_r}     running processes and jobs"
    echo -e "  ${_y}helpme shortcuts${_r}   keyboard shortcuts"
    echo -e "  ${_y}helpme packages${_r}    installing software on Arch"
    echo -e "  ${_y}helpme daily${_r}       email, music, news, calendar, PDFs"
    echo -e "  ${_y}helpme ssh${_r}         connecting to servers and GitHub"
    echo -e "  ${_y}helpme why${_r}         what is this terminal kit and why it matters"
    echo ""
    echo -e "  ${_c}cheat <cmd>${_r}        real-world examples for any command"
    echo -e "  ${_c}tips${_r}               random useful tip"
    echo -e "  ${_c}sysinfo${_r}            system overview"
    echo -e "  ${_c}customize${_r}          change colors, style, shortcuts"
    echo ""
    return
  fi

  case "$topic" in
    files)
      echo -e "\n${_b}File Navigation & Management${_r}"
      echo -e "  ${_c}ls -lah${_r}            list files (sizes, hidden files)"
      echo -e "  ${_c}cd <dir>${_r}           enter a directory"
      echo -e "  ${_c}cd ..${_r}              go up one level"
      echo -e "  ${_c}cd -${_r}               go back to last directory"
      echo -e "  ${_c}pwd${_r}                show where you are right now"
      echo -e "  ${_c}mkcd <name>${_r}        create a folder and enter it"
      echo -e "  ${_c}cp <src> <dest>${_r}    copy a file"
      echo -e "  ${_c}mv <src> <dest>${_r}    move or rename a file"
      echo -e "  ${_c}trash <file>${_r}       safe delete (recoverable)"
      echo -e "  ${_c}trash-restore${_r}      see what's in the trash"
      echo -e "  ${_c}extract <file>${_r}     unzip/untar any archive"
      echo -e "  ${_c}cat <file>${_r}         print file contents"
      echo -e "  ${_c}less <file>${_r}        read file page by page (Q to quit)"
      echo -e "  ${_c}tree${_r}               visual folder structure"
      echo -e "  ${_c}glow <file.md>${_r}     read a markdown file beautifully (alias: md)"
      echo -e "  ${_c}yazi${_r}               visual file manager with previews (alias: files)"
      echo ""
      ;;
    search)
      echo -e "\n${_b}Finding Things${_r}"
      echo -e "  ${_c}grep 'text' file${_r}       search for text in a file"
      echo -e "  ${_c}grep -r 'text' .${_r}       search all files in current folder"
      echo -e "  ${_c}find . -name '*.txt'${_r}   find files by name"
      echo -e "  ${_c}find . -mtime -1${_r}       files modified in last 24h"
      echo -e "  ${_c}history | grep git${_r}     search your command history"
      echo -e "  ${_c}Ctrl+R${_r}                 live history search"
      echo ""
      ;;
    git)
      echo -e "\n${_b}Git Basics${_r}"
      echo -e "  ${_c}git status${_r}              see what changed"
      echo -e "  ${_c}git diff${_r}                see exact changes line by line"
      echo -e "  ${_c}git add .${_r}               stage all changes"
      echo -e "  ${_c}git commit -m 'msg'${_r}     save a snapshot with a message"
      echo -e "  ${_c}git push${_r}                send changes to GitHub"
      echo -e "  ${_c}git pull${_r}                get latest changes from GitHub"
      echo -e "  ${_c}git branch${_r}              list branches"
      echo -e "  ${_c}git switch <branch>${_r}     switch to a branch"
      echo -e "  ${_c}git log --oneline${_r}       compact history"
      echo -e "  ${_c}cheat git${_r}               more git examples"
      echo ""
      ;;
    network)
      echo -e "\n${_b}Networking${_r}"
      echo -e "  ${_c}myip${_r}               your public IP"
      echo -e "  ${_c}localip${_r}            your local network IP"
      echo -e "  ${_c}ports${_r}              what's listening on which port"
      echo -e "  ${_c}ping google.com${_r}    test internet connection"
      echo -e "  ${_c}curl <url>${_r}         fetch a URL"
      echo -e "  ${_c}wget <url>${_r}         download a file"
      echo -e "  ${_c}ssh user@host${_r}      connect to a remote machine"
      echo ""
      ;;
    process)
      echo -e "\n${_b}Processes & Jobs${_r}"
      echo -e "  ${_c}ps aux${_r}             list all running processes"
      echo -e "  ${_c}htop${_r}               live process monitor (Q to quit)"
      echo -e "  ${_c}kill <pid>${_r}         stop a process by ID"
      echo -e "  ${_c}killall <name>${_r}     stop all processes by name"
      echo -e "  ${_c}Ctrl+C${_r}             cancel current command"
      echo -e "  ${_c}Ctrl+Z${_r}             suspend current command"
      echo -e "  ${_c}fg${_r}                 bring suspended job back"
      echo -e "  ${_c}command &${_r}          run in background"
      echo ""
      ;;
    shortcuts)
      echo -e "\n${_b}Keyboard Shortcuts${_r}"
      echo -e "  ${_c}Ctrl+R${_r}    search history"
      echo -e "  ${_c}Ctrl+L${_r}    clear screen"
      echo -e "  ${_c}Ctrl+C${_r}    cancel command"
      echo -e "  ${_c}Ctrl+Z${_r}    suspend command"
      echo -e "  ${_c}Ctrl+A${_r}    start of line"
      echo -e "  ${_c}Ctrl+E${_r}    end of line"
      echo -e "  ${_c}Ctrl+W${_r}    delete last word"
      echo -e "  ${_c}Ctrl+U${_r}    delete whole line"
      echo -e "  ${_c}Tab${_r}       autocomplete"
      echo -e "  ${_c}↑ / ↓${_r}     scroll history"
      echo ""
      ;;
    packages)
      echo -e "\n${_b}Installing Software (Arch / pacman)${_r}"
      echo -e "  ${_c}update${_r}                     update everything"
      echo -e "  ${_c}install <name>${_r}             install a package"
      echo -e "  ${_c}search <name>${_r}              search for a package"
      echo -e "  ${_c}sudo pacman -R <name>${_r}      remove a package"
      echo -e "  ${_c}sudo pacman -Ql <name>${_r}     list files in a package"
      echo -e "  ${_c}pacman -Qi <name>${_r}          info about a package"
      echo ""
      echo -e "  ${_b}AUR (community packages):${_r}"
      echo -e "  ${_c}yay -S <name>${_r}              install from AUR (if yay installed)"
      echo -e "  ${_c}yay -Ss <name>${_r}             search AUR"
      echo ""
      ;;
    daily)
      echo -e "\n${_b}Daily Life in the Terminal${_r}"
      echo -e "  Everything you need — no browser required.\n"
      echo -e "  ${_b}Reading${_r}"
      echo -e "  ${_c}md <file.md>${_r}       read a markdown file beautifully (glow)"
      echo -e "  ${_c}glow docs/${_r}         browse a folder of markdown files"
      echo -e "  ${_c}wiki <topic>${_r}        Wikipedia article in the terminal"
      echo -e "  ${_c}zathura <file.pdf>${_r} open a PDF (needs desktop env)"
      echo ""
      echo -e "  ${_b}Search & Web${_r}"
      echo -e "  ${_c}search <query>${_r}      DuckDuckGo search — no tracking, no ads"
      echo -e "  ${_c}w3m <url>${_r}           browse any website in the terminal"
      echo -e "  ${_c}tuir -s <topic>${_r}     browse Reddit (alias: reddit)"
      echo -e "  ${_c}news / newsboat${_r}     RSS reader (add feeds: ~/.newsboat/urls)"
      echo -e "  ${_c}weather${_r}             full weather forecast"
      echo -e "  ${_c}wtf${_r}                 one-line weather summary"
      echo ""
      echo -e "  ${_b}Email${_r}"
      echo -e "  ${_c}email${_r} / ${_c}aerc${_r}       open your email client"
      echo -e "  First-time setup: run 'aerc' and follow the wizard"
      echo ""
      echo -e "  ${_b}Music & Video${_r}"
      echo -e "  ${_c}music${_r} / ${_c}cmus${_r}       music player (Space=play, n=next, q=quit)"
      echo -e "  ${_c}vid <file>${_r} / ${_c}mpv${_r}   play video or audio files"
      echo -e "  ${_c}yt-dlp <url>${_r}       download YouTube video or audio"
      echo -e "  ${_c}ncspot${_r}              Spotify in the terminal"
      echo ""
      echo -e "  ${_b}Calendar, Tasks & Calculator${_r}"
      echo -e "  ${_c}calendar${_r} / ${_c}calcurse${_r}  calendar + to-do list"
      echo -e "  ${_c}task add 'buy milk'${_r}   add a task (taskwarrior)"
      echo -e "  ${_c}task${_r}                  list your tasks"
      echo -e "  ${_c}calc '15% of 80'${_r}      quick maths (try: calc 'sqrt(144)')"
      echo ""
      echo -e "  ${_b}Files & System${_r}"
      echo -e "  ${_c}files${_r} / ${_c}yazi${_r}        visual file manager with previews"
      echo -e "  ${_c}ncdu${_r}                disk usage — find what's eating space"
      echo -e "  ${_c}rsync -av src/ dest/${_r}  sync or back up a folder"
      echo -e "  ${_c}fastfetch${_r}           beautiful system summary"
      echo ""
      echo -e "  ${_b}Security${_r}"
      echo -e "  ${_c}pass init <email>${_r}   set up your password manager"
      echo -e "  ${_c}pass add github${_r}     store a password"
      echo -e "  ${_c}pass github${_r}         retrieve a password"
      echo ""
      ;;
    ssh)
      echo -e "\n${_b}SSH — Connecting to Servers & GitHub${_r}"
      echo -e "  ${_b}Generate a key (do this once):${_r}"
      echo -e "  ${_c}ssh-keygen -t ed25519 -C 'you@example.com'${_r}"
      echo -e "  ${_c}cat ~/.ssh/id_ed25519.pub${_r}    copy this → paste into GitHub/server"
      echo ""
      echo -e "  ${_b}Connect to a server:${_r}"
      echo -e "  ${_c}ssh user@hostname${_r}            connect (will ask for password first time)"
      echo -e "  ${_c}ssh-copy-id user@hostname${_r}    install your key so no password needed"
      echo ""
      echo -e "  ${_b}GitHub SSH setup:${_r}"
      echo -e "  1. Run: ssh-keygen -t ed25519 -C 'your@email.com'"
      echo -e "  2. Run: cat ~/.ssh/id_ed25519.pub"
      echo -e "  3. Copy the output"
      echo -e "  4. Go to github.com → Settings → SSH Keys → New SSH Key → Paste"
      echo -e "  5. Test with: ssh -T git@github.com"
      echo ""
      echo -e "  ${_b}Useful:${_r}"
      echo -e "  ${_c}~/.ssh/config${_r}    save shortcuts (Host myserver → ssh myserver)"
      echo -e "  ${_c}cheat ssh${_r}        more ssh examples"
      echo ""
      ;;
    why)
      echo ""
      echo -e "\033[1;32m  Why this terminal kit?\033[0m"
      echo ""
      echo -e "  Most computers are designed to keep you distracted —"
      echo -e "  ads, notifications, apps that want your attention."
      echo ""
      echo -e "  A Unix terminal is the opposite. It's a tool you control."
      echo -e "  Nothing runs unless you tell it to."
      echo -e "  Nothing watches you. Nothing sells you anything."
      echo ""
      echo -e "  When you learn the terminal, you learn how computers"
      echo -e "  actually work — not just how to click on things."
      echo -e "  That knowledge doesn't go out of date."
      echo ""
      echo -e "  You can write code, manage files, read the news,"
      echo -e "  listen to music, check email, and build software —"
      echo -e "  all without leaving this window."
      echo ""
      echo -e "  \033[0;36mThis kit is your starting point.\033[0m"
      echo -e "  The rest is up to you."
      echo ""
      ;;
    *)
      echo "Unknown topic: '$topic'"
      echo "Try: files, search, git, network, process, shortcuts, packages, daily, why"
      ;;
  esac
}

# ==============================================================================
# apps: live dashboard — shows what's installed and how to launch it
# ==============================================================================
apps() {
  local _b="\033[1m" _r="\033[0m" _g="\033[1;32m" _y="\033[1;33m" _c="\033[0;36m" _dim="\033[2m"
  local ok="${_g}✓${_r}" no="${_dim}-${_r}"
  local filter="${1:-}"

  _app() {
    local cmd="$1" label="$2" hint="$3"
    # If a filter is set, only show matching rows
    if [ -n "$filter" ] && [[ "$label $cmd" != *"$filter"* ]]; then return; fi
    if command -v "$cmd" >/dev/null 2>&1; then
      printf "  %b  %-32s %b%s%b\n" "$ok" "$label" "$_c" "$hint" "$_r"
    else
      printf "  %b  %b%-32s not installed: sudo pacman -S %s%b\n" "$no" "$_dim" "$label" "$cmd" "$_r"
    fi
  }

  echo ""
  echo -e "${_b}  Your apps${_r}  ${_dim}(✓ ready  - not installed)${_r}"
  echo ""

  echo -e "  ${_b}Reading & Files${_r}"
  _app glow      "md / glow        markdown"     "md file.md"
  _app yazi      "files / yazi     file manager" "files"
  _app bat       "bat              better cat"   "bat file.txt"
  _app zathura   "zathura          PDF reader"   "zathura file.pdf"
  _app chafa     "chafa            image viewer" "chafa photo.jpg"
  echo ""

  echo -e "  ${_b}Email & Web${_r}"
  _app aerc      "email / aerc     email"        "email"
  _app newsboat  "news / newsboat  RSS reader"   "news"
  _app w3m       "w3m              web browser"  "w3m https://example.com"
  _app ddgr      "search / ddgr    web search"   "search linux tips"
  echo ""

  echo -e "  ${_b}Music & Video${_r}"
  _app cmus      "music / cmus     music player" "music"
  _app mpv       "vid / mpv        video & audio" "vid file.mp4"
  _app yt-dlp    "yt-dlp           downloader"   "yt-dlp <url>"
  _app ncspot    "ncspot           Spotify"       "ncspot"
  _app tuir      "tuir             Reddit TUI"    "tuir -s linux"
  echo ""

  echo -e "  ${_b}Productivity${_r}"
  _app calcurse  "calendar         calendar"     "calendar"
  _app task      "task             to-do list"   "task add 'thing'"
  _app qalc      "calc             calculator"   "calc '15% of 80'"
  _app ncdu      "ncdu             disk usage"   "ncdu"
  _app fastfetch "fastfetch        system info"  "fastfetch"
  echo ""

  echo -e "  ${_b}Development${_r}"
  _app nvim      "nvim             text editor"  "nvim file.txt"
  _app git       "git              version ctrl" "git status"
  _app lazygit   "lazygit          git TUI"      "lazygit"
  _app node      "node / nvm       javascript"   "node --version"
  echo ""

  echo -e "  ${_b}Security${_r}"
  _app pass      "pass             passwords"    "pass init <email>"
  _app wl-copy   "clip / paste     clipboard"    "echo hello | clip"
  echo ""

  # Count missing
  local missing=0
  for cmd in glow yazi bat zathura chafa aerc newsboat w3m ddgr cmus mpv yt-dlp ncspot tuir calcurse task qalc ncdu fastfetch nvim git lazygit pass wl-copy; do
    command -v "$cmd" >/dev/null 2>&1 || (( missing++ )) || true
  done

  if [ "$missing" -gt 0 ]; then
    echo -e "  ${_y}$missing apps not yet installed.${_r}"
    echo -e "  Run ${_c}bash ~/tmkit-arch/install.sh${_r} and answer Y to add them."
  else
    echo -e "  ${_g}All apps installed — you're fully equipped!${_r}"
  fi
  echo ""
}

# ==============================================================================
# command_not_found_handle: friendly error when a command doesn't exist
# ==============================================================================
command_not_found_handle() {
  local _r="\033[0m" _y="\033[1;33m" _c="\033[0;36m"
  echo -e "${_y}Command not found:${_r} $1"

  if command -v pacman >/dev/null 2>&1; then
    echo -e "${_c}Try installing it:${_r} sudo pacman -S $1"
  fi

  case "$1" in
    vim|vi)      echo -e "${_c}Tip:${_r} Install with: sudo pacman -S vim" ;;
    python)      echo -e "${_c}Tip:${_r} Try 'python3' instead" ;;
    pip)         echo -e "${_c}Tip:${_r} Try 'pip3' instead" ;;
    cls)         echo -e "${_c}Tip:${_r} Use 'clear' or Ctrl+L" ;;
    dir)         echo -e "${_c}Tip:${_r} Use 'ls' to list files" ;;
    ipconfig)    echo -e "${_c}Tip:${_r} Use 'ip addr' or 'localip'" ;;
    ifconfig)    echo -e "${_c}Tip:${_r} Use 'ip addr' or install: sudo pacman -S net-tools" ;;
    apt|apt-get) echo -e "${_c}Tip:${_r} On Arch, use 'sudo pacman -S <package>' or just 'install <package>'" ;;
    brew)        echo -e "${_c}Tip:${_r} On Arch, use pacman instead. Try: helpme packages" ;;
  esac

  echo -e "  Run ${_c}cheat <command>${_r} for examples, or ${_c}helpme${_r} for help."
  return 127
}

# ==============================================================================
# customize: interactive menu to personalize the terminal
# ==============================================================================
__color_palettes=(
  "Ocean Blue      #118ab2"
  "Hacker Green    #06d6a0"
  "Sunset Orange   #f17c1d"
  "Galaxy Purple   #9b5de5"
  "Cherry Red      #ef476f"
  "Gold            #ffd166"
  "Cyber Cyan      #00f5d4"
  "Hot Pink        #ff006e"
)

__pick_color() {
  local label="$1"
  local _b="\033[1m" _r="\033[0m" _y="\033[1;33m" _c="\033[0;36m"
  echo ""
  echo -e "${_b}Pick a color for $label:${_r}"
  echo ""
  for i in "${!__color_palettes[@]}"; do
    local name hex
    name=$(echo "${__color_palettes[$i]}" | awk '{print $1, $2}')
    hex=$(echo "${__color_palettes[$i]}" | awk '{print $NF}')
    printf "  %s%d)%s %-18s %s\n" "$_y" "$((i+1))" "$_r" "$name" "$hex"
  done
  echo "  9) Custom hex (e.g. #ff6600)"
  echo ""
  read -rp "  Pick [1-9]: " pick

  PICKED_HEX=""
  if [[ "$pick" =~ ^[1-8]$ ]]; then
    PICKED_HEX=$(echo "${__color_palettes[$((pick-1))]}" | awk '{print $NF}')
  elif [ "$pick" = "9" ]; then
    read -rp "  Enter hex: " PICKED_HEX
    [[ ! "$PICKED_HEX" =~ ^#[0-9a-fA-F]{6}$ ]] && echo "  Invalid hex." && PICKED_HEX="" && return 1
  else
    return 1
  fi
}

__customize_prompt_style() {
  local _b="\033[1m" _r="\033[0m" _c="\033[0;36m"
  local toml="$HOME/.config/starship.toml"
  [ ! -f "$toml" ] && echo "  starship.toml not found." && return

  echo ""
  echo -e "${_b}Choose prompt style:${_r}"
  echo ""
  echo "  1) Two-line  (default)"
  echo "     ┌─ user@host ~/projects  branch"
  echo "     └─> ❯"
  echo ""
  echo "  2) Single line"
  echo "     user ~/projects  branch ❯"
  echo ""
  echo "  3) Minimal"
  echo "     ~/projects ❯"
  echo ""
  read -rp "  Pick [1-3]: " pick

  # Use python to safely rewrite the multiline format block in TOML
  local new_format
  case "$pick" in
    1) new_format='format = """\n[┌─](#0f4c81)$username$hostname$directory$git_branch$git_status\n[└─>](#0f4c81)$nodejs$python$cmd_duration$status $character"""' ;;
    2) new_format='format = "$username$hostname$directory$git_branch$git_status$nodejs$python$cmd_duration$status$character"' ;;
    3) new_format='format = "$directory$git_branch$status$character"' ;;
    *) echo "  Skipped."; return ;;
  esac

  python3 - "$toml" "$new_format" << 'PYEOF'
import sys, re
toml_path, new_fmt = sys.argv[1], sys.argv[2]
with open(toml_path) as f:
    content = f.read()
# Replace the entire format = """..""" or format = ".." block at the top level
content = re.sub(r'^format = """.*?"""', new_fmt, content, flags=re.DOTALL|re.MULTILINE, count=1)
content = re.sub(r'^format = "[^"]*"', new_fmt, content, flags=re.MULTILINE, count=1)
with open(toml_path, 'w') as f:
    f.write(content)
PYEOF
  echo -e "  ${_c}✓ Prompt style updated — run 'reload' or open a new terminal${_r}"
}

__customize_color_menu() {
  local _b="\033[1m" _r="\033[0m" _c="\033[0;36m"
  local toml="$HOME/.config/starship.toml"
  [ ! -f "$toml" ] && echo "  starship.toml not found." && return

  echo ""
  echo -e "${_b}Which color to change?${_r}"
  echo "  1) Directory path"
  echo "  2) Git branch"
  echo "  3) Hostname"
  echo "  4) Command duration"
  echo ""
  read -rp "  Pick [1-4]: " pick

  local label marker
  case "$pick" in
    1) label="directory"      ; marker="# directory" ;;
    2) label="git branch"     ; marker="# git_branch" ;;
    3) label="hostname"       ; marker="bold #ffd166" ;;
    4) label="command timer"  ; marker="bold #f17c1d" ;;
    *) echo "  Skipped." ; return ;;
  esac

  __pick_color "$label"
  [ -z "$PICKED_HEX" ] && return

  # Replace the specific line containing the marker
  sed -i "/$marker/s/#[0-9a-fA-F]\{6\}/$( echo $PICKED_HEX | tr -d '#' | sed 's/^/#/')/" "$toml"
  echo -e "  ${_c}✓ $label color set to $PICKED_HEX${_r}"
}

__customize_tips() {
  local _b="\033[1m" _r="\033[0m" _c="\033[0;36m"
  echo ""
  echo -e "${_b}Tip frequency on startup:${_r}"
  echo "  1) Every time (default)"
  echo "  2) Sometimes (1 in 3)"
  echo "  3) Rarely (1 in 10)"
  echo "  4) Never"
  echo ""
  read -rp "  Pick [1-4]: " pick

  # Clean up old setting
  sed -i '/# TIP_FREQUENCY/d' "$HOME/.bashrc"
  sed -i '/^__tip_roll/d' "$HOME/.bashrc"
  sed -i 's/^  __tip_roll$/  tips/' "$HOME/.bashrc"
  sed -i 's/^  : # tips disabled$/  tips/' "$HOME/.bashrc"

  case "$pick" in
    1) echo -e "  ${_c}✓ Tips on every startup${_r}" ;;
    2) echo '__tip_roll() { (( RANDOM % 3 == 0 )) && tips; } # TIP_FREQUENCY' >> "$HOME/.bashrc"
       sed -i 's/^  tips$/  __tip_roll/' "$HOME/.bashrc"
       echo -e "  ${_c}✓ Tips on sometimes${_r}" ;;
    3) echo '__tip_roll() { (( RANDOM % 10 == 0 )) && tips; } # TIP_FREQUENCY' >> "$HOME/.bashrc"
       sed -i 's/^  tips$/  __tip_roll/' "$HOME/.bashrc"
       echo -e "  ${_c}✓ Tips set to rarely${_r}" ;;
    4) sed -i 's/^  tips$/  : # tips disabled/' "$HOME/.bashrc"
       echo -e "  ${_c}✓ Tips disabled${_r}" ;;
    *) echo "  Skipped." ;;
  esac
}

__customize_editor() {
  local _b="\033[1m" _r="\033[0m" _c="\033[0;36m"
  echo ""
  echo -e "${_b}Choose default editor:${_r}"
  echo "  1) nano   (easiest for beginners)"
  echo "  2) nvim   (neovim - powerful, worth learning)"
  echo "  3) vim    (classic)"
  echo ""
  read -rp "  Pick [1-3]: " pick

  local editor
  case "$pick" in
    1) editor="nano" ;;
    2) editor="nvim" ;;
    3) editor="vim"  ;;
    *) echo "  Skipped." ; return ;;
  esac

  if ! command -v "$editor" >/dev/null 2>&1; then
    echo "  $editor not installed. Install it with: sudo pacman -S $editor"
    return
  fi

  sed -i '/^export EDITOR=/d' "$HOME/.bashrc"
  sed -i '/^export VISUAL=/d' "$HOME/.bashrc"
  echo "export EDITOR=$editor" >> "$HOME/.bashrc"
  echo "export VISUAL=$editor" >> "$HOME/.bashrc"
  echo -e "  ${_c}✓ Default editor set to $editor${_r}"
}

__customize_alias() {
  local _b="\033[1m" _r="\033[0m" _c="\033[0;36m" _y="\033[1;33m"
  echo ""
  echo -e "${_b}Add a custom shortcut${_r}"
  echo ""
  echo -e "  A shortcut (alias) lets you type something short instead of a long command."
  echo -e "  Example: type ${_y}dev${_r} instead of ${_y}cd ~/projects && ls${_r}"
  echo ""
  read -rp "  Shortcut name (e.g. 'dev'): " alias_name
  [ -z "$alias_name" ] && echo "  Skipped." && return

  read -rp "  Command to run (e.g. 'cd ~/projects'): " alias_cmd
  [ -z "$alias_cmd" ] && echo "  Skipped." && return

  if alias "$alias_name" >/dev/null 2>&1; then
    read -rp "  '$alias_name' already exists. Overwrite? [y/N] " confirm
    [[ ! "$confirm" =~ ^[Yy]$ ]] && return
    sed -i "/^alias ${alias_name}=/d" "$HOME/.bashrc"
  fi

  printf '\n# Custom shortcut\nalias %s=%q\n' "$alias_name" "$alias_cmd" >> "$HOME/.bashrc"
  echo -e "  ${_c}✓ Added: ${alias_name}='${alias_cmd}'${_r}"
  echo -e "  ${_c}  Run 'reload' to use it now${_r}"
}

customize() {
  local _b="\033[1m" _r="\033[0m" _g="\033[1;32m" _c="\033[0;36m" _y="\033[1;33m"

  while true; do
    echo ""
    echo -e "${_b}${_g}  ⚙  Customize your terminal${_r}"
    echo -e "  ───────────────────────────────────"
    echo -e "  ${_y}1)${_r} Change prompt style"
    echo -e "  ${_y}2)${_r} Change colors"
    echo -e "  ${_y}3)${_r} Tip frequency"
    echo -e "  ${_y}4)${_r} Default editor"
    echo -e "  ${_y}5)${_r} Add a shortcut (alias)"
    echo -e "  ${_y}6)${_r} Open config files directly"
    echo -e "  ${_y}7)${_r} Apply changes now"
    echo -e "  ${_y}0)${_r} Done"
    echo ""
    read -rp "  Pick [0-7]: " choice

    case "$choice" in
      1) __customize_prompt_style ;;
      2) __customize_color_menu ;;
      3) __customize_tips ;;
      4) __customize_editor ;;
      5) __customize_alias ;;
      6)
        echo ""
        echo -e "  ${_c}bashrc${_r}       opens ~/.bashrc"
        echo -e "  ${_c}starshiprc${_r}   opens ~/.config/starship.toml"
        echo -e "  Run either command to edit directly."
        ;;
      7)
        source "$HOME/.bashrc" 2>/dev/null
        echo -e "  ${_c}✓ Applied!${_r}"
        ;;
      0|q|Q)
        echo -e "\n  Run ${_c}customize${_r} anytime to change things.\n"
        break
        ;;
      *) echo "  Type a number from the menu." ;;
    esac
  done
}

# ==============================================================================
# Bash Completion
# ==============================================================================
if ! shopt -oq posix; then
  if [ -f /usr/share/bash-completion/bash_completion ]; then
    . /usr/share/bash-completion/bash_completion
  elif [ -f /etc/bash_completion ]; then
    . /etc/bash_completion
  fi
fi

# ==============================================================================
# Starship Prompt
# ==============================================================================
if command -v starship >/dev/null 2>&1; then
  eval "$(starship init bash)"
else
  PS1='\u@\h:\w\$ '
fi

# ==============================================================================
# Optional: ble.sh (autosuggestions + syntax highlighting)
# ==============================================================================
[ -f ~/.ble.sh/out/ble.sh ] && source ~/.ble.sh/out/ble.sh

# ==============================================================================
# Optional: FZF
# ==============================================================================
[ -f ~/.fzf.bash ] && source ~/.fzf.bash

# ==============================================================================
# Node Version Manager (nvm)
# ==============================================================================
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ]            && . "$NVM_DIR/nvm.sh"
[ -s "$NVM_DIR/bash_completion" ]   && . "$NVM_DIR/bash_completion"

__nvm_auto_switch() {
  [ ! -f ".nvmrc" ] && return
  local want have
  want=$(nvm version "$(cat .nvmrc)")
  have=$(nvm version)
  [ "$want" = "$have" ] && return
  [ "$want" = "N/A" ] && echo "Installing node from .nvmrc..." && nvm install && return
  nvm use --silent
}

cd() { builtin cd "$@" && __nvm_auto_switch; }
__nvm_auto_switch

# ==============================================================================
# pyenv
# ==============================================================================
if command -v pyenv >/dev/null 2>&1; then
  export PYENV_ROOT="$HOME/.pyenv"
  export PATH="$PYENV_ROOT/bin:$PATH"
  eval "$(pyenv init - bash)"
fi

# ==============================================================================
# direnv
# ==============================================================================
command -v direnv >/dev/null 2>&1 && eval "$(direnv hook bash)"

# ==============================================================================
# PATH
# ==============================================================================
[ -d "$HOME/.local/bin" ] && PATH="$HOME/.local/bin:$PATH"
[ -d "$HOME/bin" ]        && PATH="$HOME/bin:$PATH"
[ -d "$HOME/projects" ]   && alias proj='cd "$HOME/projects"'
export PATH

# ==============================================================================
# corepack
# ==============================================================================
command -v corepack >/dev/null 2>&1 && corepack enable >/dev/null 2>&1 || true

# ==============================================================================
# Startup
# ==============================================================================
if [[ $- == *i* ]]; then
  printf "\n\033[1;32m  ★  Welcome back, %s!\033[0m  (\033[0;36m%s\033[0m)\n" "$USER" "$HOSTNAME"
  printf "     \033[1;33mhelpme\033[0m · \033[1;33mapps\033[0m · \033[1;33mtips\033[0m · \033[1;33msysinfo\033[0m · \033[1;33mcustomize\033[0m\n\n"
  if [ ! -f "$HOME/.tkrc" ]; then
    echo -e "\033[1;33m  👋 First time? Run \033[0;36mapps\033[1;33m to see what's ready to use, or \033[0;36mhelpme\033[1;33m to explore.\033[0m\n"
    touch "$HOME/.tkrc"
  fi
  tips
fi
