#!/usr/bin/env bash

# Build src/app/app.* files

MD="`dirname $(readlink -f ${0})`/.."
A_DIR="${MD}/src/app/top"

declare -i START_YEAR="${1}"
declare -i YEAR="${2}"

LABELS="single multiple multiple_e fat dev_single dev_multiple dev_multiple_e dev_special special gpu_4 dev_gpu_4 gpu_8"

html()
{
  declare -i year=${1}

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

  echo "</mat-tab-group>"
}

component()
{
  declare -i year=${1}
  cat << EOF
import { Component, OnInit } from '@angular/core';
import { ${LABELS// /,} } from '../../_data/${year}'

@Component({
  selector: 'top-${year}-root',
  templateUrl: './${year}.component.html'
})
export class Top${year}Component implements OnInit {
  constructor() {}

EOF

  for label in ${LABELS}; do
    echo "  public ${label}_data:boolean = false;"
  done

  echo -e "\n  ngOnInit () {"

  for label in ${LABELS}; do
    cat << EOF
    if ( ${label} === undefined || ${label}.length === 0 ) {
      this.${label}_data = true;
    };
EOF
  done

  echo -e "  }\n}"
}

module()
{
  declare -i year=${1}
  cat << EOF
import { NgModule } from '@angular/core';
import { CommonModule } from '@angular/common';
import { MatTabsModule } from '@angular/material/tabs';

EOF

  for label in ${LABELS}; do
    echo "import { ${label^}Module } from './${label}/${label}.module';"
  done

  cat << EOF
import { Top${year}RouterModule } from './${year}.router';
import { Top${year}Component } from './${year}.component';
@NgModule({
  imports: [
EOF

  for label in ${LABELS}; do
    echo "    ${label^}Module,"
  done

  cat << EOF
    Top${year}RouterModule,
    MatTabsModule,
    CommonModule
  ],
  declarations: [
    Top${year}Component,
  ],
})
export class Top${year}Module { }
EOF
}

router()
{
  declare -i year=${1}

  cat << EOF
import { NgModule } from '@angular/core';
import { Routes, RouterModule } from '@angular/router';

import { Top${year}Component } from './${year}.component';

const routes: Routes = [
  { path: '', component: Top${year}Component}
];
@NgModule({
  imports: [RouterModule.forChild(routes)],
  exports: [RouterModule]
})
export class Top${year}RouterModule {}
EOF
}

html_c()
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
  </div>
</div>
EOF
}

component_c()
{
  declare -i year=${1}
  queue=${2}

  cat << EOF
import { Component } from '@angular/core';
import { topOptions } from '../../../_helpers/configs';
import { ${queue} } from '../../../_data/top_${year}';

@Component({
  selector: '${queue}-${year}',
  templateUrl: '${queue}.component.html'
})
export class ${queue^}Component {
  public type = 'BubbleChart';
  public data = ${queue};

  public columnNames = ['Id', 'date', 'waiting time in seconds', 'user', 'number of CPU tasks'];

  public options = {
    title: "Top 5 users waiting time in the ${queue} queue scattered through ${year}",
    titleTextStyle: topOptions.titleTextStyle,
    sizeAxis: topOptions.sizeAxis,
    vAxis: topOptions.vAxis,
    hAxis: topOptions.hAxis
  };

  public width = topOptions.width;
  public height = topOptions.height;
}
EOF
}

module_c()
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
  out_folder="${A_DIR}/${START_YEAR}"
  [[ -d ${out_folder} ]] && rm -rf ${out_folder}
  mkdir -p ${out_folder}

  router ${START_YEAR} > "${out_folder}/${START_YEAR}.router.ts"
  module ${START_YEAR} > "${out_folder}/${START_YEAR}.module.ts"
  component ${START_YEAR} > "${out_folder}/${START_YEAR}.component.ts"
  html ${START_YEAR} > "${out_folder}/${START_YEAR}.component.html"

  for label in ${LABELS}; do
    folder_c="${out_folder}/${label}"
    [[ -d ${folder_c} ]] && rm -rf ${folder_c}
    mkdir -p ${folder_c}

    html_c > "${folder_c}/${label}.component.html"
    component_c ${START_YEAR} ${label} > "${folder_c}/${label}.component.ts"
    module_c ${label} > "${folder_c}/${label}.module.ts"
  done

  START_YEAR=$(( ${START_YEAR} + 1 ))
done
