alias ls "exa --group-directories-first"
alias ll "ls -lF"
alias la "ll -a"
alias cl "clear"
alias em "emacsclient -c -a ''"
alias clippy-all "cargo clippy -- -D clippy::all -W clippy::pedantic -W clippy::nursery"


function fork
    $argv &>/dev/null & disown
end

function term
    fork alacritty -e fish -c "$argv"
end


if test -d $HOME/.cargo/bin/
    set -xp PATH "$HOME/.cargo/bin/"
end

if test -d $HOME/.emacs.d/bin/
    set -xp PATH "$HOME/.emacs.d/bin/"
end


alias fish_greeting "neofetch"
starship init fish | source
