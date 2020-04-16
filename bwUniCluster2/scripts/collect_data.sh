#!/usr/bin/env bash

DATA_FOLDER="/www/faculty/it/bwHPC/SCRIPTS/bwUniCluster2"
SERVER_FOLDER="es_asaramet@bwunicluster.scc.kit.edu:/opt/bwhpc/es/dbdata"

rsync -uar ${SERVER_FOLDER}/*_logs ${DATA_FOLDER}
