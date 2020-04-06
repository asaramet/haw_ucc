#!/usr/bin/env bash

MD=`dirname $(readlink -f $0)`

# old variables
OLD_COMMSERVER_ID='asaramet'
OLD_COMMSERVER_HOSTNAME='comserver.hs-esslingen.de'
OLD_COMMSERVER_FOLDER='/www/faculty/it/bwHPC/_ssl'

OLD_UNICLUSTER_ID="es_asaramet"
OLD_UNICLUSTER_HOSTNAME="bwunicluster.scc.kit.edu"
OLD_DATA_FOLDER="/www/faculty/it/bwHPC/SCRIPTS"

# new
NEW_COMMSERVER_ID='asaramet'
NEW_COMMSERVER_HOSTNAME='comserver.hs-esslingen.de'
NEW_COMMSERVER_FOLDER='/www/faculty/it/bwHPC/_ssl'

NEW_UNICLUSTER_ID="es_asaramet"
NEW_UNICLUSTER_HOSTNAME="bwunicluster.scc.kit.edu"
NEW_DATA_FOLDER="/www/faculty/it/bwHPC/SCRIPTS"

# changes
sed -i s:${OLD_COMMSERVER_ID}:${NEW_COMMSERVER_ID}:g ${MD}/bwUniCluster1/package.json
sed -i s:${OLD_COMMSERVER_HOSTNAME}:${NEW_COMMSERVER_HOSTNAME}:g ${MD}/bwUniCluster1/package.json
sed -i s:${OLD_COMMSERVER_FOLDER}:${NEW_COMMSERVER_FOLDER}:g ${MD}/bwUniCluster1/package.json

sed -i s:${OLD_COMMSERVER_ID}:${NEW_COMMSERVER_ID}:g ${MD}/app_uni/scripts/update.sh
sed -i s:${OLD_COMMSERVER_HOSTNAME}:${NEW_COMMSERVER_HOSTNAME}:g ${MD}/app_uni/scripts/update.sh
sed -i s:${OLD_COMMSERVER_FOLDER}:${NEW_COMMSERVER_FOLDER}:g ${MD}/app_uni/scripts/update.sh

sed -i s:${OLD_UNICLUSTER_ID}:${NEW_UNICLUSTER_ID}:g ${MD}/scripts/collect_data.sh
sed -i s:${OLD_UNICLUSTER_HOSTNAME}:${NEW_UNICLUSTER_HOSTNAME}:g ${MD}/scripts/collect_data.sh
sed -i s:${OLD_DATA_FOLDER}:${NEW_DATA_FOLDER}:g ${MD}/scripts/collect_data.sh

sed -i s:${OLD_DATA_FOLDER}/haw:${NEW_DATA_FOLDER}/haw:g ${MD}/scripts/gather_costs.sh

sed -i s:${OLD_DATA_FOLDER}/haw:${NEW_DATA_FOLDER}/haw:g ${MD}/scripts/user_data.py
