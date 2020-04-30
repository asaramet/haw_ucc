#!/usr/bin/env bash

MD=`dirname $(readlink -f $0)`
prefixes='aa as es hf hk hn hr hs ht hu ro'
host="asaramet@comserver.hs-esslingen.de"

check_prefix()
{
  prefix=${1}
  [[ -z ${prefix} ]] && return
  for el in ${prefixes}; do
    [[ ${el} == ${prefix} ]] && return
  done
  echo "ERROR: Wrong HAW prefix: ${prefix}" && exit 1
}

clean () {
  echo "Clean all!"
  npm run clean:all
}

install_npm_packages()
{
  if [[ ! -d "${MD}/../node_modules" ]]; then
    cd "${MD}/.."
    npm install &&
    npm un typescript &&
    npm i -S typescript@3.5 &&
    npm audit fix
  fi
}

htaccess () {
  cat << EOF
AuthUserFile /www/faculty/it/bwHPC/.htpasswd
AuthName "index.html"
AuthType Basic
Require user admin ${1}Admin
EOF
}

update()
{
  haw_prefix=${1}
  echo "Update data for ${haw_prefix}"
  cd "${MD}/.."
  install_npm_packages
  npm run make &&
  npm run clean:src &&

  # compile
  TMP_FILE="${MD}/temp.txt"
  [[ -f ${TMP_FILE} ]] && rm -f ${TMP_FILE}
  ${MD}/../../bwUniCluster2/scripts/get_active_haws.sh ${TMP_FILE}
  ${MD}/create.sh ${haw_prefix} ${TMP_FILE}
  rm -f ${TMP_FILE}
  npm run compile
  htaccess ${haw_prefix} > public/.htaccess
}

sync()
{
  haw_prefix=${1}
  chmod g=u public -R
  rsync -uavhr public/ ${host}:/www/faculty/it/bwHPC/uni2/${haw_prefix}/ --delete-excluded
}


help_menu () {
  cat << EOF
  Usage ${0} [OPTIONS] [UNI PREFIX]

  OPTIONS:
    help       Show this message

  EXAMPLES:
    Create components for hu:
      $ ${0} hu

    Create components for ${prefixes}
      $ ${0}

EOF
}

case ${1} in
  -h | --help)
    help_menu
  ;;
  *)
    check_prefix ${1}
    if [[ ! -z ${1} ]]; then
      prefix=${1}
      update ${prefix} &&
      sync ${prefix} &&
      clean &&
      exit 0
    fi
    for prefix in ${prefixes}; do
      update ${prefix} &&
      sync ${prefix} &&
      clean
    done
esac
