#! /usr/bin/env fish

pkill taffybar
taffybar &
xsetroot -cursor_name left_ptr
feh --no-fehbg --bg-max ~/Pictures/xmonad-bg

sleep 1 &
wait $last_pid
systemctl --user restart nm-applet
