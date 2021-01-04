#!/usr/bin/env bash

# Create src/app/users folder for HAW with prefix PREFIX using generated TMP_FILE
PREFIX=${1}
[[ -z ${PREFIX} ]] && echo "ERROR: HAW prefix not specified" && exit 1

TMP_FILE=${2}
[[ -z ${TMP_FILE} ]] && echo "ERROR: data file not provided" && exit 1
[[ ! -f ${TMP_FILE} ]] && echo "ERROR: Corupted provided ${TMP_FILE}" && exit 1

MD=`dirname $(readlink -f $0)`
A_DIR="${MD}/../src/app/users"

MONTHS='1:Jan 2:Feb 3:Mar 4:Apr 5:May 6:Jun 7:Jul 8:Aug 6:Sep 10:Oct 11:Nov 12:Dec'

[[ -d ${A_DIR} ]] && rm -rf ${A_DIR}
mkdir -p ${A_DIR}

declare -i START_YEAR="2020"
declare -i END_YEAR=`date -d 'yesterday' '+%Y'`

write_main_html()
{
  declare -i year=${1}
  cat << EOF
<h1 style="margin-top: 40px;">Unique "{{uniName}}" users in ${year}</h1>
<div class="users-pro-uni-table">
<table mat-table [dataSource]="dataSource" matSort>

  <ng-container matColumnDef="month" sticky>
    <th mat-header-cell *matHeaderCellDef> Month </th>
    <td mat-cell *matCellDef="let element">{{monthsDict[element.month]}}
    </td>
  </ng-container>

  <ng-container matColumnDef="users">
    <th mat-header-cell *matHeaderCellDef> Users </th>
    <td mat-cell *matCellDef="let element">
      <button mat-button color="accent" class="users-table-btn"
        *ngIf="element.users !== 0" [routerLink]="prefix + '/' + element.month">
        {{element.users}}
      </button>
      <p *ngIf="element.users === 0" class="users-table-text">0</p>
    </td>
  </ng-container>

  <tr mat-header-row *matHeaderRowDef="displayedColums; sticky: true"></tr>
  <tr mat-row *matRowDef="let row; columns: displayedColums"></tr>
</table></div>
EOF
}

write_main_component()
{
  declare -i year=${1}

  last_month="12"
  echo `date -d 'yesterday' '+%m'`
  [[ ${year} -eq ${END_YEAR} ]] && last_month=`date -d 'yesterday' '+%m'`

  last_month="${last_month#'0'}" # remove '0' prefix

  declare -i month="1"
  [[ ${year} -eq "2020" ]] && declare -i month="3"

  cat << EOF
import { Component, OnInit, ViewChild } from '@angular/core';
import { MatSort, MatTableDataSource } from '@angular/material';

import { DataObject, SortedUniUsers } from '../../_helpers/users.methods';
import { monthsDict } from '../../_helpers/add_data';
import { uniPrefixes } from '../../_helpers/uni_prefixes';
import * as db from '../../_data/${year}';

const monthlyData = [
EOF

  while [[ ${month} -le ${last_month} ]]; do
    echo -e "  { month: ${month}, data: db.udata_${year}_${month} },"
    month=$(( ${month} + 1 ))
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

  public prefix = '${PREFIX}';

  public uniName:string = uniPrefixes.find( obj => {
    return obj.prefix === this.prefix
  }).name

  private TABLE_DATA = Data.sortedYearlyUsers(monthlyData)[this.prefix];

  public monthsDict = monthsDict;

  public displayedColums:string[] = ['month', 'users']
  public dataSource: MatTableDataSource<SortedUniUsers> =
    new MatTableDataSource(this.TABLE_DATA);

  @ViewChild(MatSort, {static:true}) sort: MatSort;

  ngOnInit () {
    this.dataSource.sort = this.sort;
  }
}
EOF
}

