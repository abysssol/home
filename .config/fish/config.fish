alias ls "exa --group-directories-first"
alias ll "ls -lF"
alias la "ll -a"
alias cl "clear"
alias term "alacritty -e sh -c $argv"

alias git-config "git --git-dir=$HOME/.home-config --work-tree=$HOME"
alias git-config-sys "sudo git --git-dir=/sys-config --work-tree=/"

alias clippy-all "cargo clippy -- -D clippy::all -W clippy::pedantic -W clippy::nursery"

if test -d $HOME/.cargo/bin/
    set -xp PATH "$HOME/.cargo/bin"
end

alias fish_greeting "neofetch"
starship init fish | source
