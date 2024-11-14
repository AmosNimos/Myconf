#!/bin/bash

monitor-option(){
	primary="$1"
	secondary="$2"
	choice=$(echo -e "Dual\nMono" | rofi -dmenu -i -p "Monitor options")
	if [ "$choice" == "Dual" ];then
		#External and internal
		xrandr --output $primary --mode 1920x1080 --primary --rotate normal
		xrandr --output $secondary --mode 1920x1080 --rotate normal --right-of $primary
		bspc monitor $primary -d 1 2 3 4 5
		bspc monitor $secondary -d 6 7 8 9 0
	elif [ "$choice" == "Mono" ];then
		#External only
		xrandr --output $secondary --off
		bspc monitor -d 1 2 3 4 5 6 7 8 9 0
	fi
}
