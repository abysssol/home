alias exa "exa --group-directories-first"
alias ll "exa -lF"
alias la "ll -a"
alias cl "clear"

alias git-config "git --git-dir=$HOME/.home-config --work-tree=$HOME"

alias clippy-all "cargo clippy -- -D clippy::all -W clippy::pedantic -W clippy::nursery"
alias clippy-res "cargo clippy -- -W clippy::restriction"
alias clippy-car "cargo clippy -- -W clippy::cargo"

if test -d $HOME/.cargo/bin/
        set -xp PATH "$HOME/.cargo/bin"
end

function fish_greeting
    neofetch
end

starship init fish | source
