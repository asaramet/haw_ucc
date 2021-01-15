import { NgModule } from '@angular/core';

import { MatButtonModule } from '@angular/material/button';
import { MatCardModule } from '@angular/material/card';
import { MatTabsModule } from '@angular/material/tabs';

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
