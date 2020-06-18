#!/usr/bin/env bash

SERVER_FOLDER="asaramet@grid01.hs-esslingen.de:/opt/openfoam/bwUniData"
DATA_FOLDER="/opt/bwhpc/es/dbdata/"

rsync -uar ${DATA_FOLDER} ${SERVER_FOLDER}
