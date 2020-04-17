#!/usr/bin/env bash

MD="`dirname $(readlink -f ${0})`/.."

S_DIR=${MD}/scripts
A_DIR=${MD}/src/app

update()
{
  ${S_DIR}/collect_data.sh
  ${S_DIR}/write_bwUniData.sh
}

update
