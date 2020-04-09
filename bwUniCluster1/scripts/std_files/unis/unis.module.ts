import { NgModule } from '@angular/core';
import { CommonModule } from '@angular/common';

import { UnisComponent } from './unis.component';

// Angular material
import { AppMaterialModule } from '../_helpers/material.module';

@NgModule({
  imports: [
    AppMaterialModule,
    CommonModule,
  ],
  exports: [ UnisComponent ],
  declarations: [ UnisComponent ]
})
export class UnisModule { }
