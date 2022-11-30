#! /usr/bin/env fish

xsetroot -cursor_name left_ptr

feh --no-fehbg --bg-max ~/.config/xmonad/background

pkill unclutter
unclutter --timeout 5 --jitter 16 &

systemctl --user start status-watcher
pkill taffybar
taffybar &