write_router_module()
{
  declare -i year=${1}
  out_folder=${2}

  module_file="${out_folder}/${year}.module.ts"
  router_file="${out_folder}/${year}.router.ts"

  cat > ${module_file} << EOF
import { NgModule } from '@angular/core';
import { CommonModule } from '@angular/common';
import { MatTableModule } from '@angular/material';
import { MatSortModule } from '@angular/material/sort';
import { MatButtonModule } from '@angular/material/button';
import { GoogleChartsModule } from 'angular-google-charts';

import { Users${year}RouterModule } from './${year}.router';
import { Users${year}Component } from './${year}.component';
import { ${PREFIX^}${year}Component } from './${PREFIX}/year.component';
EOF

  cat > ${router_file} << EOF
import { NgModule } from '@angular/core';
import { Routes, RouterModule } from '@angular/router';

import { Users${year}Component } from './${year}.component';
import { ${PREFIX^}${year}Component } from './${PREFIX}/year.component';
EOF

  components=""
  while read -r line; do
    read -ra ADDR <<< ${line}
    if [[ ${ADDR[0]} -eq ${year} && ${ADDR[2]} == ${PREFIX} ]]; then
      month=${ADDR[1]}
      comp="${PREFIX^}${year}${month}Component"
      components="${components} ${comp}"
      echo "import { ${comp} } from './${PREFIX}/${month}.component';" | tee -a ${router_file} >> ${module_file}
    fi
  done < ${TMP_FILE}

  cat >> ${module_file} << EOF

@NgModule({
  imports: [
    Users${year}RouterModule,
    MatTableModule, MatSortModule,
    MatButtonModule, GoogleChartsModule,
    CommonModule
  ],
  declarations: [
    ${PREFIX^}${year}Component,
EOF
  cat >> ${router_file} << EOF

const routes: Routes = [
  { path: '${PREFIX}/Year', component: ${PREFIX^}${year}Component},
EOF

  for comp in ${components}; do
    echo -e "    ${comp}," >> ${module_file}

    month=${comp%Component}
    month=${month:6}

    for combo in ${MONTHS}; do
      IFS=":" read -ra ADDR <<< ${combo}
      [[ ${ADDR[0]} -eq ${month} ]] &&
      echo -e "  { path: '${PREFIX}/${ADDR[1]}', component: ${comp}}," >> ${router_file}
    done
  done

  cat >> ${module_file} << EOF
    Users${year}Component
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

write_haw_html()
{
  cat << EOF
<h1>{{uni}}. {{title}} {{month}}</h1>

<div style="justify-content:center">

<div class="pct-table">
  <div class="users-table">
    <table mat-table [dataSource]="dataSource" matSort>

    <ng-container matColumnDef="userID">
      <th mat-header-cell *matHeaderCellDef mat-sort-header>User ID</th>
      <td mat-cell *matCellDef="let element">{{element.userID}}</td>
    </ng-container>

    <ng-container matColumnDef="email">
      <th mat-header-cell *matHeaderCellDef mat-sort-header>Email</th>
      <td mat-cell *matCellDef="let element">{{element.email}}</td>
    </ng-container>

    <ng-container matColumnDef="pcts">
      <th mat-header-cell *matHeaderCellDef mat-sort-header>Pct</th>
      <td mat-cell *matCellDef="let element">{{element.pcts}} %</td>
    </ng-container>

    <tr mat-header-row *matHeaderRowDef="displayedColums; sticky: true"></tr>
    <tr mat-row *matRowDef="let row; columns: displayedColums"></tr>
    </table>
  </div>

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

write_haw_component()
{
  declare -i year=${1}
  declare -i month=${2} # flag to know if it's month or year (no option) component

  cat << EOF
import { Component, OnInit, ViewChild } from '@angular/core';
import { MatSort, MatTableDataSource } from '@angular/material';

import { DataObject } from '../../../_helpers/users.methods';
import { uniPrefixes } from '../../../_helpers/uni_prefixes';
EOF

  [[ ${month} -eq "0" ]] &&
  echo "import { udata_${year} } from '../../../_data/${year}';"  &&
  echo "import { users_chart_opt } from '../../../_helpers/add_data';"

  [[ ${month} -gt "0" ]] &&
  echo "import { udata_${year}_${month} } from '../../../_data/${year}';"  &&
  echo "import { users_chart_opt, months } from '../../../_helpers/add_data';"

  cat << EOF
const prefix:string = '${PREFIX}'
const Data = new DataObject();

@Component({
EOF

  [[ ${month} -eq "0" ]] &&
  cat << EOF
  templateUrl: 'year.component.html'
})
export class ${PREFIX^}${year}Component implements OnInit {
  private TABLE_DATA = Data.uniData(udata_${year}, prefix);
  public month:string = "";
EOF

  [[ ${month} -gt "0" ]] &&
  cat << EOF
  templateUrl: '${month}.component.html'
})
export class ${PREFIX^}${year}${month}Component implements OnInit {
  private TABLE_DATA = Data.uniData(udata_${year}_${month}, prefix);
  public month:string = months[${month}];
EOF

  cat << EOF
  public title:string = "Unique users workload for ${year}:";
  private chart_data:any[] = Data.getChartData(this.TABLE_DATA);

  public uni:string = uniPrefixes.find(element => {
    return element.prefix === prefix
  }).name;


  public displayedColums:string[] = ['userID', 'email', 'pcts'];
  public dataSource = new MatTableDataSource(this.TABLE_DATA);

  // Pie chart
  public type = 'PieChart';
  public data = this.chart_data;
  public columnNames = users_chart_opt.columnNames;
  public options = users_chart_opt.options;
  public width = users_chart_opt.width;
  public height = users_chart_opt.height;

  @ViewChild(MatSort, {static:true}) sort : MatSort;

  ngOnInit () {
    this.dataSource.sort = this.sort;
  }
}
EOF
}

while [[ ${START_YEAR} -le ${END_YEAR} ]]; do
  out_folder="${A_DIR}/${START_YEAR}"
  [[ -d ${out_folder} ]] && rm -rf ${out_folder}
  mkdir -p ${out_folder}

  write_main_html ${START_YEAR} > "${out_folder}/${START_YEAR}.component.html"
  write_main_component ${START_YEAR} > "${out_folder}/${START_YEAR}.component.ts"
  write_router_module ${START_YEAR} ${out_folder}

  haw_folder="${out_folder}/${PREFIX}"
  [[ ! -d ${haw_folder} ]] && mkdir -p ${haw_folder}

  while read -r line; do
    read -ra ADDR <<< ${line}
    if [[ ${ADDR[0]} -eq ${START_YEAR} && ${ADDR[2]} == ${PREFIX} ]]; then

      declare -i month=${ADDR[1]}
      write_haw_html > "${haw_folder}/${month}.component.html"
      write_haw_component ${START_YEAR} ${month} > "${haw_folder}/${month}.component.ts"
    fi
  done < ${TMP_FILE}

  write_haw_html > "${haw_folder}/year.component.html" &&
  write_haw_component ${START_YEAR} > "${haw_folder}/year.component.ts"

  START_YEAR=$(( ${START_YEAR} + 1 ))
done
