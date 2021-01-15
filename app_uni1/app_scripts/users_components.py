#!/usr/bin/env python3

import os, sys, getopt
from string import Template

dir_path = os.path.dirname(os.path.realpath(__file__))
appFolder = os.path.join(dir_path, "..")
hawPrefixes = ['aa', 'as', 'es', 'hf', 'hk', 'hn', 'hr', 'hs', 'ht', 'hu', 'ro']

def createHTML(year):
  textTempl = Template('''
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
''')
  return textTempl.substitute(year=year)

def createTS(uniPrefix, year, month, start_month=1):
  dataDictStr = '['
  objTemplate = Template('\n  { month: ${month}, data: db.udata_${year}_${month} },')
  while start_month <= month:
    dataDictStr += objTemplate.substitute(year=year, month=start_month)
    start_month += 1
  dataDictStr += '\n  { month: -1, data: db.udata_' + str(year) + ' }\n];'
  textTempl = Template('''
import { Component, OnInit, ViewChild } from '@angular/core';
import { MatSort } from '@angular/material/sort';
import { MatTableDataSource } from '@angular/material/table';

import { DataObject, SortedUniUsers } from '../../_helpers/users.methods';
import { monthsDict } from '../../_helpers/add_data';
import { uniPrefixes } from '../../_helpers/uni_prefixes';
import * as db from '../../_data/${year}';

const monthlyData = ${dataDict}

const Data = new DataObject();

@Component({
  selector: 'users-${year}-root',
  templateUrl: './${year}.component.html'
})
export class Users${year}Component implements OnInit {
  constructor() {}

  public prefix = '${uniPrefix}';

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
''')
  return textTempl.substitute(year=year, dataDict=dataDictStr, uniPrefix=uniPrefix)

def writeComponents(uniPrefix, year, month, start_month=1):
  outputFolder = os.path.join(appFolder, "src/app/users", str(year))
  if not os.path.exists(outputFolder):
    return print("Error: folder " + outputFolder + " doesn't exist!")
  if uniPrefix not in hawPrefixes:
    return print("Error: wrong uni prefix specified - " + uniPrefix)

  with open(os.path.join(outputFolder, str(year) + '.component.html'), 'w') as f:
    f.write(createHTML(year))
  with open(os.path.join(outputFolder, str(year) + '.component.ts'), 'w') as f:
    f.write(createTS(uniPrefix, year, month, start_month))
  return

def main (argv):
  try:
    opts, args = getopt.getopt(argv, "y:s:m:u:")
  except getopt.GetoptError:
    print ('users.components.py -y <year> -u <uni prefix> -m <up_to_month> -s <start_month>')
    sys.exit(2)
  for opt, arg in opts:
    if opt == '-y':
      year = int(arg)
    if opt == '-m':
      month = int(arg)
    if opt == '-u':
      uni = arg
    if opt == '-s':
      start_month = int(arg)
      return writeComponents(uni, year, month, start_month)
  writeComponents(uni, year, month)

if __name__ == "__main__":
  main(sys.argv[1:])
