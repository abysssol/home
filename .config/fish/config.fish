alias nix-shell "nix-shell --run fish"
alias clippy-all "cargo clippy -- -D clippy::all -W clippy::pedantic -W clippy::nursery"
alias dl-music "yt-dlp --no-playlist --embed-metadata -x --audio-format flac"

alias ls "exa --group-directories-first"
alias ll "ls -lF"
alias la "ll -a"
alias cl "clear"

function fork
    $argv &>/dev/null &
    disown
end

function term
    fork alacritty -e fish -c "$argv"
end

if test -d $HOME/.local/share/cargo/bin
    set -xa PATH "$HOME/.local/share/cargo/bin"
end

if test -d $HOME/.emacs.d/bin
    set -xa PATH "$HOME/.emacs.d/bin/"
end

set -U fish_greeting
starship init fish | source
