#!/bin/sh

# socom: damn simple serial communication

if [ $# -lt 1 ] || [ $# -gt 2 ]; then
    echo "usage: $(basename $0) tty [baudrate]" 1>&2
    exit 1
fi

BAUD=''
if [ $# -eq 2 ]; then
    BAUD=",b$2"
fi

cleanup() {
    stty "${SAVE}"
    echo 1>&2
}

echo "quit: ^]" 1>&2

# is stdin a terminal ?
if [ -t 0 ]; then
    SAVE="$(stty -g)"
    trap cleanup EXIT
    # use stty directly instead of using socat options
    # because socat tries to ioctl stdout
    stty raw -echo opost isig intr ^\]
fi

socat stdio open:"$1,raw${BAUD}"
