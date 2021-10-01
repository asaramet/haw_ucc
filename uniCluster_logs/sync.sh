#!/usr/bin/env bash

SERVER_FOLDER="asaramet@grid01.hs-esslingen.de:/opt/openfoam/bwUniData"
#SERVER_FOLDER="asaramet@134.108.34.12:/www/faculty/it/bwHPC/SCRIPTS/bwUniCluster2"
DATA_FOLDER="/opt/bwhpc/es/dbdata/"

rsync -uar ${DATA_FOLDER} ${SERVER_FOLDER}
