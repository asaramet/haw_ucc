#!/usr/bin/env bash

MD=`dirname $(readlink -f $0)`
NG_DATA=${MD}/../../bwUniCluster1/scripts/ngData
#prefixes='aa hu'
prefixes='aa as hf hk hn hr hs ht hu ro'
validPrefixes='aa as es hf hk hn hr hs ht hu ro'
host="asaramet@comserver.hs-esslingen.de"

clean () {
  echo "Clean all!"
  npm run clean:all
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

  if [[ ! -d node_modules ]]; then
    npm install &&
    npm un typescript &&
    npm i -S typescript@3.5 &&
    npm audit fix
  fi
  # compile
  ${MD}/create.sh all ${1} &&
  npm run compile
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
    for prefix in ${prefixes}; do
      update ${prefix}
    done
    clean
  ;;
  *)
    [[ -z ${1} ]] && echo "ERROR: Please specify HAW. For more info do: '${0} help'" && exit 0
    for prefix in ${validPrefixes}; do
      if [[ ${prefix} == ${1} ]]; then
        update ${1}
        clean
        exit 0
      fi
    done
    echo "ERROR: ${1} is not a valid HAW prefix!"
  ;;
esac
