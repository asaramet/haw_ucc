#!/usr/bin/env bash

MD=`dirname $(readlink -f $0)`
possible_prefixes='aa as es hf hk hn hr hs ht hu ro'
scriptsFolder="${MD}/../../bwUniCluster1/scripts"

build () {
  [[ ! -d src ]] && npm run make:new
  [[ ! -d node_modules ]] && npm install && npm audit fix
}

create () {
  prefix=${1}
  year=${2}

  declare -i currentYear=`date +%Y`
  currentMonth=`date +%m`
  currentMonth="${currentMonth#'0'}" # remove '0' prefix

  [[ ${currentYear} -gt "2020" ]] && declare -i currentYear="2020"
  [[ ${currentYear} -eq "2020" ]] && declare -i currentMonth="3"
  [[ -z ${prefix} ]] && echo "No uni prefix specified" && exit 0
  echo "Creating components for ${prefix}, ${year}..."
  ${scriptsFolder}/create_users_components.sh -c ${prefix} ${year} &&
  ${scriptsFolder}/create_users_components.sh -m ${prefix} ${year}

  [[ ${year} -eq 2017 ]] && ${MD}/users_components.py -y 2017 -m 12 -u ${prefix} -s 5
  [[ ${year} -gt 2017 ]] && [[ ${year} -lt ${currentYear} ]] &&
  ${MD}/users_components.py -y ${year} -m 12 -u ${prefix}
  [[ ${year} -eq ${currentYear} ]] &&
  ${MD}/users_components.py -y ${currentYear} -m ${currentMonth} -u ${prefix}
}

help_menu () {
  cat << EOF
  Usage ${0} [OPTIONS] [UNI PREFIX] [YEAR]

  OPTIONS:
    -h | --help       Show this message
    -b | --build      Build new case

  EXAMPLES:
    Create components for es, 2018:
      $ ${0} es 2018

    Create components for aa from 2017 up to $(date +%Y):
      $ ${0} all aa

    Build a new fresh case:
      $ ${0} -b

EOF
}

case ${1} in
  -h | --help)
    help_menu
  ;;
  -b | --build)
    build
  ;;
  all)
    for prefix in ${possible_prefixes}; do
      if [[ ${2} == ${prefix} ]]; then
        startYear=2017
        while [[ ${startYear} -le `date +%Y` ]]; do
          create ${prefix} ${startYear}
          startYear=$(( ${startYear} + 1 ))
        done
      fi
    done
  ;;
  *)
    for prefix in ${possible_prefixes}; do
      [[ ${1} == ${prefix} ]] && [[ ${2} -ge 2017 ]] &&
      npm run clean &&
      create ${prefix} ${2} && exit 1
    done
    echo "Wrong option. For more info try ${0} --help"
  ;;
esac
