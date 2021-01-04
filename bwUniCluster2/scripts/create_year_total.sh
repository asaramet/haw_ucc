#!/usr/bin/env bash

# Crate YEARly: YEAR.component.* YEAR.module.ts YEAR.router.ts

MD="`dirname $(readlink -f ${0})`/.."
A_DIR=${MD}/src/app

START_YEAR="2020"
YEAR=`date -d 'yesterday' '+%Y'`

write_html()
{
  cat << EOF
<div class="tab-month">
  <h1>
    {{title}} {{year}}
  </h1>
  <div class='chart'>
    <mat-card class="chart-card">
      <mat-card-header>{{cardHeader}}</mat-card-header>
      <mat-card-content>
        <div *ngFor="let month of data">
          {{month[0]}} - {{month[1]}} %
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

write_component()
{
  declare -i year=${1}
  [[ ${year} -eq 0 ]] && echo "missing YEAR to create component for." && exit 1

  cat << EOF
import { Component } from '@angular/core';
import { total_uca_${year} } from '../../_data/total';

import { months, total_opt } from '../../_helpers/add_data';

// get data
let data:any[] = [];
total_uca_${year}.forEach( (row:any) => {
  data.push([months[row.month], row.haw]);
});

@Component({
  selector: 'data-${year}-total',
  templateUrl: 'total.component.html'
})
export class TotalComponent {
  public year = ${year};
  public title = total_opt.titile;
  public cardHeader = total_opt.headerCard;

  // Area chart
  public type = 'AreaChart';
  public data = data;
  public columnNames = total_opt.columnNames;
  public options = {
    colors: total_opt.colors,
    vAxis: {
      ticks: [1.25, 2.5, 3.75, 5],
      textStyle: {
        fontName: total_opt.fontName,
        fontSize: total_opt.fontSize
      }
    },
    hAxis: {
      textPosition: 'out',
      textStyle: {
        fontName: total_opt.fontName,
        fontSize: total_opt.fontSize
      },
      slantedText: true
    },
    legend: {
      textStyle: {
        fontName: total_opt.fontName,
        fontSize: total_opt.fontSize
      },
      position: "top"
    }
  };
   width = total_opt.chartWidth;
   height = total_opt.chartHeight
}
EOF
}

write_module()
{
  cat << EOF
import { NgModule } from '@angular/core';
import { CommonModule } from '@angular/common';
import { GoogleChartsModule } from 'angular-google-charts';
import { MatCardModule } from '@angular/material/card';
import { TotalComponent } from './total.component';
@NgModule({
  declarations: [ TotalComponent ],
  imports: [
    CommonModule,
    MatCardModule,
    GoogleChartsModule ],
  exports: [ TotalComponent ]
})
export class TotalModule {}
EOF
}

while [[ ${START_YEAR} -le ${YEAR} ]]; do
  OUTPUT_DIR="${A_DIR}/${START_YEAR}/total"
  echo "... Create ${OUTPUT_DIR}"

  [[ -d ${OUTPUT_DIR} ]] && rm ${OUTPUT_DIR}
  mkdir -p ${OUTPUT_DIR}

  write_html > "${OUTPUT_DIR}/total.component.html"
  write_component ${START_YEAR} > "${OUTPUT_DIR}/total.component.ts"
  write_module > "${OUTPUT_DIR}/total.module.ts"

  START_YEAR=$(( ${START_YEAR} + 1 ))
done
