#!/usr/bin/env bash

MD=`dirname $(readlink -f $0)`
MD="${MD}/.."
S_DIR=${MD}/scripts
A_DIR=${MD}/src/app
OUTPUT_DIR="/www/faculty/it/bwHPC/SCRIPTS/bwUniCluster1/output"

CURRENT_MONTH=`date +%m`
[[ ${CURRENT_MONTH:0:1} -eq 0 ]] && CURRENT_MONTH=${CURRENT_MONTH:1:2}
CURRENT_YEAR=`date +%Y`
[[ ${CURRENT_YEAR} -eq "2020" ]] && declare -i CURRENT_MONTH="3"

collect_data () {
  YEAR=${1}

  echo -e "\n === Collecting data for ${YEAR}..."
  [[ -f ${LOG_FILE} ]] && rm ${LOG_FILE} &&

  echo "-- Sync database --"
  ${S_DIR}/collect_data.sh -s ${YEAR} 2>&1 &&
  ${S_DIR}/collect_data.sh -c ${YEAR} 2>&1 &&
  echo "-- DONE --"
}

gather_data () {
  declare -i YEAR=${1}

  echo "-- Gather costs and users data for ${year} --"
  ${S_DIR}/gather_costs.sh ${YEAR} 2>&1 &&
  ${S_DIR}/gather_costs.sh -m 2>&1 &&
  echo "-- DONE --"

  echo "-- Gather users data in ts files --"
  ${S_DIR}/gather_users_data.sh -t ${YEAR} 2>&1 &&
  ${S_DIR}/gather_users_data.sh -m 2>&1 &&
  echo "-- DONE --"

  rm ${S_DIR}/ngData -rf
}

create_unis_components () {
  declare -i YEAR=${1}
  declare -i MONTH=${2}

  startMonth=1
  [[ ${YEAR} -eq 2017 ]] && startMonth=5
  ${S_DIR}/create_unis_components.sh ${YEAR} ${startMonth} ${MONTH} 2>&1 &&
  ${S_DIR}/create_unis_components.sh -m 2>&1 &&
  ${S_DIR}/create_total_components.sh ${YEAR} 2>&1 &&
  rm ${S_DIR}/ngData -rf
}

update_yearly_components () {
  declare -i YEAR=${1}
  declare -i MONTH=${2}

  startMonth=1
  [[ ${YEAR} -eq 2017 ]] && startMonth=5
  ${S_DIR}/update_modules.sh ${YEAR} ${startMonth} ${MONTH} 2>&1
}

create_users_components () {
  YEAR=${1}

  [[ -d ${A_DIR}/users/${YEAR} ]] && rm ${A_DIR}/users/${YEAR} -rf
  mkdir -p ${A_DIR}/users/${YEAR}
  ${S_DIR}/create_users_components.sh -c all ${YEAR} 2>&1 &&
  ${S_DIR}/create_users_components.sh -m all ${YEAR} 2>&1 &&
  rm ${S_DIR}/ngData -rf
}

htaccess () {
  cat << EOF
AuthUserFile /www/faculty/it/bwHPC/.htpasswd
AuthName "index.html"
AuthType Basic
Require user admin
EOF
}

install_npm()
{
  if [[ ! -d "${MD}/node_modules" ]]; then
    cd ${MD} &&
    npm install &&
    npm uninst typescript &&
    npm i -S typescript@3.5 &&
    npm audit fix
  fi
}

update () {
  [[ ! -d ${A_DIR} ]] && mkdir -p ${A_DIR}
  [[ ! -d ${OUTPUT_DIR} ]] && mkdir ${OUTPUT_DIR}
  declare -i fromYear=2017

  [[ ${CURRENT_YEAR} -gt "2020" ]] && declare -i CURRENT_YEAR="2020" && declare -i CURRENT_MONTH="3"
  while [[ ${fromYear} -lt ${CURRENT_YEAR} ]]; do
    [[ ! -d ${OUTPUT_DIR}/../${fromYear} ]] ||
    [[ ! -d ${OUTPUT_DIR}/../haw/${fromYear} ]] &&
    collect_data ${fromYear}
    [[ ! -f ${A_DIR}/_data/${fromYear}.ts ]] ||
    [[ ! -f ${A_DIR}/_data/bwUniData_${fromYear}.ts ]] && gather_data ${fromYear}
    [[ ! -d ${A_DIR}/users/${fromYear} ]] && create_users_components ${fromYear}
    create_unis_components ${fromYear} 12
    update_yearly_components ${fromYear} 12

    fromYear=$(( ${fromYear} + 1 ))
  done
  collect_data ${CURRENT_YEAR}
  gather_data ${CURRENT_YEAR}
  create_users_components ${CURRENT_YEAR}
  create_unis_components ${CURRENT_YEAR} ${CURRENT_MONTH}
  update_yearly_components ${CURRENT_YEAR} ${CURRENT_MONTH}
  if [[ ${CURRENT_MONTH} -eq 1 ]]; then
    create_users_components $(( ${CURRENT_YEAR} - 1 ))
    python3 ${S_DIR}/create_tsconfig.py -y ${CURRENT_YEAR}
  fi
  [[ ! -f ${A_DIR}/bwUniCluster1/tsconfig-prod-aot.json ]] &&
  python3 ${S_DIR}/create_tsconfig.py -y ${CURRENT_YEAR}
  ${S_DIR}/copy_stds.sh

  python3 ${S_DIR}/total.py -o ${A_DIR}/_data/total.ts
  PUBLIC_DIR=${A_DIR}/../../public
  [[ ! -d ${PUBLIC_DIR} ]] && mkdir ${PUBLIC_DIR}
  htaccess > ${PUBLIC_DIR}/.htaccess

  #install_npm
}

help_menu () {
  cat << EOF
  Update bwUniCluster1 up to `date`

  Usage: ${0} [OPTIONS]

  OPTIONS:
    -h | --help         Show this message

  EXAMPLES:
    Update bwUniCluster1 till `date`
        $ ${0}
EOF
}

case "${1}" in
  -h | --help)
    help_menu
  ;;
  *)
    update
  ;;
esac
