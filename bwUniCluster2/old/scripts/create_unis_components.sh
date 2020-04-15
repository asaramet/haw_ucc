#!/usr/bin/env bash

MD=`dirname $(readlink -f $0)`
appFolder="${MD}/../src/app"
dataFolder="${MD}/ngData/components"

declare -i processedYear=2017
[[ ! -z ${1} ]] && declare -i year=${1}

declare -i fromMonth=1
[[ ! -z ${2} ]] && declare -i fromMonth=${2}
[[ ! -z ${3} ]] && declare -i upToMonth=${3}

generate () {
  year=${1}
  month=${2}
  outputFolder="${dataFolder}/${year}/${month}"
  if [[ ! -d ${appFolder}/${year}/${month} ]]; then
    echo "--- generating: ${outputFolder}..."
    [[ ! -d ${outputFolder} ]] && mkdir -p ${outputFolder}
    generate_html > ${outputFolder}/${month}.component.html
    generate_module ${month} > ${outputFolder}/${month}.module.ts
    generate_component ${year} ${month} > ${outputFolder}/${month}.component.ts
  fi
}

generate_component () {
  year=${1}
  month=${2}
  [[ '10 11 12' =~ (^|[[:space:]])${month}($|[[:space:]]) ]] &&
  ucaVariable="uca_${year}_${month}" || ucaVariable="uca_${year}_0${month}"
  cat << EOF
import { Component } from '@angular/core';

import { ${ucaVariable} } from '../../_data/bwUniData_${year}';
import { total_uca_${year} } from '../../_data/total';
import { months,
         pie_chart_opt
       } from '../../_helpers/add_data';

// get data
let data:any[] = [];
${ucaVariable}.forEach( (row) => {
  data.push([row.prefix, row.cost]);
});

@Component({
  selector: 'data-${year}-${month}',
  templateUrl: '${month}.component.html'
})
export class Month${month}Component {
  public year = ${year};
  public mnth:number = ${month};
  public haw_data = ${ucaVariable};

  public title = pie_chart_opt.title;
  public cardHeader = pie_chart_opt.headerCard;
  public month = months[this.mnth];
  public tcc_total = total_uca_${year}.find(item => item.year === this.year &&
    item.month === this.mnth)

  // Pie chart
  public type = 'PieChart';
  public data = data;
  public columnNames = pie_chart_opt.columnNames;
  public options = {
    pieHole: pie_chart_opt.pieHole,
    fontName: pie_chart_opt.fontName,
    fontSize: pie_chart_opt.fontSize,
    colors: pie_chart_opt.colors,
    legend: pie_chart_opt.legend
  };
   width = pie_chart_opt.width;
   height = pie_chart_opt.height;
}
EOF
}

generate_html () {
  cat << EOF
<div class="tab-month">
  <h1>{{title}} {{month}} {{year}} is - <b>{{tcc_total.haw}} %</b></h1>
  <div class='chart'>
    <mat-card class="chart-card">
      <mat-card-header>{{cardHeader}}</mat-card-header>
      <mat-card-content>
        <div *ngFor="let haw of haw_data">
          {{haw.prefix}} - {{haw.pct}} %
        </div>
      </mat-card-content>
    </mat-card>
    <google-chart #chart
      [type]="type"
      [data]="data"
      [columnNames]="columnNames"
      [options]="options"
      [width]="width"
      [height]="height">
    </google-chart>
  </div>
</div>
EOF
}

generate_module () {
  month=${1}
  cat << EOF
import { NgModule } from '@angular/core';
import { CommonModule } from '@angular/common';
import { GoogleChartsModule } from 'angular-google-charts';
import { MatCardModule } from '@angular/material';


import { Month${month}Component } from './${month}.component';
@NgModule({
  declarations: [ Month${month}Component ],
  imports: [
    CommonModule,
    MatCardModule,
    GoogleChartsModule ],
  exports: [ Month${month}Component ]
})
export class Month${month}Module {}
EOF
}

check_options () {
  runFunction=${1}
  if [[ ${fromMonth} -ge 1 && ${fromMonth} -le 12 ]]; then
    if [[ -z ${upToMonth} ]]; then
      ${runFunction} ${year} ${fromMonth}
    else
      while [[ ${fromMonth} -le ${upToMonth} ]]; do
        if [[ ${fromMonth} -ge 13 ]]; then
          echo "There are 12 months in a year!"
          break
        else
          ${runFunction} ${year} ${fromMonth}
          fromMonth=$(( ${fromMonth} + 1 ))
        fi
      done
    fi
  else
    echo "Wrong specified month, for more info try: ${0} --help"
  fi
}

move_files () {
  if [[ -d ${dataFolder} ]]; then
    echo "--- moving files from ${dataFolder} to ${appFolder}..."
    for folder in `ls ${dataFolder}`; do
      [[ ! -d ${appFolder}/${folder} ]] && mkdir ${appFolder}/${folder}
      mv ${dataFolder}/${folder}/* ${appFolder}/${folder}/
    done
    rm -rf ${dataFolder}
  fi
}

help_menu () {
  cat << EOF
  Usage: ${0} [YEAR] [START_MONTH] [END_MONTH]

  YEAR               Year to process
  START_MONTH        From what month to start generating components
  END_MONTH          To what month to continue generating, if omitted run only for FROM_MONTH

  OPTIONS:
    -h | --help         Show this message
    -m | --move         Move files to angular application folder

  EXAMPLES:
    Create data components for January, 2018
        $ ${0} 2018 1

    Create data components for January - December 2019:
        $ ${0} 2019 1 12

    Move created components to angular application folder: ${appFolder}
        $ ${0} --move
EOF
}

case "${1}" in
  -h | --help)
    help_menu
  ;;
  -m | --move)
    move_files
  ;;
  *)
    check_options generate
  ;;
esac
