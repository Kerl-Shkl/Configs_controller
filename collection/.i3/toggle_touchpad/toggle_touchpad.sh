#!/bin/bash

TOUCHPAD=Elan\ Touchpad;
echo $TOUCHPAD
if xinput list-props "$TOUCHPAD" | grep "Device Enabled ([0-9][0-9][0-9]):.*1" > /dev/null 
then
    xinput disable "$TOUCHPAD"
    notify-send -u low  "Touchpad disabled"
else
    xinput enable "$TOUCHPAD"
    notify-send -u low  "Touchpad enabled"
fi
