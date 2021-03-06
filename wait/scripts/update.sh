#!/usr/bin/env bash

MD="`dirname $(readlink -f ${0})`/.."
S_DIR=${MD}/scripts
A_DIR=${MD}/src/app

declare -i START_YEAR="2020"
declare -i YEAR=`date -d 'yesterday' '+%Y'`
#declare -i YEAR="2022"

htaccess () {
  cat << EOF
AuthUserFile /www/faculty/it/bwHPC/.htpasswd
AuthName "index.html"
AuthType Basic
Require user admin
EOF
}

create_prod_files()
{
  echo "Build production files..."
  ${S_DIR}/tsconfig.sh ${START_YEAR} ${YEAR}

  PUBLIC_DIR=${MD}/public
  [[ ! -d ${PUBLIC_DIR} ]] && mkdir -p ${PUBLIC_DIR}
  htaccess > "${PUBLIC_DIR}/.htaccess"
}

install_npm_packs()
{
  if [[ ! -d "${MD}/node_modules" ]]; then
    npm install &&
    npm un typescript &&
    npm i -S typescript@4.0 &&
    npm audit fix
  fi
}

create_data_files()
{
  echo "Build data files"
  month=`date -d 'yesterday' '+%m'`
  month="${month#'0'}" # remove '0' prefix

  data_folder="${A_DIR}/_data"
  [[ ! -d ${data_folder} ]] && mkdir -p ${data_folder}

  python3 ${S_DIR}/get_data.py
  python3 ${S_DIR}/get_top_data.py
}

create_angular_app()
{
  echo "Build angular app files"
  ${S_DIR}/app_files.sh ${START_YEAR} ${YEAR}
  ${S_DIR}/helpers.sh
  ${S_DIR}/yearly_files.sh ${START_YEAR} ${YEAR}
  ${S_DIR}/top_files.sh ${START_YEAR} ${YEAR}
}

update()
{
  [[ -d ${A_DIR} ]] && rm -rf ${A_DIR}
  mkdir -p ${A_DIR}

  # run update functions
  create_data_files
  create_angular_app
  create_prod_files
  #install_npm_packs
}

help_menu () {
  cat << EOF
  Update wait data

  Usage: ${0} [OPTIONS]

  OPTIONS:
    -h | --help         Show this message
    -p | --prod         Create production files

  EXAMPLES:
    Update wait
        $ ${0}
EOF
}

case "${1}" in
  -h | --help)
    help_menu
  ;;
  -p | --prod)
    create_prod_files
  ;;
  *)
    update
  ;;
esac
