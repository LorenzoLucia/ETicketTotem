#!/usr/bin/env bash

# Disable xset blanking
xset -dpms
xset s noblank
xset s off

# Disable cursor for touchscreen
unclutter -idle 1 -root &

# Let Chromium think it always exited cleanly.
#sed -i 's/"exited_cleanly":false/"exited_cleanly":true/' '~/.config/chromium/Default/Preferences'
#sed -i 's/"exit_type":"Crashed"/"exit_type":"Normal"/' '~/.config/chromium/Default/Preferences'

# Start Chromium.
chromium-browser --kiosk --noerrdialogs --disable-infobars 'http://172.20.10.6:8081'
