#!/usr/bin/env bash

PATH=$PATH:$HOME/WORK/node-v10.16.0-linux-x64/bin
MD="$HOME/WORK/haw_ucc"
UPDATE_FILE="$HOME/WORK/update.log"

cd ${MD}/bwUniCluster2
echo -e "\n=== update $MD on `date` \n" > "${UPDATE_FILE}"
npm run update 1>>${UPDATE_FILE} 2>&1 &&

echo -e "\n=== rsync angular" >> ${UPDATE_FILE} &&
npm run rsync 1>>${UPDATE_FILE} 2>&1 &&

echo -e "\n=== update haw's" >> "${UPDATE_FILE}" &&
cd ${MD}/app_uni &&
npm run update all 1>>${UPDATE_FILE} 2>&1 &&

echo -e "\n=== DONE! `date`" >> "${UPDATE_FILE}"
