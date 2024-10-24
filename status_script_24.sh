#!/bin/sh
# shell script to prepend i3status with more stuff

cl0=/sys/class/hwmon/hwmon
cl1=/temp3_label
thc=/tmp/hwmon_cpu
tsp=/tmp/i3statusP
if ! [ -e $thc ]; then
  for i in {0..3}; do
    if [ -e $cl0$i$cl1 ]; then
      if [ "$(cat $cl0$i$cl1)" = Tccd1 ]; then
        ln -s $cl0$i $thc
        break
      fi
    fi
  done
fi
if ! [ -p $tsp ]; then
  mkfifo $tsp
fi
i3status --config ~/.config/i3/i3status > $tsp &
cpref="[{\"name\":\"keyboard layout\",\"markup\":\"none\",\"full_text\":\""

getlo(){
  lo=$(xkblayout-state print %s/%v)
  lol=${#lo}-1
  if [ ${lo:$lol} = / ]; then
    lo=${lo:0:$lol}
  fi
#  soviet boost:
  if [ "$lo" = ru ]; then
    lo="CCCP"
  fi
#  boosted!
}

setrm(){
  tf="$(sed -n 's/^.*ram: \([.0-9]*\).*$/\1/p' <<<$postf)"
  rl=$((7-${#tf}))
  ijs="    "
  ijs="${ijs:0:rl}"
  postf="$(sed "s/ram:/${ijs}ram:/" <<<$postf)"
}

(while :; do
  read line
  if [ "$line" = "" ]; then
    break
  elif [ "$line" = U ]; then
    getlo
    echo $pref$cpref$lo"\"},""$postf"
  else
    poc=${line:0:2}
    if [ "$poc" = "[{" ]; then
      pref=""
      postf="${line:1}"
      getlo
      setrm
      echo $pref$cpref$lo"\"},""$postf"
    elif [ "$poc" = ",[" ]; then
      pref=","
      postf="${line:2}"
      getlo
      setrm
      echo $pref$cpref$lo"\"},""$postf"
    else
      echo $line
    fi
  fi
done) < /tmp/i3statusP
