#!/usr/bin/env bash

PATH=$PATH:$HOME/WORK/node-v14.0.0-linux-x64/bin
MD="$HOME/WORK/haw_ucc"
UPDATE_FILE="$HOME/WORK/update.log"

update_main()
{
  cd ${MD}/bwUniCluster2
  echo -e "\n=== update $MD on `date` \n" > "${UPDATE_FILE}"
  npm run update 1>>${UPDATE_FILE} 2>&1 &&

  echo -e "\n=== rsync angular" >> ${UPDATE_FILE} &&
  npm run rsync 1>>${UPDATE_FILE} 2>&1
}

update_haws()
{
  echo -e "\n=== update haw's" >> "${UPDATE_FILE}" &&
  cd ${MD}/app_uni &&
  npm run update 1>>${UPDATE_FILE} 2>&1
}

update_main &&
update_haws
echo -e "\n=== DONE! `date`" >> "${UPDATE_FILE}"
