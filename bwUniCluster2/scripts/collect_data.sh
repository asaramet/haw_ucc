#!/usr/bin/env bash

DATA_FOLDER="/www/faculty/it/bwHPC/SCRIPTS/bwUniCluster2"
#SERVER_FOLDER="es_asaramet@bwunicluster.scc.kit.edu:/opt/bwhpc/es/dbdata"
#SERVER_FOLDER="asaramet@grid01.hs-esslingen.de:/opt/openfoam/bwUniData"
SERVER_FOLDER="asaramet@comserver.hs-esslingen.de:/www/faculty/it/bwHPC/SCRIPTS/bwUniCluster2"

sync()
{
  #echo "Gathering data from bwUniCluster..."
  [[ ! -d ${DATA_FOLDER} ]] && mkdir -p ${DATA_FOLDER}
  rsync -uar ${SERVER_FOLDER}/*_logs ${DATA_FOLDER}
}

help()
{
  cat << EOF
  Collect and synchronize date from ${SERVER_FOLDER} to ${DATA_FOLDER}

  Usage: ${0}

  OPTIONS:
    -h | --help       Show this message

  NO OPTIONS          will sync tha data

  EXAMPLES:
    Synchronize all data with bwUniCluster2
        $ ${0}
EOF
}

case "${1}" in
  -h | --help)
    help
  ;;
  *)
    sync
  ;;
esac
