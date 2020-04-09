#!/usr/bin/env bash
MD=`dirname $(readlink -f $0)`
dataFolder="/www/faculty/it/bwHPC/SCRIPTS"
prefixes='aa as es hf hk hn hr hs ht hu ro'
bwUniCluster_username="es_asaramet"

# if make fromYear 2017 if it's not set in options
declare -i fromYear=2017
[[ ! -z ${2} ]] && declare -i fromYear=${2}
[[ ! -z ${3} ]] && declare -i upToYear=${3}

sync_data () {
  echo "Synchronizing data with bwUniCluster..."
  [[ -d ${dataFolder} ]] && mkdir -p ${dataFolder}
  declare -i year=${1}
  currentYear=`date +"%Y"`
  echo ""
  echo "--- Year: ${year}"
  [[ ! -d ${dataFolder}/${year} ]] && mkdir -p ${dataFolder}/${year}
  statsFolder="${dataFolder}/statistics"
  [[ ! -d ${statsFolder} ]] && mkdir -p ${statsFolder}

  syncHost=${bwUniCluster_username}@bwUniCluster.scc.kit.edu
  #rsync -auv ${syncHost}:/opt/moab/stats/feedback/${year}*.log ${dataFolder}/${year} &&
  rsync -auv asaramet@comserver.hs-esslingen.de:${dataFolder}/${year}/${year}*.log ${dataFolder}/${year} &&
  rsync -auv ${syncHost}:/opt/bwhpc/common/admin/statistics/uc1_knotenauslastung_standorte.csv ${statsFolder} &&
  echo "DONE synchronizing!"
}

debug () {
  year=${1}
  debugFolder='${MD}/ngData/haw/debug'
  inputFolder="${dataFolder}/haw/${year}"

  if [[ -d ${inputFolder} ]]; then
    [[  -d ${debugFolder} ]] && rm -rf ${debugFolder}
    mkdir -p ${debugFolder}
    cp ${inputFolder} ${debugFolder} -rf &&
    for month in {01..12}; do
      logFile=${debugFolder}/${year}/${month}.log
      if [[ -f ${logFile} ]]; then
        for uniPrefix in ${prefixes}; do
          sed -i "/Group=${uniPrefix}_${uniPrefix}/d" ${logFile}
        done
      fi
    done
  else
    echo "Folder ${inputFolder} does not exist!"
  fi
}

collect_data () {
  year=${1}
  for uniPrefix in ${prefixes}; do
    echo "Collecting data for ${uniPrefix}..."
    outputFolder="${dataFolder}/haw/${uniPrefix}"
    [[ ! -d ${outputFolder} ]] && mkdir -p ${outputFolder}

    echo "For ${year}..."
    [[ ! -d ${outputFolder}/${year} ]] && mkdir -p ${outputFolder}/${year}
    [[ ! -d ${outputFolder}/../${year} ]] && mkdir -p ${outputFolder}/../${year}

    for month in {01..12}; do
      grep "Group=${uniPrefix}_${uniPrefix}" ${dataFolder}/${year}/${year}${month}* > ${outputFolder}/${year}/${month}.bak &&
      grep "Account=haw" ${outputFolder}/${year}/${month}.bak > ${outputFolder}/${year}/${month}.log &&
      rm -f ${outputFolder}/${year}/${month}.bak
      grep "Account=haw" ${dataFolder}/${year}/${year}${month}* > ${outputFolder}/../${year}/${month}.log
      sed -i "/Group=NOGROUP/d" ${outputFolder}/../${year}/${month}.log
    done

    # remove empty files
    find ${outputFolder}/${year} -type f -size 0 -exec rm {} \;
    find ${outputFolder}/../${year} -type f -size 0 -exec rm {} \;
    # remove empty folders
    find ${outputFolder}/${year} -maxdepth 0 -empty -exec rm {} -rf \;

    # collect yearly data
    yearlyDataFile=${outputFolder}/${year}/total.log
    [[ -f ${yearlyDataFile} ]] && rm -f ${yearlyDataFile}
    find ${outputFolder}/${year}/ -name *[0-9].log -exec cat {} >> ${yearlyDataFile} \;
  done
  # remove empty files
  find ${outputFolder} -type f -size 0 -exec rm {} \;
}

check_year_options () {
  runFunction=${1}
  if [[ ${fromYear} -ge 2017 ]]; then
    if [[ -z ${upToYear} ]]; then
      ${runFunction} ${fromYear}
    else
      while [[ ${fromYear} -le ${upToYear} ]]; do
        ${runFunction} ${fromYear}
        fromYear=$(( ${fromYear} + 1 ))
      done
    fi
  else
    echo "Wrong start year, for more info try: ${0} --help"
  fi
}

help_menu () {
  cat << EOF
  Usage: ${0} OPTION [START_YEAR] [END_YEAR]

  OPTIONS:
    -h | --help       Show this message
    -s | --sync       Synchronize data base with bwUniCluster
    -c | --calc       Sort synchronized data in ${dataFolder}
    -d | --debug      Debug sorted data

    START_YEAR        From what year to process data min. 2017, if omitted set to 2017
    END_YEAR          To what year to process data min. 2017, if omitted run only for FROM_YEAR

  EXAMPLES:
    Synchronize overall data with bwUniCluster from 2017 up to 2019
        $ ${0} -s 2017 2019

    Sort data from 2017 up to 2018
        $ ${0} -c 2017 2018

    Sort data for 2019
        $ ${0} -c 2019

    Debug sorted data for 2019
        $ ${0} -d 2019

EOF
}

case "${1}" in
  -h | --help)
    help_menu
  ;;
  -s | --sync)
    check_year_options sync_data
  ;;
  -c | --calc)
    check_year_options collect_data
  ;;
  -d | --debug)
    check_year_options debug
  ;;
  *)
    echo "Wrong operator, for more info try: ${0} --help"
  ;;
esac
