#!/bin/sh

# Image viewer
VIEWER=imv

# Folder to save screenshots in
FOLDER="$HOME/screenshot"

# Current date and time, used for filenames
DATE=$(date +"%Y-%m-%dT%H-%M-%S.%N")

# Clipboard manager
CLIP=wl-copy

# Notification settings
# Enable notifications
NOTIFY=1
CATEGORY="screenshot"
# Notification timeout in ms
NOTIFY_TIMEOUT=10000

# Name of saved file, overwritten in window screenshot
OUTPUT="$FOLDER/$DATE.png"

send_notify() {
    MSG=$1
    if [ ! -z "$NOTIFY" ]; then
        notify-send -t $NOTIFY_TIMEOUT -c $CATEGORY "scsh.sh" "$MSG"
    fi
}

if [ ! -d $FOLDER ] 
then
    mkdir $FOLDER
fi

while getopts "n" opt; do
    case $opt in
        n)
            NOTIFY=
            ;;
        \?)
            echo "Invalid option: -$OPTARG" >&2
            exit 1
            ;;
        :)
            echo "Option -$OPTARG requires an argument." >&2
            exit 1
            ;;
    esac
done

shift `expr $OPTIND - 1`

case $1 in
	all)
		grim $OUTPUT
        send_notify "Screenshot All\n$OUTPUT"
		;;
	area)
		grim -g "$(slurp)" $OUTPUT
        send_notify "Screenshot Area\n$OUTPUT"
		;;
	window)
        NAME=$(swaymsg -t get_tree | jq -r '.. | select(.focused?) | .name')
        WINDOW=$(swaymsg -t get_tree | jq -r '.. | select(.focused?) | .rect | "\(.x),\(.y) \(.width)x\(.height)"')
        OUTPUT="$FOLDER/$DATE-$NAME.png"
		grim -g "$WINDOW" $OUTPUT
        send_notify "Screenshot Window $NAME\n$OUTPUT"
		;;
    last)
        LAST=$(ls -t $FOLDER | head -n1)
        $VIEWER "$FOLDER/$LAST"
        send_notify "Opening image\n$FOLDER/$LAST"
        ;;      
    clip-last)
        LAST=$(ls -t $FOLDER | head -n1)
        cat "$FOLDER/$LAST" | $CLIP
        send_notify "Copied last image to clipboard\n$FOLDER/$LAST"
        ;;
    clip-area)
        grim -g "$(slurp)" - | $CLIP
        send_notify "Screenshot area to clipboard\n"
        ;;
    last-file)
        LAST=$(ls -t $FOLDER | head -n1)
        $CLIP "$FOLDER/$LAST"
        send_notify "Copied name of last screenshot to clipboard\n$FOLDER/$LAST"
        ;;
	*)
		echo "Unrecognized command: $1"
esac

