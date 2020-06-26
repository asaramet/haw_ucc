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
export const colors = {
  single: ['#04B45F'],
  dev_single: ['#00FF00'],
  dev_multiple: ['#F7BE81'],
  multiple: ['#FE9A2E'],
  fat: ['#B40431'],
  dev_multiple_e: ['#61210B'],
  multiple_e: ['#5F4C0B'],
  dev_special: ['#0B3861'],
  special: ['#0404B4'],
  gpu_4: ['#088A68'],
  gpu_8: ['#04B4AE']
}

export const options = {
  width: 1500,
  height: 650,
}
EOF
}

[[ ! -d ${A_DIR} ]] && mkdir -p ${A_DIR}
material > "${A_DIR}/material.module.ts"
configs > "${A_DIR}/configs.ts"
