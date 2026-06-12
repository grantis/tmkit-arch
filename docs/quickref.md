# Terminal Kit — Quick Reference

Open with: `md docs/quickref.md`

---

## Navigation

```
pwd                  where am I?
ls                   list files
ls -lah              list with sizes + hidden files
cd folder            enter a folder
cd ..                go up one level
cd -                 go back to last folder
cd ~                 go home
tree                 visual folder structure
files / yazi         visual file manager with previews
```

---

## Files

```
cat file.txt          print file contents
less file.txt         read file page by page (Q to quit)
bat file.txt          cat with syntax highlighting
md file.md            render a markdown file beautifully
nano file.txt         edit a file (Ctrl+S save, Ctrl+X quit)
nvim file.txt         neovim (i to type, Esc then :wq to save+quit)
cp file copy.txt      copy a file
mv old.txt new.txt    move or rename a file
trash file.txt        safe delete — recoverable from ~/.trash
trash-restore         see what's in the trash
trash-empty           permanently empty trash
mkdir folder          create a folder
mkcd folder           create a folder and enter it
extract file.zip      unzip/untar any archive format
rsync -av src/ dest/  sync or back up a folder
chafa photo.jpg       view an image in the terminal
```

---

## Finding Things

```
grep 'text' file.txt      search for text in a file
grep -r 'text' .          search all files in current folder
find . -name '*.txt'      find files by name
find . -mtime -1          files changed in last 24h
history | grep git        search your command history
Ctrl+R                    live interactive history search
```

---

## System

```
sysinfo          system overview (this kit)
fastfetch        beautiful system summary with ASCII art
htop             live process monitor (Q to quit)
ncdu             interactive disk usage — find what's eating space
df -h            disk space
free -h          memory usage
uptime           how long system has been running
whoami           your username
uname -r         kernel version
```

---

## Network

```
myip                 your public IP
localip              your local network IP
weather              full weather forecast (no browser needed)
wtf                  one-line weather summary
ping google.com      test internet (Ctrl+C to stop)
wget <url>           download a file
curl <url>           fetch a URL
ports                what's listening on which port
w3m <url>            browse a website in the terminal
ssh user@host        connect to a remote machine
```

---

## Daily Life

```
email / aerc         read and send email
music / cmus         music player (Space=play, n=next, q=quit)
vid <file> / mpv     play video or audio
yt-dlp <url>         download YouTube video or audio
ncspot               Spotify in the terminal
news / newsboat      RSS reader (r=refresh, q=quit)
calendar / calcurse  calendar + tasks
task add 'thing'     add a to-do (taskwarrior)
task                 list your tasks
calc '15% of 80'     powerful calculator (try: calc 'sqrt(144)')
zathura file.pdf     PDF reader (needs desktop environment)
```

---

## Git

```
git status              see what changed
git diff                see exact changes
git add .               stage all changes
git commit -m 'msg'     save a snapshot
git push                send to GitHub
git pull                get latest changes
git branch              list branches
git switch <branch>     switch branch
git log --oneline       compact history
cheat git               more examples
```

---

## SSH & GitHub

```
ssh-keygen -t ed25519 -C 'you@email.com'   generate a key (do once)
cat ~/.ssh/id_ed25519.pub                  copy this → paste into GitHub Settings
ssh -T git@github.com                      test GitHub SSH connection
ssh user@host                              connect to a server
ssh-copy-id user@host                      copy key to server (no more passwords)
```

---

## Packages (Arch)

```
update                      update everything (pacman -Syu)
install <name>              install a package
search <name>               search for a package
sudo pacman -R <name>       remove a package
pacman -Qi <name>           info about an installed package
yay -S <name>               install from AUR (if yay installed)
```

---

## Security

```
pass init <email>      set up password manager (once)
pass add github        store a password
pass github            retrieve a password
pass ls                list all stored passwords
```

---

## Keyboard Shortcuts

```
Ctrl+R      search history
Ctrl+C      cancel current command
Ctrl+Z      suspend command  (fg to resume)
Ctrl+L      clear screen
Ctrl+A      jump to start of line
Ctrl+E      jump to end of line
Ctrl+W      delete last word
Ctrl+U      delete entire line
Tab         autocomplete
↑ / ↓       scroll history
```

---

## This Kit's Commands

```
helpme               full help index
helpme files         file navigation
helpme git           git basics
helpme ssh           SSH keys and GitHub
helpme network       networking
helpme daily         email, music, news, calendar
helpme packages      installing software
helpme why           the philosophy behind this

tips / tip           random bash tip
cheat <cmd>          real-world command examples
sysinfo              system overview
customize            change colors, prompt, editor, shortcuts

please               re-run last command with sudo
reload               reload ~/.bashrc
bashrc               edit ~/.bashrc
starshiprc           edit prompt config
```

---

## Pipe Tricks

```
ls -la | grep '.txt'         filter output
cat file.txt | wc -l         count lines in a file
history | tail -20           last 20 commands
command > file.txt           save output to file (overwrite)
command >> file.txt          append output to file
cmd1 && cmd2                 run cmd2 only if cmd1 succeeds
```
