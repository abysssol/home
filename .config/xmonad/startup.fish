#! /usr/bin/env fish

xrandr --output DP-0 --mode 2560x1440 --rate 165 --pos 1080x0 --primary \
    --output HDMI-0 --mode 1920x1080 --rate 60 --pos 0x0 --rotate right
xsetroot -cursor_name left_ptr

feh --no-fehbg --bg-max ~/Pictures/background

pkill unclutter
unclutter --timeout 5 --jitter 16 &

systemctl --user start status-watcher
pkill taffybar
taffybar &
