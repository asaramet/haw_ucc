#!/usr/bin/env bash
# Collect CPUTime per user and uni in javascript dicts and save them to ${YEAR}.ts files

MD="`dirname $(readlink -f ${0})`/.."

OUT_FOLDER="${MD}/src/app/_data"

declare -i YEAR=`date -d 'yesterday' '+%Y'`
declare -i END_MONTH=`date -d 'yesterday' '+%m'`

declare -i START_YEAR="2020"

[[ ${YEAR} -lt ${START_YEAR} ]] && echo "Wrong argument YEAR: ${YEAR}" && exit 1

# build last year data during January this year
[[ ${START_YEAR} -lt ${YEAR} ]] && [[ ${END_MONTH} -eq 1 ]] &&
START_YEAR=$(( ${YEAR} - 1 )) &&
echo "... Building ${OUT_FOLDER}/${START_YEAR}.ts" &&
python3 "${MD}/scripts/write_data_year.py" -y ${START_YEAR} -m "12"

echo "... Building ${OUT_FOLDER}/${YEAR}.ts"
python3 "${MD}/scripts/write_data_year.py" -y ${YEAR} -m ${END_MONTH}
