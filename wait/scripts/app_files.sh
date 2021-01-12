#!/usr/bin/env bash

# Build src/app/app.* files

MD="`dirname $(readlink -f ${0})`/.."
A_DIR="${MD}/src/app"

declare -i START_YEAR="${1}"
declare -i YEAR="${2}"

HTML="${A_DIR}/app.component.html"
COMPONENT="${A_DIR}/app.component.ts"
MODULE="${A_DIR}/app.module.ts"
ROOTER="${A_DIR}/app.router.module.ts"

html()
{
  START_YEAR=${1}
  year=${2}
  cat << EOF
<section class="mat-typography">
  <h1 class="title mat-display-1">{{title}}</h1>
  <nav class="navs">
    <div [hidden]="(showTop)">
EOF

  start_year=${START_YEAR}
  while [[ ${start_year} -le ${year} ]]; do
    echo "      <button mat-button color='primary' routerLink='${start_year}'>${start_year}</button>"
    start_year=$(( ${start_year} + 1 ))
  done

  echo -e '    </div>\n    <div [hidden]="!(showTop)">'

  start_year=${START_YEAR}
  while [[ ${start_year} -le ${year} ]]; do
    echo "    <button mat-button color='accent' routerLink='top/${start_year}'>${start_year}</button>"
    start_year=$(( ${start_year} + 1 ))
  done

  cat << EOF
    </div>
    <div [hidden]="!(showTop)">
      <button mat-button color="primary" routerLink="${year}" (click)="toggleTop()">
        All
      </button>
    </div>
    <div [hidden]="(showTop)">
      <button mat-button color="accent" routerLink="top" (click)="toggleTop()">
        Top Users
      </button>
    </div>
  </nav>
  <router-outlet></router-outlet>
</section>
<footer class="mat-typography">
  <p class="body-1">&copy; ${year} Hochschule Esslingen, Alexandru Saramet</p>
</footer>
EOF
}

component()
{
  cat << EOF
import { Component } from '@angular/core';
@Component({
  selector: 'app-root',
  templateUrl: './app.component.html'
})
export class AppComponent {
  constructor () {}
  public title:string = "Waiting time in different job queues on bwUniCluster 2.0 for HAW users";
  public showTop:boolean = false;
  toggleTop() {
    this.showTop = !this.showTop;
  }
}
EOF
}

module()
{
  cat << EOF
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
export class AppModule { }
EOF
}

rooter()
{
  start_year=${1}
  year=${2}

  cat << EOF
import { NgModule } from '@angular/core';
import { Routes, RouterModule } from '@angular/router';
const routes: Routes = [
EOF

  while [[ ${start_year} -le ${year} ]]; do
    echo "  //{ path: '${start_year}', loadChildren: './${start_year}/${start_year}.module#Year${start_year}Module' },"
    echo "  //{ path: 'top/${start_year}', loadChildren: './top/${start_year}/${start_year}.module#Top${start_year}Module' },"
    echo "  { path: '${start_year}', loadChildren: () => import('./${start_year}/${start_year}.module').then(m => m.Year${start_year}Module) },"
    echo "  { path: 'top/${start_year}', loadChildren: () => import('./top/${start_year}/${start_year}.module').then(m => m.Top${start_year}Module) },"
    start_year=$(( ${start_year} + 1 ))
  done

  cat << EOF
  { path: 'top', redirectTo: 'top/${year}', pathMatch: 'full' },
  { path: '', redirectTo: '${year}', pathMatch: 'full'},
]
@NgModule({
  imports: [
    RouterModule.forRoot(routes)
  ],
  exports: [RouterModule],
  providers: []
})
export class AppRouterModule {}
EOF
}

rooter ${START_YEAR} ${YEAR} > ${ROOTER}
module > ${MODULE}
component > ${COMPONENT}
html ${START_YEAR} ${YEAR} > ${HTML}
