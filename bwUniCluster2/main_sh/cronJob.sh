#!/usr/bin/env bash

PATH=$PATH:$HOME/WORK/node-v14.15.4-linux-x64/bin
MD="$HOME/WORK/haw_ucc"
UPDATE_FILE="$HOME/WORK/update.log"

update_main()
{
  cd ${MD}/bwUniCluster2
  echo -e "\n=== update $MD on `date` \n" > "${UPDATE_FILE}"
  npm run update 1>>${UPDATE_FILE} 2>&1 &&

  echo -e "\n=== sync angular" >> ${UPDATE_FILE} &&
  npm run rsync 1>>${UPDATE_FILE} 2>&1
}

update_haws()
{
  echo -e "\n=== update haw's" >> "${UPDATE_FILE}" &&
  cd ${MD}/app_uni2 &&
  npm run update 1>>${UPDATE_FILE} 2>&1
}

update_wait()
{
  cd "${MD}/wait"
  echo -e "\n=== update $MD on `date` \n" > "${UPDATE_FILE}"
  npm run update 1>>${UPDATE_FILE} 2>&1 &&

  echo -e "\n=== rsync angular" >> ${UPDATE_FILE} &&
  npm run rsync 1>>${UPDATE_FILE} 2>&1
}

set_env()
{
  VERSION="3.8.2"
  BASE_DIR="/home/rsns01/staff/it/asaramet/unix/WORK/Python/${VERSION}"

  if [[ -d ${BASE_DIR} ]]; then
    export PATH="${BASE_DIR}/bin:${PATH}"
    export LD_LIBRARY_PATH="${BASE_DIR}/lib:${LD_LIBRARY_PATH}"
    export INCLUDE="${BASE_DIR}/include/python3.8:${INCLUDE}"
  fi
}

set_env &&
update_main &&
update_wait &&
update_haws &&
echo -e "\n=== DONE! `date`" >> "${UPDATE_FILE}"
