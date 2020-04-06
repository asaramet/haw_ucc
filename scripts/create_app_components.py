#!/usr/bin/env python3

import os, sys, getopt
from string import Template

dir_path = os.path.dirname(os.path.realpath(__file__))
app_path = os.path.join(dir_path, '../bwUniCluster1/src/app')
startWith = 2017

def component():
  return '''
import { Component } from '@angular/core';
@Component({
  selector: 'app-root',
  templateUrl: './app.component.html'
})
export class AppComponent {
  constructor () {}
  public title:string = "Utilized capacity of available nodes on bwUniCluster per HAW";
  public showUsers:boolean = false;
  toggleUsers() {
    this.showUsers = !this.showUsers;
  }
}'''

def module():
  return '''
import { BrowserModule } from '@angular/platform-browser';
import { BrowserAnimationsModule } from '@angular/platform-browser/animations';
import { NgModule } from '@angular/core';
import { CommonModule } from '@angular/common';
import { HttpClientModule } from '@angular/common/http';
import { AppRouterModule } from './app.router.module';
import { AppComponent } from './app.component';
import { AppMaterialModule } from './_helpers/material.module';
@NgModule({
  declarations: [
    AppComponent
  ],
  imports: [
    CommonModule,
    BrowserModule,
    BrowserAnimationsModule,
    HttpClientModule,
    AppRouterModule,
    AppMaterialModule
  ],
  providers: [],
  bootstrap: [AppComponent]
})
export class AppModule { }'''

def router(year):
  text = '''import { NgModule } from '@angular/core';
import { Routes, RouterModule } from '@angular/router';
const routes: Routes = ['''

  start = startWith
  while (start <= year):
    tmp = """
  { path: \'${year}\', loadChildren: \'./${year}/${year}.module#Year${year}Module\' },
  { path: \'users/${year}\', loadChildren: \'./users/${year}/${year}.module#Users${year}Module\' },"""
    text += Template(tmp).substitute(year=start)
    start += 1

  tmp = '''
  { path: \'users\', redirectTo: \'users/${year}\', pathMatch: \'full\' },
  { path: \'\', redirectTo: \'${year}\', pathMatch: \'full\'}
]
@NgModule({
  imports: [
    RouterModule.forRoot(routes)
  ],
  exports: [RouterModule],
  providers: []
})
export class AppRouterModule {}'''
  text += Template(tmp).substitute(year=year)
  return text

def html(year):
  text = '''<section class="mat-typography">
  <h1 class="title mat-display-1">{{title}}</h1>
  <nav class="navs">
    <div [hidden]="(showUsers)">
'''

  start = startWith
  while (start <= year):
    tmp = "      <button mat-button color=\"primary\" routerLink=\"${year}\">${year}</button>\n"
    text += Template(tmp).substitute(year=start)
    start += 1

  text += """    </div>\n    <div [hidden]=\"!(showUsers)\">\n"""

  start = startWith
  while (start <= year):
    tmp = "      <button mat-button color=\"accent\" routerLink=\"users/${year}\">${year}</button>\n"
    text += Template(tmp).substitute(year=start)
    start += 1

  tmp ='''    </div>
    <div [hidden]=\"!(showUsers)\">
      <button mat-button color=\"primary\" routerLink=\"${year}\" (click)=\"toggleUsers()\">
        Unis
      </button>
    </div>
    <div [hidden]=\"(showUsers)\">
      <button mat-button color=\"accent\" routerLink=\"users\" (click)=\"toggleUsers()\">
        Users
      </button>
    </div>
  </nav>
  <router-outlet></router-outlet>
</section>
<footer class=\"mat-typography\">
  <p class=\"body-1\">&copy; ${year} Hochschule Esslingen, Alexandru Saramet</p>
</footer>'''
  text += Template(tmp).substitute(year=year)
  return text

def createFiles(year):
  with open(os.path.join(app_path, 'app.component.ts'), 'w') as f:
    f.write(component())

  with open(os.path.join(app_path, 'app.module.ts'), 'w') as f:
    f.write(module())

  with open(os.path.join(app_path, 'app.router.module.ts'), 'w') as f:
    f.write(router(year))

  with open(os.path.join(app_path, 'app.component.html'), 'w') as f:
    f.write(html(year))

def main(argv):
  opts, args = getopt.getopt(argv, "y:")
  for opt, arg in opts:
    if opt == '-y':
      year = int(arg)
  createFiles(year)

if __name__ == '__main__':
  main(sys.argv[1:])
