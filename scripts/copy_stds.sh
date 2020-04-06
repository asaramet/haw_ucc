#!/usr/bin/env bash

MD=`dirname $(readlink -f $0)`
appFolder="${MD}/../bwUniCluster1/src/app"

declare -i year=2017
[[ ! -z ${1} ]] && declare -i year=${1}

generate () {
  copy_unis_components
  copy_helpers
  python3 ${MD}/create_app_components.py -y `date +%Y`
}

copy_unis_components () {
  [[ ! -d ${appFolder}/unis ]] && cp -rf ${MD}/std_files/unis ${appFolder}
  [[ ! -f ${appFolder}/unis/unis.component.html ]] ||
  [[ ! -f ${appFolder}/unis/unis.component.ts ]] ||
  [[ ! -f ${appFolder}/unis/unis.module.ts ]] &&
  cp -f ${MD}/std_files/unis/* ${appFolder}/unis/
}

copy_helpers () {
  [[ ! -d ${appFolder}/_helpers ]] && cp -rf ${MD}/std_files/_helpers ${appFolder}
  [[ ! -f ${appFolder}/_helpers/add_data.ts ]] ||
  [[ ! -f ${appFolder}/_helpers/material.module.ts ]] ||
  [[ ! -f ${appFolder}/_helpers/uni_prefixes.ts ]] ||
  [[ ! -f ${appFolder}/_helpers/users.methods.ts ]] &&
  cp -f ${MD}/std_files/_helpers/* ${appFolder}/_helpers/
}

help_menu () {
  cat << EOF
  Usage: ${0}

  YEAR               Year to process

  OPTIONS:
    -h | --help         Show this message

  EXAMPLES:
    Copy standard files in ${appFolder}
        $ ${0}

EOF
}

case "${1}" in
  -h | --help)
    help_menu
  ;;
  *)
    generate
  ;;
esac
