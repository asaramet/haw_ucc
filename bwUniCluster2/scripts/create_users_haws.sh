#!/usr/bin/env bash

# Create useres/YEAR/HAW components

TMP_FILE=${1}
[[ ! -f ${TMP_FILE} ]] && echo "Unexisting temp file provided!" && exit 1

MD="`dirname $(readlink -f ${0})`/.."
A_DIR="${MD}/src/app/users"

START_YEAR="2020"
YEAR=`date -d 'today' '+%Y'`

write_html()
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

write_component()
{
  haw=${1}
  declare -i year=${2}
  declare -i month=${3} # if month == 0 -> year component

  cat << EOF
import { Component, OnInit, ViewChild } from '@angular/core';
import { MatSort, MatTableDataSource } from '@angular/material';

import { DataObject } from '../../../_helpers/users.methods';
import { uniPrefixes } from '../../../_helpers/uni_prefixes';
EOF

  if [[ ${month} -eq "0" ]]; then
    cat << EOF
import { users_chart_opt } from '../../../_helpers/add_data';
import { udata_${year} } from '../../../_data/${year}';

const prefix:string = '${haw}'
const Data = new DataObject();

@Component({
  templateUrl: 'year.component.html'
})
export class ${haw^}${year}Component implements OnInit {
  private TABLE_DATA = Data.uniData(udata_${year}, prefix);

  public month:string = "";
EOF
  else
    cat << EOF
import { users_chart_opt, months } from '../../../_helpers/add_data';
import { udata_${year}_${month} } from '../../../_data/${year}';

const prefix:string = '${haw}'
const Data = new DataObject();

@Component({
  templateUrl: '${month}.component.html'
})
export class ${haw^}${year}${month}Component implements OnInit {
  private TABLE_DATA = Data.uniData(udata_${year}_${month}, prefix);

  public month:string = months[${month}];
EOF
  fi

  cat << EOF
  private chart_data:any[] = Data.getChartData(this.TABLE_DATA);

  public uni:string = uniPrefixes.find(element => {
    return element.prefix === prefix
  }).name;

  public title:string = "Unique users workload for ${year}:";

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

while [[ ${START_YEAR} -le ${YEAR} ]]; do
  OUTPUT_DIR="${A_DIR}/${START_YEAR}"
  echo "... Writing ${OUTPUT_DIR} haws"

  active_haws="" # save active haws this year

  while read -r line; do
    read -ra ADDR <<< ${line}
    if [[ ${ADDR[0]} -eq ${START_YEAR} ]]; then
      month=${ADDR[1]}
      haw=${ADDR[2]}

      out_folder="${OUTPUT_DIR}/${haw}"
      [[ ! -d ${out_folder} ]] && mkdir -p ${out_folder}

      write_html > "${out_folder}/${month}.component.html"
      write_component ${haw} ${START_YEAR} ${month} > "${out_folder}/${month}.component.ts"

      case ${active_haws} in
        *${haw}* ) # if prefix in active_haws leave it, don't modify
        ;;
        *)
          active_haws="${active_haws} ${haw}" # add haw to active_haws
      esac
    fi
  done < ${TMP_FILE}

  for haw in ${active_haws}; do
    out_folder="${OUTPUT_DIR}/${haw}"
    write_html > "${out_folder}/year.component.html"
    write_component ${haw} ${START_YEAR} > "${out_folder}/year.component.ts"
  done

  START_YEAR=$(( ${START_YEAR} + 1 ))
done
