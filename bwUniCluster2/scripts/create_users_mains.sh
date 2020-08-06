#!/usr/bin/env bash

# Create users/YEAR: YEAR.component.* YEAR.module.ts YEAR.router.ts

TMP_FILE=${1}
[[ ! -f ${TMP_FILE} ]] && echo "Unexisting temp file provided!" && exit 1

MD="`dirname $(readlink -f ${0})`/.."
A_DIR="${MD}/src/app/users"

[[ -d ${A_DIR} ]] && rm -rf ${A_DIR}
mkdir -p ${A_DIR}

START_YEAR="2020"
YEAR=`date -d 'yesterday' '+%Y'`

MONTHS='1:Jan 2:Feb 3:Mar 4:Apr 5:May 6:Jun 7:Jul 8:Aug 9:Sep 10:Oct 11:Nov 12:Dec'

write_module_rooter()
{
  declare -i year=${1}
  [[ ${year} -lt ${START_YEAR} ]] && echo "Wrong YEAR specified to write module ts" && exit 1

  module_file="${A_DIR}/${year}/${year}.module.ts"
  router_file="${A_DIR}/${year}/${year}.router.ts"

  cat > ${module_file} << EOF
import { NgModule } from '@angular/core';
import { CommonModule } from '@angular/common';
import { MatTableModule } from '@angular/material';
import { MatSortModule } from '@angular/material/sort';
import { MatButtonModule } from '@angular/material/button';
import { GoogleChartsModule } from 'angular-google-charts';

import { Users${year}RouterModule } from './${year}.router';
import { Users${year}Component } from './${year}.component';
EOF

  cat > ${router_file} << EOF
import { NgModule } from '@angular/core';
import { Routes, RouterModule } from '@angular/router';

import { Users${year}Component } from './${year}.component';
EOF

  components="" # collect components to write them in declarations
  active_haws="" # active haw this year to add yearly component
  while read -r line; do
    read -ra ADDR <<< ${line}
    if [[ ${ADDR[0]} -eq ${year} ]]; then
      month=${ADDR[1]}
      prefix=${ADDR[2]}
      cmp="${prefix^}${year}${month}Component"
      components="${components} ${cmp}"
      echo "import { ${cmp} } from './${prefix}/${month}.component';" | tee -a ${router_file} >> ${module_file}
      case ${active_haws} in
        *${prefix}* ) # if prefix in active_haws leave it, don't modify
        ;;
        *)
          active_haws="${active_haws} ${prefix}"
      esac
    fi
  done < ${TMP_FILE}

  for prefix in ${active_haws}; do
    cmp="${prefix^}${year}Component"
    components="${components} ${cmp}"
    echo "import { ${cmp} } from './${prefix}/year.component';" | tee -a ${router_file} >> ${module_file}
  done

  cat >> ${module_file} << EOF
@NgModule({
  imports: [
    Users${year}RouterModule,
    MatTableModule, MatSortModule,
    MatButtonModule, GoogleChartsModule,
    CommonModule
  ],
  declarations: [
EOF

  echo "const routes: Routes = [" >> ${router_file}

  for comp in ${components}; do
    echo "    ${comp}," >> ${module_file}

    # write rooter.ts
    prefix=${comp:0:2} # first 2 letters. Ex Aa
    prefix=${prefix,,} # convert all to lowercase
    month=${comp%Component} # cut suffix Component
    month=${month:6} # cut prefix. Ex: Aa2020

    # if it's an year component month will be ''
    [[ -z ${month} ]] &&
    echo "  { path: '${prefix}/Year', component: ${comp}}," >> ${router_file} && continue

    for combo in ${MONTHS}; do
      IFS=":" read -ra ADDR <<< ${combo}
      [[ ${ADDR[0]} -eq ${month} ]] &&
      echo "  { path: '${prefix}/${ADDR[1]}', component: ${comp}}," >> ${router_file} && continue
    done
  done

  cat >> ${module_file} << EOF
    Users${year}Component,
  ],
})
export class Users${year}Module { }
EOF

  cat >> ${router_file} << EOF
  { path: '', component: Users${year}Component}
];
@NgModule({
  imports: [RouterModule.forChild(routes)],
  exports: [RouterModule]
})
export class Users${year}RouterModule {}
EOF
}

