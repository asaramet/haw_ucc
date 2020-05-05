#!/usr/bin/env bash

MD="`dirname $(readlink -f ${0})`/.."
OUT_FILE="${MD}/src/app/_data/total.ts"
[[ -f ${OUT_FILE} ]] && rm -f ${OUT_FILE}

DATA_FOLDER="/www/faculty/it/bwHPC/SCRIPTS/bwUniCluster2/sreport_logs"

declare -i YEAR=`date -d 'yesterday' '+%Y'`
declare -i START_YEAR="2020"

echo_data()
{
  year="${1}"
  month="${2}"

  month_strg=${month}
  [[ ${month} -lt 10 ]] && month_strg="0${month}"

  log_file="${DATA_FOLDER}/${year}-${month_strg}.log"
  [[ ! -f ${log_file} ]] && echo "File ${log_file} doesn't exist" && exit 1

  while read -r line; do
    IFS=" " read -ra ADDR <<< ${line}
    [[ ${ADDR[0]} != "uc2" ]] && continue
    [[ ${ADDR[1]} == "root" ]] && declare -i root=${ADDR[2]}
    [[ ${ADDR[1]} == "haw" ]] && declare -i haw=${ADDR[2]} && break
  done < ${log_file}
  HAW=$(echo ${root} ${haw} | awk '{ printf "%.2f", ($2 * 100 ) / $1 }')

  echo "{year: ${year}, month: ${month}, haw: ${HAW}, total: 100}"
}

write_ts()
{
  # usage write_ts <START_MONTH> <END_MONTH>
  declare -i year=${1}
  declare -i end_month=${2}

  [[ ${year} -lt ${START_YEAR} ]] && echo "Wrong year specified: ${year}" && exit 1
  [[ ${end_month} -eq 0 ]] && echo "Not enough arguments specified!" && exit 1

  declare -i start_month="1"
  [[ ${year} -eq 2020 ]] && declare -i start_month="3"

  echo "export const total_uca_${year} = ["

  while [[ ${start_month} -lt ${end_month} ]]; do
    echo "  `echo_data  ${year} ${start_month}`,"
    start_month=$(( ${start_month} + 1))
  done

  echo "  `echo_data  ${year} ${end_month}`" # same line without comma

  echo -e "]\n"
}

while [[ ${START_YEAR} -lt ${YEAR} ]]; do
  write_ts ${START_YEAR} "12" >> ${OUT_FILE}
  START_YEAR=$(( ${START_YEAR} + 1 ))
done

declare -i END_MONTH=`date -d 'yesterday' '+%m'`
write_ts ${YEAR} ${END_MONTH} >> ${OUT_FILE}
