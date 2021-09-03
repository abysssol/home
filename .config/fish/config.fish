alias ls "exa --group-directories-first"
alias ll "ls -lF"
alias la "ll -a"
alias cl "clear"

alias git-config "git --git-dir=$HOME/.home.git --work-tree=$HOME"
alias sudo-git-config "sudo git --git-dir=/.system.git --work-tree=/"

alias clippy-all "cargo clippy -- -D clippy::all -W clippy::pedantic -W clippy::nursery"

function term
    alacritty -e fish -c "$argv" & disown
end

if test -d $HOME/.cargo/bin/
    set -xp PATH "$HOME/.cargo/bin"
end

alias fish_greeting "neofetch"
starship init fish | source
