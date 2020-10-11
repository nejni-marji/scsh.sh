#!/bin/sh

VIEWER=imv

FOLDER="$HOME/screenshot"
DATE=$(date +"%Y-%m-%dT%H-%M-%S.%N")

CLIP=wl-copy

NOTIFY=1
CATEGORY="screenshot"
NOTIFY_TIMEOUT=10000

OUTPUT="$FOLDER/$DATE.png"

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
        if [ ! -z "$NOTIFY" ]; then
            notify-send -t $NOTIFY_TIMEOUT -c $CATEGORY "scsh.sh" "Screenshot All\n$OUTPUT"
        fi
		;;
	area)
		grim -g "$(slurp)" $OUTPUT
        if [ ! -z "$NOTIFY" ]; then
            notify-send -t $NOTIFY_TIMEOUT -c $CATEGORY "scsh.sh" "Screenshot Area\n$OUTPUT"
        fi
		;;
	window)
        NAME=$(swaymsg -t get_tree | jq -r '.. | select(.focused?) | .name')
        WINDOW=$(swaymsg -t get_tree | jq -r '.. | select(.focused?) | .rect | "\(.x),\(.y) \(.width)x\(.height)"')
        OUTPUT="$FOLDER/$DATE-$NAME.png"
		grim -g "$WINDOW" $OUTPUT
        if [ ! -z "$NOTIFY" ]; then
            notify-send -t $NOTIFY_TIMEOUT -c $CATEGORY "scsh.sh" "Screenshot Window $NAME\n$OUTPUT"
        fi
		;;
    last)
        LAST=$(ls -t $FOLDER | head -n1)
        $VIEWER "$FOLDER/$LAST"
        if [ ! -z "$NOTIFY" ]; then
            notify-send -t $NOTIFY_TIMEOUT -c $CATEGORY "scsh.sh" "Opening image\n$FOLDER/$LAST"
        fi
        ;;      
    clip-last)
        LAST=$(ls -t $FOLDER | head -n1)
        cat "$FOLDER/$LAST" | $CLIP
        if [ ! -z "$NOTIFY" ]; then
            notify-send -t $NOTIFY_TIMEOUT -c $CATEGORY "scsh.sh" "Copied last image to clipboard\n$FOLDER/$LAST"
        fi
        ;;
    clip-area)
        grim -g "$(slurp)" - | $CLIP
        if [ ! -z "$NOTIFY" ]; then
            notify-send -t $NOTIFY_TIMEOUT -c $CATEGORY "scsh.sh" "Screenshot area to clipboard\n"
        fi
        ;;
    last-file)
        LAST=$(ls -t $FOLDER | head -n1)
        $CLIP "$FOLDER/$LAST"
        if [ ! -z "$NOTIFY" ]; then
            notify-send -t $NOTIFY_TIMEOUT -c $CATEGORY "scsh.sh" "Copied name of last screenshot to clipboard\n$FOLDER/$LAST"
        fi
        ;;
	*)
		echo "Unrecognized command: $1"
esac

