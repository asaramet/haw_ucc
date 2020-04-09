#!/usr/bin/env bash

declare -i year=2017
[[ ! -z ${1} ]] && declare -i year=${1}

declare -i fromMonth=1
[[ ! -z ${2} ]] && declare -i fromMonth=${2}
[[ ! -z ${3} ]] && declare -i upToMonth=${3}

MD=`dirname $(readlink -f $0)`
appFolder="${MD}/../src/app/${year}"
dataFolder="${MD}/ngData/${year}"

generate () {
  start_month=${1}
  end_month=${2}
  python3 ${MD}/update_modules.py -y ${year} -s ${start_month} -e ${end_month} &&
  echo "--- created yearly components for ${year} in ${dataFolder}..."
}

check_options () {
  runFunction=${1}
  if [[ ${fromMonth} -ge 1 && ${fromMonth} -le 12 ]]; then
    if [[ -z ${upToMonth} ]]; then
      ${runFunction} ${fromMonth} 12
    else
      if [[ ${upToMonth} -ge 13 ]]; then
          echo "There are 12 months in a year!"
          break
      else
        ${runFunction} ${fromMonth} ${upToMonth}
      fi
    fi
  else
    echo "Wrong specified month, for more info try: ${0} --help"
  fi
}

help_menu () {
  cat << EOF
  Usage: ${0} OPTIONS [YEAR] [MONTH]

  OPTIONS:
    -h | --help         Show this message

    YEAR                Year to genetrate data for
    MONTH               Up to which month to generate data for starting with 1

  EXAMPLES:
    Create data for 2019, from Jan to May
        $ ${0} 2019 1 5
EOF
}

case "${1}" in
  -h | --help)
    help_menu
  ;;
  *)
    check_options generate
  ;;
esac
