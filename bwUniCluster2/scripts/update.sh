#!/usr/bin/env bash

MD="`dirname $(readlink -f ${0})`/.."
S_DIR=${MD}/scripts
A_DIR=${MD}/src/app

[[ -d ${A_DIR} ]] && rm -rf ${A_DIR}
mkdir -p ${A_DIR}

htaccess () {
  cat << EOF
AuthUserFile /www/faculty/it/bwHPC/.htpasswd
AuthName "index.html"
AuthType Basic
Require user admin
EOF
}

create_data_files()
{
  ${S_DIR}/collect_data.sh

  DATA_FOLDER="${A_DIR}/_data"
  [[ ! -d ${DATA_FOLDER} ]] && mkdir -p ${DATA_FOLDER}

  ${S_DIR}/write_bwUniData.sh
  ${S_DIR}/write_data_year.sh
  ${S_DIR}/write_total.sh
}

create_app()
{
  ${S_DIR}/copy_helpers.sh
  ${S_DIR}/create_mains.sh
  ${S_DIR}/create_year_mains.sh
  ${S_DIR}/create_year_months.sh
  ${S_DIR}/create_year_annual.sh
  ${S_DIR}/create_year_total.sh
}

update()
{
  create_data_files
  create_app

  PUBLIC_DIR=${MD}/public
  [[ -d ${PUBLIC_DIR} ]] && mkdir -p ${PUBLIC_DIR}
  htaccess > "${PUBLIC_DIR}/.htaccess"
}

update
