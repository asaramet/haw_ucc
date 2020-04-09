import { NgModule } from '@angular/core';

import {
  //MatIconModule,
  MatButtonModule,
  MatTabsModule,
  MatCardModule
} from '@angular/material';

/**
* NgModules that includes all Material modules that are required to serve the app
*/
@NgModule({
  exports: [
    //FlexLayoutModule,
    //MatIconModule,
    MatButtonModule,
    MatTabsModule,
    MatCardModule
  ]
})
export class AppMaterialModule {};
