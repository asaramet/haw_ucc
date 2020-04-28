#!/usr/bin/env bash

# Crate YEARly/MONTHs components : YEAR/MONTH.component.* YEAR/MONTH.module.ts


MD="`dirname $(readlink -f ${0})`/.."
A_DIR=${MD}/src/app

START_YEAR="2020"
YEAR=`date -d 'today' '+%Y'`

write_html()
{
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
      [columns]="columnNames"
      [options]="options"
      [width]="width"
      [height]="height">
    </google-chart>
  </div>
</div>
EOF
}

write_module()
{
  declare -i month=${1}
  [[ ${month} -eq 0 ]] && echo "missing MONTH to create module file for." && exit 1

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

write_component()
{
  declare -i year=${1}
  [[ ${year} -eq 0 ]] && echo "missing YEAR to create module file for." && exit 1
  declare -i month=${2}
  [[ ${month} -eq 0 ]] && echo "missing MONTH to create module file for." && exit 1
  month_str="${month}"
  [[ ${month} -lt 10 ]] && month_str="0${month}"

  cat << EOF
import { Component } from '@angular/core';
import { uca_${year}_${month_str} } from '../../_data/bwUniData_${year}';
import { total_uca_${year} } from '../../_data/total';
import { months,
         pie_chart_opt
       } from '../../_helpers/add_data';

// get data
let data:any[] = [];
uca_${year}_${month_str}.forEach( (row) => {
  data.push([row.prefix, row.cost]);
});

@Component({
  selector: 'data-${year}-${month}',
  templateUrl: '${month}.component.html'
})
export class Month${month}Component {
  public year = ${year};
  public mnth:number = ${month};
  public haw_data = uca_${year}_${month_str};

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

while [[ ${START_YEAR} -le ${YEAR} ]]; do
  OUTPUT_DIR="${A_DIR}/${START_YEAR}"
  echo "... Create ${OUTPUT_DIR} months"

  declare -i end_month=`date -d 'today' '+%m'`
  [[ ${START_YEAR} -lt ${YEAR} ]] && end_month="12"

  declare -i start_month="1"
  [[ ${START_YEAR} -eq "2020" ]] && declare -i start_month="3"

  while [[ ${start_month} -le  ${end_month} ]]; do
    month_folder="${OUTPUT_DIR}/${start_month}"
    [[ -d ${month_folder} ]] && rm -rf ${month_folder}
    mkdir -p ${month_folder}
    write_module ${start_month} > "${month_folder}/${start_month}.module.ts"
    write_html > "${month_folder}/${start_month}.component.html"
    write_component ${START_YEAR} ${start_month} > "${month_folder}/${start_month}.component.ts"
    start_month=$(( ${start_month} + 1 ))
  done
  START_YEAR=$(( ${START_YEAR} + 1 ))
done
