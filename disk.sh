#!/bin/bash
# mac-tron
# version 0.3

usage()
{
cat << EOF

Get capacity information on a ultra.cc slot.

usage: $0 <options>
OPTIONS:
  -t    Output total capacity (Gb)
  -c    Output consumed capacity (Gb)
  -r    Output remaining capacity (Gb)
  -p    Output remaining percent (%)
  -u    Output consumed percent (%)
  -d    Output all disk stats to screen
  -h|?  Show this message

EOF
}

#read in data values
data=$(printf %s\\n $(/usr/bin/quota -s | /bin/grep dev))

function get_totalcapacity () {
totalcapacity=$(echo $data | /usr/bin/awk '{printf $3-0}')
echo $totalcapacity
}

function get_consumedcapacity () {
consumedcapacity=$(echo $data | /usr/bin/awk '{printf ($2-0)}')
echo $consumedcapacity
}

function get_remainingcapacity () {
remainingcapacity=$(echo $data | /usr/bin/awk '{printf ($3-$2)}')
echo $remainingcapacity
}

function get_remainingpercent () {
remainingpercent=$(awk -v remainingcapacity=$(get_remainingcapacity) -v totalcapacity=$(get_totalcapacity) 'BEGIN {printf "%5.2f\n",remainingcapacity/totalcapacity*100}')
echo $remainingpercent
}

function get_consumedpercent () {
consumedpercent=$(awk -v remainingcapacity=$(get_remainingcapacity) -v totalcapacity=$(get_totalcapacity) 'BEGIN {printf "%5.2f\n",100-remainingcapacity/totalcapacity*100}')
echo $consumedpercent
}


function get_diskdata () {
echo "Gb Capacity  =$(get_totalcapacity)G"
echo "Gb Consumed  =$(get_consumedcapacity)G"
echo "Gb Remaining =$(get_remainingcapacity)G"
echo
echo "%  Consumed  =$(get_consumedpercent)%"
echo "%  Remaining =$(get_remainingpercent)%"
}

if [ $# -eq 0 ];
then
    usage
    exit 0
fi

while getopts 'tcrpudh?' options
do
  case $options in
    t) get_totalcapacity ;;
    c) get_consumedcapacity ;;
    r) get_remainingcapacity ;;
    p) get_remainingpercent ;;
    u) get_consumedpercent ;;
    d) get_diskdata ;;
    h|?) usage ;;
  esac
done
