#!/usr/bin/env bash

MD=`dirname $(readlink -f $0)`
inputFolder="/www/faculty/it/bwHPC/SCRIPTS/haw"
outputFolder="${inputFolder}/../output"
ngDataFolder="${MD}/ngData/_data"
appFolder="${MD}/../src/app/_data"

prefixes='aa as es hf hk hn hr hs ht hu ro'

declare -i fromYear=2017
[[ ! -z ${1} ]] && declare -i fromYear=${1}

[[ ! -z ${2} ]] && declare -i upToYear=${2}

[[ ! -d ${outputFolder} ]] && mkdir -p ${outputFolder}

get_TotalCost () {
  # Get TotalCost value in a line
  cut_line=${1##*TotalCost=}
  echo ${cut_line%;*}
}

get_total_costs () {
  # Calculate total number of costs from a given file
  fileName=${1}
  totals=0
  while read -r line; do
    cost=`get_TotalCost ${line}`
    #echo "cost: $cost / totals: $totals"
    totals=$(echo $totals $cost | awk '{ printf "%f", $1 + $2 }')
  done < ${fileName}
  echo $totals
}

output_costs () {
  # For yearly output use: func -y year 'total' uni_prefix
  # For monthly output use: func -m year month
  # For monthly output per uni use -h year month uni_prefix
  year=${2}
  month=${3}
  uniPrefix=${4}

  case "${1}" in
    -m)
      get_total_costs ${inputFolder}/${year}/${month}.log 2> /dev/null
    ;;
    -h)
      get_total_costs ${inputFolder}/${uniPrefix}/${year}/${month}.log
    ;;
    -y)
      get_total_costs ${inputFolder}/${uniPrefix}/${year}/total.log
    ;;
  esac
}

gather_data () {
  year=${1}
  [[ ! -d ${outputFolder}/${year} ]] && mkdir -p ${outputFolder}/${year}
  [[ ! -d ${ngDataFolder} ]] && mkdir -p ${ngDataFolder}

  ngDataFile="${ngDataFolder}/bwUniData_${year}.ts"
  [[ -f ${ngDataFile} ]] && rm -f ${ngDataFile}

  for month in {01..12}; do
    echo "=== Gathering data for ${year}.${month} ==="
    outputFile=${outputFolder}/${year}/${month}
    echo "total..."
    totalPerMonth=0
    totalPerMonth=`output_costs -m ${year} ${month}`

    if (( $(echo "${totalPerMonth} > 0" | bc -l) )); then
      echo -e "Jobs cost pro month:\n" > ${outputFile}
      echo -e "prefix | percentage | TotalCost " >> ${outputFile}
      echo "export const uca_${year}_${month} = [" >> ${ngDataFile}
      totalCost=0
      for prefix in ${prefixes}; do
        echo "${prefix}..."
        cost=`output_costs -h ${year} ${month} ${prefix} 2> /dev/null`
        percentage=$(echo ${totalPerMonth} ${cost} | awk '{ printf "%.2f", ($2 * 100 ) / $1 }')
        echo "${prefix}       ${percentage}     ${cost}" >> ${outputFile}
        echo -e "  {prefix: '${prefix}', pct: ${percentage}, cost: ${cost}}," >> ${ngDataFile}
        totalCost=$(echo ${totalCost} ${cost} | awk '{ printf "%.0f", $1 + $2 }')
      done
      echo -e "\nTotal calculated: ${totalCost}" >> ${outputFile}
      echo -e "Total gathered:   ${totalPerMonth}" >> ${outputFile}
      echo -e "];\n" >> ${ngDataFile}
    fi
    echo "=== DONE! ==="
  done
  echo "=== Gathering total data for ${year}"
  echo "export const uca_${year}_total = [" >> ${ngDataFile}
  for prefix in ${prefixes}; do
    echo "${prefix}..."
    cost=`output_costs -y ${year} 'total' ${prefix} 2> /dev/null`
    echo -e "  {prefix: '${prefix}', cost: ${cost}}," >> ${ngDataFile}
  done
  echo -e "];\n" >> ${ngDataFile}
}

move_files () {
  [[ ! -d ${appFolder} ]] && mkdir -p ${appFolder}
  mv ${ngDataFolder}/* ${appFolder} -v && rm -rf ${ngDataFolder}
}

help_menu () {
  cat << EOF
  Gather "TotalCost" data from feedback files.

  Usage: ${0} [START_YEAR] [END_YEAR]

  START_YEAR         From what year to process data min. 2017, if omitted set to 2017
  END_YEAR           To what year to process data min. 2017, if omitted run only for FROM_YEAR

  OPTIONS:
    -h | --help         Show this message
    -m | --move         Move files from ${ngDataFolder} to ${appFolder}

  EXAMPLES:
    Gather data for 2018
        $ ${0} 2018

    Gather data from 2017 till 2019:
        $ ${0} 2017 2019

    Move data from ${ngDataFolder} to ${appFolder}
        $ ${0} -m
EOF
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

case "${1}" in
  -h | --help)
    help_menu
  ;;
  -m | --move)
    move_files
  ;;
  *)
    check_year_options gather_data
  ;;
esac