write_component()
{
  declare -i year=${1}
  end_month=${2}

  declare -i start_month="1"
  [[ ${year} -eq "2020" ]] && declare -i start_month="3"

  cat << EOF
import { Component, OnInit, ViewChild } from '@angular/core';
import { MatSort, MatTableDataSource } from '@angular/material';

import { DataObject, YearlyUniUsers } from '../../_helpers/users.methods';
import * as db from '../../_data/${year}';

const monthlyData = [
EOF

  while [[ ${start_month} -le ${end_month} ]]; do
    echo "  { month: ${start_month}, data: db.udata_${year}_${start_month} },"
    start_month=$(( ${start_month} + 1 ))
  done

  cat << EOF
  { month: -1, data: db.udata_${year} }
];

const Data = new DataObject();

@Component({
  selector: 'users-${year}-root',
  templateUrl: './${year}.component.html'
})
export class Users${year}Component implements OnInit {
  constructor() {}

  private TABLE_DATA = Data.yearlyUsers(monthlyData);

  public months:string[] = [
EOF

  declare -i start_month="1"
  [[ ${year} -eq "2020" ]] && declare -i start_month="3"

  month_str=""
  while [[ ${start_month} -le ${end_month} ]]; do
    for month in ${MONTHS}; do
      IFS=":" read -ra ADDR <<< ${month}
      if [[ ${ADDR[0]} -eq ${start_month} ]]; then
        month_str="${month_str}'${ADDR[1]}', "
      fi
    done
    start_month=$(( ${start_month} + 1 ))
  done
  month_str="${month_str}'Year'"

  echo "    ${month_str}"

  cat << EOF
  ];

  public displayedColums:string[] = ['name'].concat(this.months);
  public dataSource: MatTableDataSource<YearlyUniUsers> =
    new MatTableDataSource(this.TABLE_DATA);

  @ViewChild(MatSort, {static:true}) sort: MatSort;

  ngOnInit () {
    this.dataSource.sort = this.sort;
  }
}
EOF
}

write_html()
{
  year=${1}

  cat << EOF
<h1>Unique HAW users in ${year}</h1>
<div class="users-table">
<table mat-table [dataSource]="dataSource" matSort>

  <ng-container matColumnDef="name" sticky>
    <th mat-header-cell *matHeaderCellDef mat-sort-header> University name </th>
    <td mat-cell *matCellDef="let element">{{element.name}}
    </td>
  </ng-container>
  <div *ngFor="let month of months">
    <ng-container [matColumnDef]="month">
      <th mat-header-cell *matHeaderCellDef mat-sort-header>{{month}}</th>
      <td mat-cell *matCellDef="let element">
        <button mat-button color="accent" class="users-table-btn"
          *ngIf="element[month] !== 0" [routerLink]="element.prefix + '/' + month">
          {{element[month]}}
        </button>
        <p *ngIf="element[month] === 0" class="users-table-text">0</p>
      </td>
    </ng-container>
  </div>

  <tr mat-header-row *matHeaderRowDef="displayedColums; sticky: true"></tr>
  <tr mat-row *matRowDef="let row; columns: displayedColums"></tr>
</table></div>
EOF
}

while [[ ${START_YEAR} -le ${YEAR} ]]; do
  out_folder="${A_DIR}/${START_YEAR}"
  mkdir -p ${out_folder}

  echo "... Writing ${out_folder} mains"
  write_html ${START_YEAR} > "${out_folder}/${START_YEAR}.component.html"
  write_module_rooter ${START_YEAR}

  END_MONTH="12"
  [[ ${START_YEAR} -eq ${YEAR} ]] && END_MONTH=`date -d 'yesterday' '+%m'`
  [[ ${END_MONTH} == "08" ]] && END_MONTH="8"
  write_component ${START_YEAR} ${END_MONTH} > "${out_folder}/${START_YEAR}.component.ts"

  START_YEAR=$(( ${START_YEAR} + 1 ))
done
