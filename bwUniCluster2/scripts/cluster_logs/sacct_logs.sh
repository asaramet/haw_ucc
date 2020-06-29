#!/usr/bin/env bash

LOG_FOLDER="/opt/bwhpc/es/dbdata/sacct_logs"

ACCOUNT="haw"
FIELDS="JobID,Group,User%20,cputimeraw,ExitCode,State,Start,End,ncpus,partition%15,Submit"

DATE_FORMAT='+%Y-%m-%d'

MONTH=`date -d "yesterday" '+%Y-%m'`
END=`date -d "yesterday" ${DATE_FORMAT}`
START="${MONTH}-01"
OUT_FILE="${MONTH}.log"

collect () {
  #echo "Collecting data for ${MONTH}"
  #echo "sacct -a -A ${ACCOUNT} -X -o ${FIELDS} -S ${START} -E ${END} > ${LOG_FOLDER}/${OUT_FILE}"
  [[ ! -d ${LOG_FOLDER} ]] && mkdir -p ${LOG_FOLDER}
  sacct -a -A ${ACCOUNT} -X -o ${FIELDS} -S ${START} -E ${END} > ${LOG_FOLDER}/${OUT_FILE}
}

collect_range () {
  if [[ -z ${2} ]]; then
    [[ -z ${1} ]] && echo "ERROR: Not enough arguments specified!" && exit 1
    END=${1}
    MONTH=`date -d "${END}" '+%Y-%m'`
    START=`date -d ${MONTH}-01 "${DATE_FORMAT}"`
  else
    START=${1}
    END=${2}
    MONTH=`date -d "${END}" '+%Y-%m'`
  fi

  IFS='-' read -ra ADDR <<< "${START}"
  declare -i START_YEAR=${ADDR[0]}
  declare -i START_MONTH=${ADDR[1]}
  declare -i START_DAY=${ADDR[2]}

  [[ ${START_DAY} -eq 0 ]] || [[ ${START_MONTH} -eq 0 ]] || [[ ${START_YEAR} -eq 0 ]] &&
  echo "ERROR: Wrong START DATE!" && exit 1

  [[ ${START_YEAR} -lt 2020 ]] || [[ ${START_YEAR} -gt 2100 ]] &&
  echo "ERROR: START Year doesn't seam right!" && exit 1

  [[ ${START_MONTH} -lt 1 ]] || [[ ${START_MONTH} -gt 12 ]] &&
  echo "ERROR: START Month doesn't seam right!" && exit 1

  [[ ${START_DAY} -lt 1 ]] || [[ ${START_DAY} -gt 31 ]] &&
  echo "ERROR: START Day doesn't seam right!" && exit 1

  IFS='-' read -ra ADDR <<< "${END}"
  declare -i END_YEAR=${ADDR[0]}
  declare -i END_MONTH=${ADDR[1]}
  declare -i END_DAY=${ADDR[2]}

  [[ ${END_DAY} -eq 0 ]] || [[ ${END_MONTH} -eq 0 ]] || [[ ${END_YEAR} -eq 0 ]] &&
  echo "ERROR: Wrong END DATE!" && exit 1

  [[ ${END_YEAR} -lt 2020 ]] || [[ ${END_YEAR} -gt 2100 ]] &&
  echo "ERROR: END Year doesn't seam right!" && exit 1

  [[ ${END_MONTH} -lt 1 ]] || [[ ${END_MONTH} -gt 12 ]] &&
  echo "ERROR: END Month doesn't seam right!" && exit 1

  [[ ${END_DAY} -lt 1 ]] || [[ ${END_DAY} -gt 31 ]] &&
  echo "ERROR: END Day doesn't seam right!" && exit 1

  [[ ${START_YEAR} -gt ${END_YEAR} ]] &&
  echo "ERROR: Start year should not be greater than end year" && exit 1

  [[ ${START_YEAR} -eq ${END_YEAR} ]] && [[ ${START_MONTH} -gt ${END_MONTH} ]] &&
  echo "ERROR: Start month should not be greater than end month in the same year" && exit 1

  [[ ${START_YEAR} -eq ${END_YEAR} ]] && [[ ${START_MONTH} -eq ${END_MONTH} ]] &&
  [[ ${START_DAY} -gt ${END_DAY} ]] &&
  echo "ERROR: Start day should not be greater than end day in the same year and month" && exit 1

  if [[ ${START_YEAR} -eq ${END_YEAR} ]]; then
    [[  ${START_MONTH} -eq ${END_MONTH} ]] && OUT_FILE="${MONTH}.log" && collect && exit 0
    while [[ ${START_MONTH} -lt ${END_MONTH} ]]; do

      START=`date -d "${START_YEAR}-${START_MONTH}-${START_DAY}" "+%Y-%m-%d"`

      declare -i START_MONTH=$(( ${START_MONTH} + 1 ))

      END=`date -d "${START_YEAR}-${START_MONTH}-01 -1 day" "+%Y-%m-%d"`
      MONTH=`date -d "${END}" '+%Y-%m'`
      OUT_FILE="${MONTH}.log"

      collect
    done

    END=`date -d "${END_YEAR}-${END_MONTH}-${END_DAY}" '+%Y-%m-%d'`
    MONTH=`date -d "${END}" '+%Y-%m'`

    START="${MONTH}-01"
    OUT_FILE="${MONTH}.log"
    collect && exit 0
  fi
  echo "NOT yet configured to process multiple years sorry" && exit 0
}

help_menu () {
  cat << EOF
  Collect jobs data on the clster in ${LOG_FOLDER}

  Usage: ${0} [OPTION] [START DATE] [END DATE]

  NOTE: If no OPTIONS are provided the script will collect data from 1-st of Month to yesterday.

  OPTIONS:
    -h | --help         Show this message
    -d | --date         Gather data starting with 'START DATE' till 'END DATE'

  START DATE            Date in format YY-MM-DD to start collecting data from.
                        If omitted will be considerd 1-st of 'END DATE': YY-MM-01

  END DATE              Date in format YY-MM-DD up to wich the data will be gathered.

  EXAMPLES:
    Gather data from 1-st on month till yesterday:
        $ ${0}

    Gather data starting with 3-d of April 2020 till 23-d of May 2020:
        $ ${0} -d 2020-04-03 2020-05-23

    Gather data for May 2020:
        $ ${0} -d 2020-05-31
EOF
}

case "${1}" in
  -h | --help)
    help_menu
  ;;
  -d | --date)
    collect_range ${2} ${3}
  ;;
  *)
    collect
  ;;
esac
