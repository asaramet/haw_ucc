#!/usr/bin/env bash

LOG_FOLDER="/opt/bwhpc/es/dbdata/sreport_logs"

DATE_FORMAT='+%Y-%m-%d'
MONTH_FORMAT='+%Y-%m'
MONTH=`date -d 'today' ${MONTH_FORMAT}`
START="${MONTH}-01"
END=`date -d 'today' ${DATE_FORMAT}`

L_END=`date -d "${START} -1 day" ${DATE_FORMAT}`
L_MONTH=`date -d ${L_END} ${MONTH_FORMAT}`
L_START="${L_MONTH}-01"

[[ ! -d ${LOG_FOLDER} ]] && mkdir -p ${LOG_FOLDER}
sreport cluster AccountUtilizationByUser Start=${START} End=${END} > ${LOG_FOLDER}/${MONTH}.log
sreport cluster AccountUtilizationByUser Start=${L_START} End=${L_END} > ${LOG_FOLDER}/${L_MONTH}.log
