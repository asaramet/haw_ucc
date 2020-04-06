#!/usr/bin/env bash

MD=`dirname $(readlink -f $0)`
#prefixes='aa hu'
prefixes='aa as hf hk hn hr hs ht hu ro'
validPrefixes='aa as hf hk hn hr hs ht hu ro'
host="asaramet@comserver.hs-esslingen.de"

make () {
  npm run make &&
  npm install
}

clean () {
  echo "Clean all!"
  npm run clean:all
  NG_DATA=${MD}/../../scripts/ngData
  [[ -d ${NG_DATA} ]] && rm -rf ${NG_DATA}
}

htaccess () {
  cat << EOF
AuthUserFile /www/faculty/it/bwHPC/.htpasswd
AuthName "index.html"
AuthType Basic
Require user admin ${1}Admin
EOF
}

update () {
  echo "Update data for ${1}"
  npm run make &&
  npm run clean:src &&

  [[ ! -d public ]] && mkdir public;
  npm run clean:app &&

  # compile
  ${MD}/create.sh all ${1} &&
  npm run cp:aot &&
  ngc -p tsconfig-prod-aot.json &&
  npm run build:css && webpack --config webpack/aot.config.js &&
  htaccess ${1} > public/.htaccess

  # sync
  chmod g=u public -R
  rsync -uavhr public/ ${host}:/www/faculty/it/bwHPC/_ssl/${1}/ --delete-excluded

  # save
  [[ -d public ]] && [[ -d ./saves/${1} ]] && rm ./saves/${1} -rf && sleep 5 &&
  mv public saves/${1} || echo 'compile first!!!'
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
      $ ${0} all

EOF
}

case ${1} in
  help)
    help_menu
  ;;
  all)
    make
    for prefix in ${prefixes}; do
      update ${prefix}
    done
    clean
  ;;
  *)
    [[ -z ${1} ]] && echo "ERROR: Please specify HAW. For more info do: '${0} help'" && exit 0
    for prefix in ${validPrefixes}; do
      [[ ${prefix} -eq ${1} ]] && make && update ${1} && clean && exit 0
    done
    echo "ERROR: ${1} is not a valid HAW prefix!"
  ;;
esac
