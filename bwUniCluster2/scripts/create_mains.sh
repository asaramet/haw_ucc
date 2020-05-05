#!/usr/bin/env bash

# Create app.router.module.ts and app.component.html

MD="`dirname $(readlink -f ${0})`/.."
A_DIR=${MD}/src/app

HTML="${A_DIR}/app.component.html"
ROOTER="${A_DIR}/app.router.module.ts"

START_YEAR="2020"
YEAR=`date -d 'yesterday' '+%Y'`

write_html()
{
  declare -i start=${START_YEAR}
  declare -i end=${1}

  [[ ${end} -lt ${start} ]] && echo "YEAR can't be less then ${start}" && exit 1

  cat << EOF
<section class="mat-typography">
  <h1 class="title mat-display-1">{{title}}</h1>
  <nav class="navs">
    <div [hidden]="(showUsers)">
EOF

  while [[ ${start} -le ${end} ]]; do
    echo "     <button mat-button color='primary' routerLink='${start}'>${start}</button>"
    start=$(( ${start} + 1 ))
  done
  echo -e '    </div>\n    <div [hidden]="!(showUsers)">'

  declare -i start=${START_YEAR}
  while [[ ${start} -le ${end} ]]; do
    echo "     <button mat-button color='accent' routerLink='users/${start}'>${start}</button>"
    start=$(( ${start} + 1 ))
  done
  cat << EOF
    </div>
    <div [hidden]="!(showUsers)">
      <button mat-button color="primary" routerLink="${end}" (click)="toggleUsers()">
        Unis
      </button>
    </div>
    <div [hidden]="(showUsers)">
      <button mat-button color="accent" routerLink="users" (click)="toggleUsers()">
        Users
      </button>
    </div>
  </nav>
  <router-outlet></router-outlet>
</section>
<footer class="mat-typography">
  <p class="body-1">&copy; ${end} Hochschule Esslingen, Alexandru Saramet</p>
</footer>
EOF
}


write_router()
{
  declare -i start=${START_YEAR}
  declare -i end=${1}

  [[ ${end} -lt ${start} ]] && echo "YEAR can't be less then ${start}" && exit 1

  cat << EOF
import { NgModule } from '@angular/core';
import { Routes, RouterModule } from '@angular/router';
const routes: Routes = [
EOF

  while [[ ${start} -le ${end} ]]; do
    cat << EOF
  { path: '${start}', loadChildren: './${start}/${start}.module#Year${start}Module' },
  { path: 'users/${start}', loadChildren: './users/${start}/${start}.module#Users${start}Module' },
EOF
    start=$(( ${start} + 1 ))
  done

  cat << EOF
  { path: 'users', redirectTo: 'users/${end}', pathMatch: 'full' },
  { path: '', redirectTo: '${end}', pathMatch: 'full'}
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

echo "... Writing ${HTML}"
write_html ${YEAR} > ${HTML}
echo "... Writing ${ROOTER}"
write_router ${YEAR} > ${ROOTER}
