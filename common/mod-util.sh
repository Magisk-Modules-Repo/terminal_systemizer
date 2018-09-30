##########################################################################################
#
# Terminal Utility Functions
# by veez21
#
##########################################################################################

MODUTILVER=v2
MODUTILVCODE=2

#=========================== Determine if A/B OTA device
if [ -d /system_root ]; then
  isABDevice=true
  SYSTEM=/system_root/system
  SYSTEM2=/system
else
  isABDevice=false
  SYSTEM=/system
  SYSTEM2=/system
fi

#=========================== Set Busybox (Used by Magisk) up
set_busybox() {
  if [ -x "$1" ]; then
    for i in $(${1} --list); do
      if [ "$i" != 'echo' ]; then
        alias "$i"="${1} $i" 2>>$LOG >>$LOG
      fi
    done
    _busybox=true
    _bb=$1
  fi
}
_busybox=false
if [ -d /sbin/.core/busybox ]; then
  PATH=$PATH:/sbin/.core/busybox
  _bb=/sbin/.core/busybox/busybox
  _busybox=true
elif [ ! -x $SYSTEM/xbin/busybox ]; then
  set_busybox /data/magisk/busybox
  set_busybox /data/adb/magisk/busybox
else
  alias busybox=""
fi
if [ -x $SYSTEM/xbin/busybox ]; then
  _bb=$SYSTEM/xbin/busybox
elif [ -x $SYSTEM/bin/busybox ]; then
  _bb=$SYSTEM/bin/busybox
elif [ $_busybox ]; then
  true
else
  echo "! Busybox not detected.."
  echo "Please install one (@osm0sis' busybox recommended)"
  false
fi
[ $? -ne 0 ] && exit $?
alias echo='echo -e'
[ -n "$LOGNAME" ] && alias clear='echo'
_bbname=$(busybox | head -n1)
_bbname=${_bbname%'('*}
BBok=true
if [ "$_bbname" == "" ]; then
  _bbname="BusyBox not found!"
  BBok=false
fi

#=========================== Default Functions and Variables

# Import util_functions.sh
[ -f /data/adb/magisk/util_functions.sh ] && . /data/adb/magisk/util_functions.sh || exit 1

# Device Info
# BRAND MODEL DEVICE API ABI ABI2 ABILONG ARCH
BRAND=$(getprop ro.product.brand)
MODEL=$(getprop ro.product.model)
DEVICE=$(getprop ro.product.device)
ROM=$(getprop ro.build.display.id)
api_level_arch_detect

# Version Number
VER=$(grep_prop version $MODDIR/module.prop)
# Version Code
REL=$(grep_prop versionCode $MODDIR/module.prop)
# Author
AUTHOR=$(grep_prop author $MODDIR/module.prop)
# Mod Name/Title
MODTITLE=$(grep_prop name $MODDIR/module.prop)

# Colors
G='\e[01;32m'		# GREEN TEXT
R='\e[01;31m'		# RED TEXT
Y='\e[01;33m'		# YELLOW TEXT
B='\e[01;34m'		# BLUE TEXT
V='\e[01;35m'		# VIOLET TEXT
Bl='\e[01;30m'		# BLACK TEXT
C='\e[01;36m'		# CYAN TEXT
W='\e[01;37m'		# WHITE TEXT
BGBL='\e[1;30;47m'	# Background W Text Bl
N='\e[0m'			# How to use (example): echo "${G}example${N}"
loadBar=' '			# Load UI
# Remove color codes if -nc or in ADB Shell
[ -n "$1" -a "$1" == "-nc" ] && shift && NC=true
[ "$NC" -o -n "$LOGNAME" ] && {
  G=''; R=''; Y=''; B=''; V=''; Bl=''; C=''; W=''; N=''; BGBL=''; loadBar='=';
}

# Divider (based on $MODTITLE, $VER, and $REL characters)
character_no=$(echo "$MODTITLE $VER $REL" | tr " " '_' | wc -c)
div="${Bl}$(printf '%*s' "${character_no}" '' | tr " " "=")${N}"

# Title Div
title_div() {
  no=$(echo "$@" | wc -c)
  extdiv=$((no-character_no))
  echo "${W}$@${N} ${Bl}$(printf '%*s' "$extdiv" '' | tr " " "=")${N}"
}

# set_file_prop <property> <value> <prop.file>
set_file_prop() {
  if [ -f "$3" ]; then
    if grep "$1=" "$3"; then
      sed -i "s/${1}=.*/${1}=${2}/g" "$3"
    else
      echo "$1=$2" >> "$3"
    fi
  else
    echo "$3 doesn't exist!"
  fi
}

# https://github.com/fearside/ProgressBar
ProgressBar() {
# Process data
  _progress=$(((${1}*100/${2}*100)/100))
  _done=$(((${_progress}*4)/10))
  _left=$((40-$_done))
# Build progressbar string lengths
  _done=$(printf "%${_done}s")
  _left=$(printf "%${_left}s")

# 1.2 Build progressbar strings and print the ProgressBar line
# 1.2.1 Output example:
# 1.2.1.1 Progress : [########################################] 100%
printf "\rProgress : ${BGBL}|${N}${_done// /${BGBL}$loadBar${N}}${_left// / }${BGBL}|${N} ${_progress}%%"
}

#https://github.com/fearside/SimpleProgressSpinner
Spinner() {

# Choose which character to show.
case ${_indicator} in
  "|") _indicator="/";;
  "/") _indicator="-";;
  "-") _indicator="\\";;
  "\\") _indicator="|";;
  # Initiate spinner character
  *) _indicator="\\";;
esac

# Print simple progress spinner
printf "\r${@} [${_indicator}]"
}

# "cmd & spinner [message]"
e_spinner() {
  PID=$!
  h=0; anim='-\|/';
  while [ -d /proc/$PID ]; do
    h=$(((h+1)%4))
    sleep 0.02
    printf "\r${@} [${anim:$h:1}]"
  done
}

# test_connection
test_connection() {
  echo -n "Testing internet connection "
  ping -q -c 1 -W 1 google.com >/dev/null 2>/dev/null && echo "- OK" || { echo "Error"; false; }
}

# Log files will be uploaded to termbin.com
upload_logs() {
  $BBok && {
    test_connection
    [ $? -ne 0 ] && exit
    verUp=none; oldverUp=none; logUp=none; oldlogUp=none;
    echo "Uploading logs"
    [ -s $VERLOG ] && verUp=$(cat $VERLOG | nc termbin.com 9999)
    [ -s $oldVERLOG ] && oldverUp=$(cat $oldVERLOG | nc termbin.com 9999)
    [ -s $LOG ] && logUp=$(cat $LOG | nc termbin.com 9999)
    [ -s $oldLOG ] && oldlogUp=$(cat $oldLOG | nc termbin.com 9999)
    echo -n "Link: "
    echo "$MODEL ($DEVICE) API $API\n$ROM\n$ID\n
    O_Verbose: $oldverUp
    Verbose:   $verUp

    O_Log: $oldlogUp
    Log:   $logUp" | nc termbin.com 9999
  } || echo "Busybox not found!"
  exit
}

# Heading
mod_head() {
  clear
  echo "$div"
  echo "${W}$MODTITLE $VER${N}(${Bl}$REL${N})"
  echo "by ${W}$AUTHOR${N}"
  echo "$div"
  echo "${W}$_bbname${N}"
  echo "${Bl}$_bb${N}"
  echo "$div"
  [ -s $LOG ] && echo "Enter ${W}logs${N} to upload logs" && echo $div
}
