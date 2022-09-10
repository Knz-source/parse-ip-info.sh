#!/bin/env bash

input=$1

tempdirname="tempsplit"
temppartprefix="$tempdirname/part"

if [ -z $input ];
then
  echo "No arguments passed"
fi

fetch_ips_info() {
  readarray -t basearray < $1

  prefixArray=(${basearray[@]/#/\"})
  suffixArray=${prefixArray[@]/%/\",}

  requestData="[${suffixArray[@]%?}]"

  curl http://ip-api.com/batch?fields=isp,country,org,as,query,regionName,city \
    --data "${requestData}"
}

clean_tempdir() {
  if [ -d $tempdirname ] 
  then 
    rm -rf $tempdirname
  fi
}

make_tempdir() {
  mkdir $tempdirname
}

split_file() {
  split -l 100 $1 $temppartprefix
}

clean_tempdir

make_tempdir

split_file $input

for part in $temppartprefix*
do
  fetch_ips_info $part
done
