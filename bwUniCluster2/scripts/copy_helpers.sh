#!/usr/bin/env bash

MD="`dirname $(readlink -f ${0})`"

A_DIR="${MD}/../src/app"
H_DIR="${A_DIR}/_helpers"

STD_DIR="${MD}/std_files"
HELPERS_DIR="${STD_DIR}/_helpers"
APP_DIR="${STD_DIR}/app"

[[ ! -d ${A_DIR} ]] && mkdir -p ${A_DIR}

[[ -d ${H_DIR} ]] && rm -rf ${H_DIR}
cp "${HELPERS_DIR}" ${H_DIR} -rf

[[ -d "${A_DIR}/unis" ]] && rm -rf "${A_DIR}/unis"
cp "${APP_DIR}" "${A_DIR}" -rf
