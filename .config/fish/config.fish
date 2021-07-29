alias exa "exa --group-directories-first"
alias ll "exa -lF"
alias la "ll -a"
alias cl "clear"

alias git-config "git --git-dir=$HOME/.home-config --work-tree=$HOME"
alias git-config-sys "sudo git --git-dir=/sys-config --work-tree=/"

alias clippy-all "cargo clippy -- -D clippy::all -W clippy::pedantic -W clippy::nursery"

if test -d $HOME/.cargo/bin/
    set -xp PATH "$HOME/.cargo/bin"
end

function fish_greeting
    neofetch
end

starship init fish | source
