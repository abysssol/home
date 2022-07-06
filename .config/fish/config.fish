set -Ux XDG_CONFIG_HOME "$HOME/.config"
set -Ux XDG_CACHE_HOME "$HOME/.cache"
set -Ux XDG_DATA_HOME "$HOME/.local/share"
set -Ux XDG_STATE_HOME "$HOME/.local/state"
set -Ux XDG_BIN_HOME "$HOME/.local/bin"

set -Ux RUSTUP_HOME "$XDG_DATA_HOME/rustup"
set -Ux CARGO_HOME "$XDG_DATA_HOME/cargo"
set -Ux WINEPREFIX "$XDG_DATA_HOME/wine"
set -Ux GTK2_RC_FILES "$XDG_CONFIG_HOME/gtk-2.0/gtkrc"
set -Ux CUDA_CACHE_PATH "$XDG_CACHE_HOME/nv"

set -Ux VISUAL "emacsclient -c -a ''"
set -Ux EDITOR "emacsclient -c -a ''"
set -Ux MANPAGER "sh -c 'col -bx | bat -pl man'"
set -U fish_greeting

alias nvidia-settings "nvidia-settings --config=$HOME/.config/nvidia/settings"
alias nix-shell "nix-shell --run fish"
alias clippy-all "cargo clippy -- -D clippy::all -W clippy::pedantic -W clippy::nursery"
alias dl-music "yt-dlp --no-playlist --embed-metadata -x --audio-format flac"

alias ls "exa --group-directories-first"
alias ll "ls -lF"
alias la "ll -a"
alias cl "clear"
alias em "emacsclient -c -a ''"
alias tem "emacsclient -t -a ''"

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

starship init fish | source
