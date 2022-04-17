#!/bin/bash
# mac-tron
# version 0.2

usage()
{
cat << EOF

Manage $service service on a ultra.cc slot.

usage: $0 <options>
OPTIONS:
  -c    Check $service status
  -s    Start $service
  -a    Auto-recover $service when failed
  -h|?  Show this message

EOF
}

#set colors
RED="\e[91m"
GREEN="\e[92m"
BLUE="\e[94m"
ENDCOLOR="\e[0m"

#set service variables
#url to monitor eg. https://hostname/rutorrent
url=''
service='webservice'
up='ruTorrent Private Area'
down=''

#set pushover variables
#uses pushover.sh with an app name
pushoverapp=""

send_message () {
./pushover.sh -a $pushoverapp -m "$1" -t "$service autorecover"
}

get_status () {
status=$(curl -sS -o - -I $url | grep ruTorrent | awk -F'"' '{print $2}')
echo -e $status
}

service_start () {
status=$(get_status)
if [[ $status == $up ]]; then
  echo -e "${GREEN}UP: $service already running.${ENDCOLOR}"
  exit
elif [[ $status == $down ]]; then
  ~/scripts/servicemonitor/nginx.sh -s
  rm ~/$service.autorecover 2>/dev/null
  echo -e "${BLUE}ACTION: sent $service start command.${ENDCOLOR}"
else
  echo -e "${RED}?: $service status unknown.${ENDCOLOR}"
fi
service_status
}


service_status () {
status=$(get_status)
if [[ $status == $up ]]; then
  result="${GREEN}UP: $service.${ENDCOLOR}"
elif [[ $status == $down ]]; then
  result="${RED}DOWN: $service.${ENDCOLOR}"
else
  result="${RED}?: $service status unknown.${ENDCOLOR}"
fi
echo -e $result
}

service_autorecover () {
status=$(get_status)
if [[ $status == $down ]] && [[ ! -f ~/$service.autorecover ]]; then
  echo -e "${BLUE}AUTORECOVER: attempting to restart $service.${ENDCOLOR}"
  service_start >/dev/null 2>/dev/null
  touch ~/$service.autorecover
  service_status
  if [[ $status == $up ]]; then
  echo -e "${GREEN}AUTORECOVER: $service restarted.${ENDCOLOR}"
  send_message "AUTORECOVER: $service restarted."
  rm ~/$service.autorecover 2>/dev/null
  fi
elif [[ $status == $up ]]; then
  echo -e "${GREEN}UP: $service checked.${ENDCOLOR}"
elif [[ -f ~/$service.autorecover ]]; then
  echo -e "${RED}AUTORECOVER of $service failed.${ENDCOLOR}"
  send_message "AUTORECOVER: $service failed."
fi
}


if [ $# -eq 0 ];
then
    usage
    exit 0
fi

while getopts 'ckash?' options
do
  case $options in
    c) service_status ;;
    s) service_start ;;
    a) service_autorecover ;;
    h|?) usage ;;
  esac
done
