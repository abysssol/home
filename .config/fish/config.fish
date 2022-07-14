set -Ux VISUAL "emacsclient -c -a ''"
set -Ux EDITOR "emacsclient -c -a ''"
set -Ux MANPAGER "sh -c 'col -bx | bat -pl man'"

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

if test -d $HOME/.cargo/bin
    set -xa PATH "$HOME/.cargo/bin"
end

if test -d $HOME/.emacs.d/bin
    set -xa PATH "$HOME/.emacs.d/bin/"
end

set -U fish_greeting
starship init fish | source
