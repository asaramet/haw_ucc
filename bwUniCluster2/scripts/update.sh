#!/usr/bin/env bash

MD="`dirname $(readlink -f ${0})`/.."
S_DIR=${MD}/scripts
A_DIR=${MD}/src/app
PUBLIC_DIR=${MD}/public

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

create_main_app()
{
  ${S_DIR}/copy_helpers.sh
  ${S_DIR}/create_mains.sh
  ${S_DIR}/create_year_mains.sh
  ${S_DIR}/create_year_months.sh
  ${S_DIR}/create_year_annual.sh
  ${S_DIR}/create_year_total.sh
}

create_users_folder()
{
  TMP_FILE="${A_DIR}/temp.txt"
  [[ -f ${TMP_FILE} ]] && rm -f ${TMP_FILE}

  ${S_DIR}/get_active_haws.sh ${TMP_FILE}

  ${S_DIR}/create_users_mains.sh ${TMP_FILE}
  ${S_DIR}/create_users_haws.sh ${TMP_FILE}

  rm -f ${TMP_FILE}
}

create_prod_files()
{
  ${S_DIR}/create_tsconfig.sh

  [[ ! -d ${PUBLIC_DIR} ]] && mkdir -p ${PUBLIC_DIR}
  htaccess > "${PUBLIC_DIR}/.htaccess"
}

install_npm_packs()
{
  if [[ ! -d node_modules ]]; then
    npm install &&
    npm un typescript &&
    npm i -S typescript@4.0 &&
    npm audit fix
  fi
}

update()
{
  [[ -d ${PUBLIC_DIR} ]] && rm -rf ${PUBLIC_DIR}
  [[ -d ${A_DIR} ]] && rm -rf ${A_DIR}

  mkdir -p ${A_DIR}
  create_data_files
  create_main_app
  create_users_folder
  create_prod_files
  #install_npm_packs
}

help_menu () {
  cat << EOF
  Update bwUniCluster2 data

  Usage: ${0} [OPTIONS]

  OPTIONS:
    -h | --help         Show this message
    -p | --prod         Create only prod specific files

  EXAMPLES:
    Update bwUniCluster2
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
