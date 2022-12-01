#! /usr/bin/env fish

xrandr --output DP-0 --mode 2560x1440 --rate 165 --pos 1920x1080
xsetroot -cursor_name left_ptr

feh --no-fehbg --bg-max ~/.config/xmonad/background

pkill unclutter
unclutter --timeout 5 --jitter 16 &

systemctl --user start status-watcher
pkill taffybar
taffybar &
