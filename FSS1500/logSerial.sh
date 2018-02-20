#!/bin/bash

# script -a -t 0 keylog.csv screen /dev/tty.usbmodem1421 115200

if test "$#" -ne 3; then
    echo "USAGE: ./$0 [PORT] [BAUD] [OUTPUT FILE]"
fi

script -t 0 $3 screen $1 $2


