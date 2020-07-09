#!/usr/bin/env bash

# Build src/app/app.* files

MD="`dirname $(readlink -f ${0})`/.."
A_DIR="${MD}/src/app/top"

declare -i START_YEAR="${1}"
declare -i YEAR="${2}"

html()
{
  declare -i year=${1}
  cat << EOF
<h1>Unique HAW users in ${year}</h1>
EOF
}

component()
{
  declare -i year=${1}
  cat << EOF
import { Component, OnInit } from '@angular/core';

@Component({
  selector: 'top-${year}-root',
  templateUrl: './${year}.component.html'
})
export class Top${year}Component implements OnInit {
  constructor() {}

  ngOnInit () {
  }
}
EOF
}

module()
{
  declare -i year=${1}
  cat << EOF
import { NgModule } from '@angular/core';
import { CommonModule } from '@angular/common';
import { MatTableModule } from '@angular/material';
import { MatSortModule } from '@angular/material/sort';
import { MatButtonModule } from '@angular/material/button';
import { GoogleChartsModule } from 'angular-google-charts';

import { Top${year}RouterModule } from './${year}.router';
import { Top${year}Component } from './${year}.component';
@NgModule({
  imports: [
    Top${year}RouterModule,
    MatTableModule, MatSortModule,
    MatButtonModule, GoogleChartsModule,
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

while [[ ${START_YEAR} -le ${YEAR} ]]; do
  out_folder="${A_DIR}/${START_YEAR}"
  [[ -d ${out_folder} ]] && rm -rf ${out_folder}
  mkdir -p ${out_folder}

  router ${START_YEAR} > "${out_folder}/${START_YEAR}.router.ts"
  module ${START_YEAR} > "${out_folder}/${START_YEAR}.module.ts"
  component ${START_YEAR} > "${out_folder}/${START_YEAR}.component.ts"
  html ${START_YEAR} > "${out_folder}/${START_YEAR}.component.html"

  START_YEAR=$(( ${START_YEAR} + 1 ))
done
