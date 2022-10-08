#! /usr/bin/env fish

xsetroot -cursor_name left_ptr
feh --no-fehbg --bg-max ~/Pictures/xmonad-bg
pkill unclutter
unclutter --timeout 3 --jitter 36 &

systemctl --user start status-watcher
pkill taffybar
taffybar &

sleep 3
systemctl --user restart nm-applet
