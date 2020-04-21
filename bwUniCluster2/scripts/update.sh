#!/usr/bin/env bash

MD="`dirname $(readlink -f ${0})`/.."

S_DIR=${MD}/scripts
A_DIR=${MD}/src/app

create_data_files()
{
  ${S_DIR}/collect_data.sh

  DATA_FOLDER="${A_DIR}/_data"
  [[ ! -d ${DATA_FOLDER} ]] && mkdir -p ${DATA_FOLDER}
  
  ${S_DIR}/write_bwUniData.sh
  ${S_DIR}/write_data_year.sh
  ${S_DIR}/write_total.sh
}

update()
{
  create_data_files
}

update
