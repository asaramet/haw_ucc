#!/usr/bin/env bash

MD="`dirname $(readlink -f ${0})`/.."
A_DIR=${MD}/src/app

START_YEAR=${1}
YEAR=${2}

LABELS="single multiple multiple_e fat dev_single dev_multiple dev_multiple_e dev_special special gpu_4 gpu_8"

html()
{
  year=${1}
  echo '<mat-tab-group mat-align-tabs="end">'

  for label in ${LABELS}; do
  cat << EOF
  <mat-tab label="${label}" [disabled]="(${label}_data)">
    <ng-template matTabContent>
      <${label}-${year}></${label}-${year}>
    </ng-template>
  </mat-tab>
EOF
  done

  echo '</mat-tab-group>'
}

component()
{
  year=${1}
  cat << EOF
import { Component, OnInit } from '@angular/core';
import { ${LABELS// /,} } from '../_data/${year}'

@Component({
  selector: 'year-${year}-root',
  templateUrl: './${year}.component.html'
})
export class Year${year}Component implements OnInit{
  constructor () {}

EOF

  for queue in ${LABELS}; do
    echo "  public ${queue}_data:boolean = false;"
  done

  echo "  ngOnInit() {"

  for queue in ${LABELS}; do
    cat << EOF
    if ( ${queue} === undefined || ${queue}.length === 0 ) {
      this.${queue}_data = true;
    };
EOF
  done

  echo -e "  }\n}\n"
}

router()
{
  year=${1}
  cat << EOF
import { NgModule } from '@angular/core';
import { Routes, RouterModule } from '@angular/router';
import { Year${year}Component } from './${year}.component';
const routes: Routes = [
  { path: '', component: Year${year}Component }
];
@NgModule({
  imports: [RouterModule.forChild(routes)],
  exports: [RouterModule]
})
export class Year${year}RouterModule {}
EOF
}

module()
{
  year=${1}
  cat << EOF
import { NgModule } from '@angular/core';
import { CommonModule } from '@angular/common';
import { MatTabsModule } from '@angular/material/tabs';
import { Year${year}Component } from './${year}.component';
import { Year${year}RouterModule } from './${year}.router';
EOF

  for label in ${LABELS}; do
    echo "import { ${label^}Module } from './${label}/${label}.module';"
  done

  cat << EOF
@NgModule({
  imports: [
EOF

  for label in ${LABELS}; do
    echo "    ${label^}Module,"
  done

  cat << EOF
    Year${year}RouterModule,
    MatTabsModule,
    CommonModule
  ],
  declarations: [ Year${year}Component ],
})
export class Year${year}Module { }
EOF
}

html_q()
{
  cat << EOF
<div class="tab-month">
  <div class='chart'>
    <google-chart
      [type]="type"
      [data]="data"
      [columns]="columnNames"
      [options]="options"
      [width]="width"
      [height]="height">
    </google-chart>
    <p>CPU Tasks</p>
  </div>
</div>
EOF
}

component_q()
{
  year=${1}
  queue=${2}

  cat << EOF
import { Component } from '@angular/core';
import { options } from '../../_helpers/configs';
import { ${queue} } from '../../_data/${year}';

@Component({
  selector: '${queue}-${year}',
  templateUrl: '${queue}.component.html'
})
export class ${queue^}Component {
  public type = 'BubbleChart';
  public data = ${queue};

  public columnNames = ['Id', 'date', 'waiting time in seconds', 'number of CPU tasks'];

  public options = {
    title: "Waiting time in the ${queue} queue scattered through 2020",
    titleTextStyle: options.titleTextStyle,
    colorAxis: options.colorAxis,
    sizeAxis: options.sizeAxis,
    vAxis: options.vAxis,
    hAxis: options.hAxis
  };

  public width = options.width;
  public height = options.height;
}
EOF
}

module_q()
{
  queue=${1}

  cat << EOF
import { NgModule } from '@angular/core';
import { CommonModule } from '@angular/common';
import { GoogleChartsModule } from 'angular-google-charts';
import { MatCardModule } from '@angular/material/card';


import { ${queue^}Component } from './${queue}.component';
@NgModule({
  declarations: [ ${queue^}Component ],
  imports: [
    CommonModule,
    MatCardModule,
    GoogleChartsModule ],
  exports: [ ${queue^}Component ]
})
export class ${queue^}Module {}
EOF
}


while [[ ${START_YEAR} -le ${YEAR} ]]; do
  FOLDER="${A_DIR}/${START_YEAR}"
  [[ ! -d ${FOLDER} ]] && mkdir -p ${FOLDER}
  html ${START_YEAR} > "${FOLDER}/${START_YEAR}.component.html"
  component ${START_YEAR} > "${FOLDER}/${START_YEAR}.component.ts"
  router ${START_YEAR} > "${FOLDER}/${START_YEAR}.router.ts"
  module ${START_YEAR} > "${FOLDER}/${START_YEAR}.module.ts"

  for label in ${LABELS}; do
    FOLDER_Q="${FOLDER}/${label}"
    [[ ! -d ${FOLDER_Q} ]] && mkdir -p ${FOLDER_Q}
    html_q > "${FOLDER_Q}/${label}.component.html"
    component_q ${START_YEAR} ${label} > "${FOLDER_Q}/${label}.component.ts"
    module_q ${label} > "${FOLDER_Q}/${label}.module.ts"
  done

  START_YEAR=$(( ${START_YEAR} + 1 ))
done
