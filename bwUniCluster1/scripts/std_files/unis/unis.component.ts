import { Component } from '@angular/core';
//import { Router } from '@angular/router';

import { uniPrefixes_1,
  uniPrefixes_2,
  uniPrefixes_3,
  uniPrefixes_4} from '../_helpers/uni_prefixes';

@Component({
  selector: 'unis-root',
  templateUrl: './unis.component.html'
})
export class UnisComponent {
  //constructor (private router:Router) {}
  constructor () {}

  uni_prefixes_1 = uniPrefixes_1;
  uni_prefixes_2 = uniPrefixes_2;
  uni_prefixes_3 = uniPrefixes_3;
  uni_prefixes_4 = uniPrefixes_4;

  //go2019() {
  //  this.router.navigate(['/unis/2019'])
  //}

  ngOnInit() {}
}
