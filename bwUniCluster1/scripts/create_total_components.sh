#!/usr/bin/env bash

MD=`dirname $(readlink -f $0)`
appFolder="${MD}/../src/app"

declare -i year=2017
[[ ! -z ${1} ]] && declare -i year=${1}

generate () {
  generate_annual ${year}
  generate_total ${year}
}
generate_annual () {
  year=${1}
  outputFolder=${appFolder}/${year}/annual
  [[ ! -d ${outputFolder} ]] && mkdir -p ${outputFolder};
  [[ ! -f ${outputFolder}/annual.component.html ]] &&
  generate_annual_html > ${outputFolder}/annual.component.html;
  [[ ! -f ${outputFolder}/annual.module.ts ]] &&
  generate_annual_module  > ${outputFolder}/annual.module.ts;
  [[ ! -f ${outputFolder}/annual.component.ts ]] &&
  generate_annual_component ${year} > ${outputFolder}/annual.component.ts
}

generate_annual_html () {
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
      [columns]="columnNames"
      [options]="options"
      [width]="width"
      [height]="height">
    </google-chart>
  </div>
</div>
EOF
}

generate_annual_module () {
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

generate_annual_component () {
  year=${1}
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

generate_total () {
  year=${1}
  outputFolder=${appFolder}/${year}/total
  [[ ! -d ${outputFolder} ]] && mkdir -p ${outputFolder};
  [[ ! -f ${outputFolder}/total.component.html ]] &&
  generate_total_html > ${outputFolder}/total.component.html;
  [[ ! -f ${outputFolder}/total.module.ts ]] &&
  generate_total_module  > ${outputFolder}/total.module.ts;
  [[ ! -f ${outputFolder}/total.component.ts ]] &&
  generate_total_component ${year} > ${outputFolder}/total.component.ts
}

generate_total_html () {
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

generate_total_module () {
  cat << EOF
import { NgModule } from '@angular/core';
import { CommonModule } from '@angular/common';
import { GoogleChartsModule } from 'angular-google-charts';
import { MatCardModule } from '@angular/material';
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

generate_total_component () {
  year=${1}
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

help_menu () {
  cat << EOF
  Usage: ${0} [YEAR]

  YEAR               Year to process

  OPTIONS:
    -h | --help         Show this message
    -m | --move         Move files to angular application folder

  EXAMPLES:
    Create data components 2018
        $ ${0} 2018

EOF
}

case "${1}" in
  -h | --help)
    help_menu
  ;;
  *)
    generate ${1}
  ;;
esac
