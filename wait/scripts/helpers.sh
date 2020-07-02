#!/usr/bin/env bash

# Build src/app/_helpers files

MD="`dirname $(readlink -f ${0})`/.."
A_DIR="${MD}/src/app/_helpers"

material()
{
  cat << EOF
import { NgModule } from '@angular/core';

import {
  MatButtonModule,
  MatTabsModule,
} from '@angular/material';

@NgModule({
  exports: [
    MatButtonModule,
    MatTabsModule,
  ]
})
export class AppMaterialModule {};
EOF
}

configs()
{
  cat << EOF
export const colors = [
'#3A01DF', '#01A9DB', '#01DFA5', 
'#01DF3A','#A5DF00','#D7DF01',
'#DBA901','#DF7401','#DF0101']

export const ticks = [
  {v:1, f:"1s"}, {v:10, f:"10s"}, {v:30, f:"30s"},
  {v:120, f:"2m"}, {v:300, f:"5m"}, {v:1800, f:"30m"}, {v:3600, f:"1h"},
  {v:36000, f:"10h"}, {v:86400, f:"1d"}, {v:604800, f:"1w"}
]

export const options = {
  width: 1500,
  height: 650,
}
EOF
}

[[ ! -d ${A_DIR} ]] && mkdir -p ${A_DIR}
material > "${A_DIR}/material.module.ts"
configs > "${A_DIR}/configs.ts"
