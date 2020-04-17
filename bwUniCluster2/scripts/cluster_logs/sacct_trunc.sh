#!/usr/bin/env bash

# Remove repeted lines from old log file.

DATA_FOLDER="/opt/bwhpc/es/dbdata/sacct_logs"

MONTH_FORMAT='+%Y-%m'
MONTH=`date -d 'today' ${MONTH_FORMAT}`
L_MONTH=`date -d "${MONTH}-01 -1 day" ${MONTH_FORMAT}`

CURRENT_LOGS="${DATA_FOLDER}/${MONTH}.log"
[[ ! -f ${CURRENT_LOGS} ]] && exit 0

while read -r line; do
  IFS=" " read -ra ADDR <<< ${line}
  [[ ${ADDR[0]} == "JobID" ]] || [[ ${ADDR[0]} == "------------" ]] && continue

  #grep ${ADDR[0]} ${DATA_FOLDER}/${L_MONTH}.log
  sed -i "/${ADDR[0]}/d" ${DATA_FOLDER}/${L_MONTH}.log
done < ${CURRENT_LOGS}
