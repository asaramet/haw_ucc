#!/usr/bin/env bash
# Collect CPUTime per uni and save it to bwUniData_*.ts files in $OUT_FOLDER

MD="`dirname $(readlink -f ${0})`/.."

DATA_FOLDER="/www/faculty/it/bwHPC/SCRIPTS/bwUniCluster2/sacct_logs"
OUT_FOLDER="${MD}/src/app/_data"

MONTH=`date -d 'yesterday' '+%m'` # doing from the 2-nd of every month
MONTH="${MONTH#'0'}" # remove '0' prefix

declare -i YEAR=`date -d 'yesterday' '+%Y'`

set_prefixes()
{
  year=${1}
  # prefixes to collect data into sacct_logs
  if [[ ${year} -eq "2020" ]]; then
    PREFIXES='aa as es hf hk hn hr hs ht hu ro'
  else
    PREFIXES='aa as es hk hn hr hs ht hu mn of ro'
  fi
}

collect_data ()
{
  year=${1}
  month=${2}

  data_file="${DATA_FOLDER}/${year}-${month}.log"

  set_prefixes ${year}

  declare -i total="0"
  for prefix in ${PREFIXES}; do
    declare -i total_cpu="0"
    while read -r line; do
      read -ra ADDR <<< ${line}
      if [[ ${ADDR[1]} == ${prefix}_${prefix} ]]; then
        declare -i cpu_time=${ADDR[3]}
        total_cpu=$(( ${total_cpu} + ${cpu_time} ))
        total=$(( ${total} + ${cpu_time} ))
      fi
    done < ${data_file}
    echo "${prefix}    ${total_cpu}"
  done

  echo "total ${total}"
}

write_body_montly()
{
  data_file=${1}
  while read -r line; do
    read -ra ADDR <<< ${line}
    [[ ${ADDR[0]} == "total" ]] && total=${ADDR[1]}
  done < ${data_file}
  while read -r line; do
    read -ra ADDR <<< ${line}
    [[ ${ADDR[0]} == "total" ]] && continue
    cost=${ADDR[1]}
    pct=$(echo ${total} ${cost} | awk '{ printf "%.2f", ($2 * 100 ) / $1 }')
    #pct=$(( ${ADDR[1]} * 100 / ${total}))
    echo "  {prefix: '"${ADDR[0]}"', pct: ${pct}, cost: ${cost}},"
  done < ${data_file}
}

write_body_total()
{
  data_file=${1}
  year=${2}

  set_prefixes ${year}

  for prefix in ${PREFIXES}; do
    declare -i cost="0"
    while read -r line; do
      read -ra ADDR <<< ${line}
      [[ ${ADDR[0]} == ${prefix} ]] && cost=$(( ${cost} + ${ADDR[1]} ))
    done < ${data_file}
    echo "  {prefix: '"${prefix}"', cost: ${cost}},"
  done
}

write_ts ()
{
  year=${1}
  last_month=${2}

  TEMP_FILE="${DATA_FOLDER}/temp.txt"
  [[ -f ${TEMP_FILE} ]] && rm -f ${TEMP_FILE}

  TEMP_FILE2="${DATA_FOLDER}/temp2.txt"
  [[ -f ${TEMP_FILE2} ]] && rm -f ${TEMP_FILE2}

  start_month="1"
  [[ ${year} -eq "2020" ]] && start_month="3"

  while [[ ${start_month} -le ${last_month} ]]; do
    mnt=${start_month}
    [[ ${start_month} -lt 10 ]] && mnt="0${start_month}"

    collect_data ${year} ${mnt} | tee ${TEMP_FILE} >> ${TEMP_FILE2}
    echo "export const uca_${year}_${mnt} = ["
    write_body_montly ${TEMP_FILE}
    echo -e "];\n"

    start_month=$(( ${start_month} + 1 ))
  done

  echo "export const uca_${year}_total = ["
  write_body_total ${TEMP_FILE2} ${year}
  echo "];"

  rm -f ${TEMP_FILE} ${TEMP_FILE2}
}

START_YEAR="2020"
while [[ ${START_YEAR} -lt ${YEAR} ]]; do
  OUT_FILE="${OUT_FOLDER}/bwUniData_${START_YEAR}.ts"
  echo "... Writing ${OUT_FILE}"
  write_ts ${START_YEAR} "12" > ${OUT_FILE}
  START_YEAR=$(( ${START_YEAR} + 1 ))
done

OUT_FILE="${OUT_FOLDER}/bwUniData_${YEAR}.ts"
echo "... Writing ${OUT_FILE}"
write_ts ${YEAR} ${MONTH} > ${OUT_FILE}
