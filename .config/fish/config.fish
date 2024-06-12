set -gx EDITOR hx
set -gx VISUAL $EDITOR
set -gx LESS -FRX
set -gx MANPAGER "sh -c 'col -bx | bat -p -l man'"
set -gx MANROFFOPT -c

alias nix-shell "nix-shell --run fish"
alias clippy-all "cargo clippy -- -D clippy::all -W clippy::pedantic -W clippy::nursery"
alias dl-music "yt-dlp --no-playlist --embed-metadata -x --audio-format flac -P ~/Downloads/music"

alias ls "eza --group-directories-first"
alias ll "eza -lF --group-directories-first"
alias la "eza -laF --group-directories-first"
alias cl clear

function fork
    $argv &>/dev/null &
    disown
end

function into
    fork $argv
    exit
end

function term
    fork alacritty -e fish -c "$argv"
end

if test -d $HOME/.emacs.d/bin
    set -gxp PATH "$HOME/.emacs.d/bin/"
end

if test -d $HOME/.cargo/bin
    set -gxp PATH "$HOME/.cargo/bin"
end

set -U fish_greeting
starship init fish | source
zoxide init fish | source
jj util completion fish | source
