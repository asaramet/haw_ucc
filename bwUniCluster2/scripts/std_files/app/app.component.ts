
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
}