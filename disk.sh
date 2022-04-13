#!/bin/bash
# mac-tron
# version 0.1

usage()
{
cat << EOF

Get capacity information on a ultra.cc slot.

usage: $0 <options>
OPTIONS:
  -c    Output total capacity (Gb)
  -a    Output available capacity (Gb)
  -p    Output available percent (%)
  -d    Output all disk data to screen
  -h|?  Show this message

EOF
}


function get_capacity () {
local capacity=$(printf %s\\n $(/usr/bin/quota -s | /bin/grep dev | /usr/bin/awk '{printf $3-0}'))
echo $capacity
}

function get_available () {
available=$(printf %s\\n $(/usr/bin/quota -s | /bin/grep dev | /usr/bin/awk '{printf ($3-$2)}'))
echo $available
}

function get_percent () {
percent=$(awk -v available=$(get_available) -v capacity=$(get_capacity) 'BEGIN {printf "%5.2f\n",available/capacity*100}')
echo $percent
}

function get_diskdata () {
echo "Capacity=$(get_capacity)G"
echo "Available=$(get_available)G"
echo "Percent=$(get_percent)%"
}

if [ $# -eq 0 ];
then
    usage
    exit 0
fi

while getopts 'capdh?' options
do
  case $options in
    c) get_capacity ;;
    a) get_available ;;
    p) get_percent ;;
    d) get_diskdata ;;
    h|?) usage ;;
  esac
done
