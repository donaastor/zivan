#!/bin/sh

[[ -f ~/.Xresources ]] && xrdb -merge -I$HOME ~/.Xresources
if [ -d /etc/X11/xinit/xinitrc.d ] ; then
 for f in /etc/X11/xinit/xinitrc.d/?*.sh ; do
  [ -x "$f" ] && . "$f"
 done
 unset f
fi
xset s noblank
xset s noexpose
xset s 0 0
xset +dpms
xset dpms 0 180 0
xset r rate 200 30
numlockx &
xbindkeys &
(sleep 1.5 && /opt/kbswtb) &
if ! pgrep -f xidlehook; then
  xidlehook --timer 600 'systemctl suspend -i' '' &
fi
picom &
export QT_SCREEN_SCALE_FACTORS=1.5
nitrogen --restore &
exec i3
