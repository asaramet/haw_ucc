#!/usr/bin/env bash

# Crate YEARly: YEAR.component.* YEAR.module.ts YEAR.router.ts


MD="`dirname $(readlink -f ${0})`/.."
A_DIR=${MD}/src/app

START_YEAR="2019"
YEAR=`date -d 'today' '+%Y'`

write_html()
{
  cat << EOF
<div class="tab-month">
  <h1>{{title}} {{year}}</h1>
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

write_component()
{
  declare -i year=${1}
  [[ ${year} -eq 0 ]] && echo "missing YEAR to create component for." && exit 1

  cat << EOF
import { Component } from '@angular/core';
import { uca_${year}_total } from '../../_data/bwUniData_${year}';
import { pie_chart_opt } from '../../_helpers/add_data';
// get data
let data:any[] = [];
let annual:number = 0;
uca_${year}_total.forEach( (row:any) => {
  data.push([row.prefix, row.cost]);
  annual = annual + row.cost;
});
//calculate percentage
let percentage:any[] = [];
uca_${year}_total.forEach( (row:any) => {
  let pct:number = (row.cost * 100) / annual;
  percentage.push({
    prefix: row.prefix,
    pct: pct.toFixed(2)
  })
});

@Component({
  selector: 'data-${year}-annual',
  templateUrl: 'annual.component.html'
})
export class AnnualComponent {
  public year = ${year};
  public title = pie_chart_opt.titleAnnual;
  public haw_data = percentage;
  public cardHeader = pie_chart_opt.headerCard;
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

write_module()
{
  cat << EOF
import { NgModule } from '@angular/core';
import { CommonModule } from '@angular/common';
import { GoogleChartsModule } from 'angular-google-charts';
import { MatCardModule } from '@angular/material';
import { AnnualComponent } from './annual.component';
@NgModule({
  declarations: [ AnnualComponent ],
  imports: [
    CommonModule,
    MatCardModule,
    GoogleChartsModule ],
  exports: [ AnnualComponent ]
})
export class AnnualModule {}
EOF
}

while [[ ${START_YEAR} -le ${YEAR} ]]; do
  OUTPUT_DIR="${A_DIR}/${START_YEAR}/annual"
  echo "... Create ${OUTPUT_DIR}"

  [[ -d ${OUTPUT_DIR} ]] && rm ${OUTPUT_DIR}
  mkdir -p ${OUTPUT_DIR}

  write_html  > "${OUTPUT_DIR}/annual.component.html"
  write_component ${START_YEAR} > "${OUTPUT_DIR}/annual.component.ts"
  write_module > "${OUTPUT_DIR}/annual.module.ts"

  START_YEAR=$(( ${START_YEAR} + 1 ))
done
