#!/bin/sh

# socom: damn simple serial communication

if [ $# -lt 1 ] || [ $# -gt 2 ]; then
    echo "usage: $(basename $0) tty [baudrate]" 1>&2
    exit 1
fi

PORTOPS=''
if [ $# -eq 2 ]; then
    PORTOPS="${PORTOPS},b$2"
fi

cleanup() {
    stty "${SAVE}"
    echo 1>&2
}

echo "quit: ^]" 1>&2

# is stdin a terminal?
if [ -t 0 ]; then
    SAVE="$(stty -g)"
    trap cleanup EXIT
    # use stty directly instead of using socat options
    # because socat tries to ioctl stdout
    stty raw -echo opost ixon isig intr ^\] icrnl
fi

# is port a terminal?
exec 3< "$1"
if [ -t 3 ]; then
    PORTOPS="${PORTOPS},raw,iexten=0,echo=0,echok=0,echoctl=0,echoke=0,min=0"
fi
exec 3>&-

socat stdio open:"$1${PORTOPS}"
