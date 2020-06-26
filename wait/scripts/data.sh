#!/usr/bin/env bash

# Build src/app/app.* files

MD="`dirname $(readlink -f ${0})`/.."
A_DIR="${MD}/src/app/_data"

declare -i START_YEAR="${1}"
declare -i YEAR="${2}"

data() {
  year=${1}

  cat << EOF
export const single = [
    [new Date(${year},3, 11), [8,30,0]],
    [new Date(${year},4, 12), [5,30,0]],
    [new Date(${year},4, 20), [5,0,0]],
    [new Date(${year},5, 1), [3,20,22]],
    [new Date(${year},6, 30), [5,22,11]],
    [new Date(${year},7, 1), [3, 29,9]]
]

export const multiple = [
    [new Date(${year},3, 11), [8,30,0]],
    [new Date(${year},4, 12), [5,30,0]],
    [new Date(${year},4, 20), [5,0,0]],
    [new Date(${year},5, 1), [3,20,22]],
    [new Date(${year},6, 30), [5,22,11]],
    [new Date(${year},7, 1), [3, 29,9]]
]

export const dev_single = [
    [new Date(${year},3, 11), [8,30,0]],
    [new Date(${year},4, 12), [5,30,0]],
    [new Date(${year},4, 20), [5,0,0]],
    [new Date(${year},5, 1), [3,20,22]],
    [new Date(${year},6, 30), [5,22,11]],
    [new Date(${year},7, 1), [3, 29,9]]
]
EOF
}

[[ ! -d ${A_DIR} ]] && mkdir -p ${A_DIR}

while [[ ${START_YEAR} -le ${YEAR} ]]; do
  data ${START_YEAR} > "${A_DIR}/${START_YEAR}.ts"
  START_YEAR=$(( ${START_YEAR} + 1 ))
done
