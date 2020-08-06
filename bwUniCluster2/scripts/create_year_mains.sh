#!/usr/bin/env bash

# Crate YEARly: YEAR.component.* YEAR.module.ts YEAR.router.ts

MD="`dirname $(readlink -f ${0})`/.."
A_DIR=${MD}/src/app

START_YEAR="2020"
YEAR=`date -d 'yesterday' '+%Y'`

write_html()
{
  year=${1}
  [[ ${year} -eq 0 ]] && echo "missing YEAR to create html for." && exit 1

  end_month=${2}
  [[ -z ${end_month} ]] && echo "missing END MONTH to create html for." && exit 1

  declare -i start_month="1"
  [[ ${year} == "2020" ]] && declare -i start_month="3"

  cat << EOF
<mat-tab-group mat-align-tabs="end">
  <mat-tab label="total">
    <ng-template matTabContent>
      <data-${year}-total></data-${year}-total>
    </ng-template>
  </mat-tab>
  <mat-tab label="annual">
    <ng-template matTabContent>
      <data-${year}-annual></data-${year}-annual>
    </ng-template>
  </mat-tab>
EOF

  while [[ ${start_month} -le ${end_month} ]]; do
    cat << EOF
  <mat-tab label="${start_month}">
    <ng-template matTabContent>
      <data-${year}-${start_month}></data-${year}-${start_month}>
    </ng-template>
  </mat-tab>
EOF
    start_month=$(( ${start_month} + 1 ))
  done

  echo -e "</mat-tab-group>\n<unis-root></unis-root>"
}

write_component()
{
  declare -i year=${1}
  [[ ${year} -eq 0 ]] && echo "missing YEAR to create component for." && exit 1

  cat << EOF
import { Component } from '@angular/core';
@Component({
  selector: 'year-${year}-root',
  templateUrl: './${year}.component.html'
})
export class Year${year}Component {
  constructor () {}
}
EOF
}

write_router()
{
  declare -i year=${1}
  [[ ${year} -eq 0 ]] && echo "missing YEAR to create router for." && exit 1

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

write_module()
{
  declare -i year=${1}
  [[ ${year} -eq 0 ]] && echo "missing YEAR to create module for." && exit 1

  end_month=${2}
  [[ -z ${end_month} ]] && echo "missing END MONTH to create module for." && exit 1

  declare -i start_month="1"
  [[ ${year} == "2020" ]] && declare -i start_month="3"

  cat << EOF
import { NgModule } from '@angular/core';
import { CommonModule } from '@angular/common';
import { MatTabsModule } from '@angular/material';
import { Year${year}Component } from './${year}.component';
import { Year${year}RouterModule } from './${year}.router';
import { UnisModule } from '../unis/unis.module';
import { TotalModule } from './total/total.module';
import { AnnualModule } from './annual/annual.module';
EOF

  while [[ ${start_month} -le ${end_month} ]]; do
    echo "import { Month${start_month}Module } from './${start_month}/${start_month}.module';"
    start_month=$(( ${start_month} + 1 ))
  done

  cat << EOF
@NgModule({
  imports: [
    AnnualModule,
    TotalModule,
EOF

  declare -i start_month="1"
  [[ ${year} == "2020" ]] && declare -i start_month="3"

  while [[ ${start_month} -le ${end_month} ]]; do
    echo "    Month${start_month}Module,"
    start_month=$(( ${start_month} + 1 ))
  done

  cat << EOF
    UnisModule,
    Year${year}RouterModule,
    MatTabsModule,
    CommonModule
  ],
  declarations: [ Year${year}Component ],
})
export class Year${year}Module { }
EOF
}

while [[ ${START_YEAR} -le ${YEAR} ]]; do
  OUTPUT_DIR="${A_DIR}/${START_YEAR}"
  echo "... Create ${OUTPUT_DIR} mains"
  [[ -d ${OUTPUT_DIR} ]] && rm -rf ${OUTPUT_DIR}
  mkdir -p ${OUTPUT_DIR}

  write_component ${START_YEAR} > "${OUTPUT_DIR}/${START_YEAR}.component.ts"
  write_router ${START_YEAR} > "${OUTPUT_DIR}/${START_YEAR}.router.ts"

  END_MONTH=`date -d 'yesterday' '+%m'`
  [[ ${END_MONTH} == "08" ]] && END_MONTH="8"
  
  [[ ${START_YEAR} -lt ${YEAR} ]] && END_MONTH="12"

  write_html ${START_YEAR} ${END_MONTH} > "${OUTPUT_DIR}/${START_YEAR}.component.html"
  write_module ${START_YEAR} ${END_MONTH} > "${OUTPUT_DIR}/${START_YEAR}.module.ts"

  START_YEAR=$(( ${START_YEAR} + 1 ))
done
