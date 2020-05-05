#!/usr/bin/env bash

# Scan log files and collect unis that hawe active users every month

[[ -z ${1} ]] && echo 'Temp folder is not specified' && exit 1
TMP_FILE=${1}

MD="`dirname $(readlink -f ${0})`/.."
A_DIR=${MD}/src/app
DATA_FOLDER="/www/faculty/it/bwHPC/SCRIPTS/bwUniCluster2/sacct_logs"
PREFIXES='aa as es hf hk hn hr hs ht hu ro'

declare -i START_YEAR="2020"
declare -i END_YEAR=`date -d 'yesterday' '+%Y'`

is_haw_active()
{
  year=${1}
  month=${2}
  prefix=${3}
  log_file=${4}

  while read -r line; do
    read -ra ADDR <<< ${line}
    if [[ ${ADDR[1]} == "${prefix}_${prefix}" ]] && [[ ${ADDR[3]} != "0" ]]; then
      echo -e "${year}\t\t${month}\t\t${prefix}"
      return
    fi
  done < ${log_file}
  return
}

read_monthly_logs()
{
  declare -i year=${1}
  declare -i end_month=${2}

  declare -i start_month="1"
  [[ ${year} -eq "2020" ]] && declare -i start_month="3"

  while [[ ${start_month} -le ${end_month} ]]; do
    month_str=${start_month}
    [[ ${start_month} -lt 10 ]] && month_str="0${start_month}"

    log_file="${DATA_FOLDER}/${year}-${month_str}.log"
    [[ ! -f ${log_file} ]] && start_month=$(( ${start_month} + 1 )) && continue

    for prefix in ${PREFIXES}; do
      is_haw_active ${year} ${start_month} ${prefix} ${log_file} >> ${TMP_FILE}
    done
    start_month=$(( ${start_month} + 1 ))
  done
}

while [[ ${START_YEAR} -le ${END_YEAR} ]]; do
  echo "... Writing temp data ${START_YEAR} into ${TMP_FILE}"
  END_MONTH="12"
  [[ ${START_YEAR} -eq ${END_YEAR} ]] && END_MONTH=`date -d 'yesterday' '+%m'`
  read_monthly_logs ${START_YEAR} ${END_MONTH}
  START_YEAR=$(( ${START_YEAR} + 1 ))
done
