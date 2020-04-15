#!/usr/bin/env python3
import os, sys, getopt
from string import Template

dir_path = os.path.dirname(os.path.realpath(__file__))
app_path = os.path.join(dir_path, "../src/app")

def html(year, start=1, end=12):
  text = '''
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
  </mat-tab>'''
  while (start <= end):
    tmpl = Template('''
  <mat-tab label="${month}">
    <ng-template matTabContent>
      <data-${year}-${month}></data-${year}-${month}>
    </ng-template>
  </mat-tab>''')
    text += tmpl.substitute(year=str(year), month=str(start))
    start += 1
  text += '''
</mat-tab-group>
<unis-root></unis-root>
'''
  tmpl = Template(text)
  return tmpl.substitute(year=str(year))

def module(year, begin=1, end=12):
  text = '''
import { NgModule } from '@angular/core';
import { CommonModule } from '@angular/common';
import { MatTabsModule } from '@angular/material';
import { Year${year}Component } from './${year}.component';
import { Year${year}RouterModule } from './${year}.router';
import { UnisModule } from '../unis/unis.module';
import { TotalModule } from './total/total.module';
import { AnnualModule } from './annual/annual.module';'''
  start = begin
  while (start <= end):
    text += Template('''
import { Month${month}Module } from './${month}/${month}.module';''').substitute(month=str(start))
    start +=1

  text += '''
@NgModule({
  imports: [
    AnnualModule,
    TotalModule,'''

  start = begin
  while (start <= end):
    text += Template('''
    Month${month}Module,''').substitute(month=str(start))
    start += 1

  text += '''
    UnisModule,
    Year${year}RouterModule,
    MatTabsModule,
    CommonModule
  ],
  declarations: [ Year${year}Component ],
})
export class Year${year}Module { }
'''
  return Template(text).substitute(year=year)

def component(year):
  return Template('''
import { Component } from '@angular/core';
@Component({
  selector: 'year-${year}-root',
  templateUrl: './${year}.component.html'
})
export class Year${year}Component {
  constructor () {}
}''').substitute(year=year)

def router(year):
  return Template('''
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
export class Year${year}RouterModule {}''').substitute(year=year)

def createFiles(year=2019, start=1, end=12):
  outputFolder = os.path.join(app_path, str(year))
  htmlFile = os.path.join(outputFolder, str(year) + '.component.html')
  moduleFile = os.path.join(outputFolder, str(year) + '.module.ts')
  compFile = os.path.join(outputFolder, str(year) + '.component.ts')
  routerFile = os.path.join(outputFolder, str(year) + '.router.ts')

  if not os.path.exists(outputFolder): os.makedirs(outputFolder)

  with open(htmlFile, 'w') as f:
    f.write(html(year, start, end))

  with open(moduleFile, 'w') as f:
    f.write(module(year, start, end))

  with open(compFile, 'w') as f:
    f.write(component(year))

  with open(routerFile, 'w') as f:
    f.write(router(year))

def main(argv):
  opts, args = getopt.getopt(argv, "y:s:e:")
  for opt, arg in opts:
    if opt == '-y':
      year = int(arg)
    if opt == '-s':
      start = int(arg)
    if opt == '-e':
      end = int(arg)
  createFiles(year, start, end)

if __name__ == "__main__":
  main(sys.argv[1:])
