import { Component } from '@angular/core';
import {Web3Service} from "./web3.service";

@Component({
  selector: 'app-root',
  templateUrl: './app.component.html',
  styleUrls: ['./app.component.css']
})
export class AppComponent {
  title = 'ethWebAngular';


  constructor(private web3Service: Web3Service) {

  }

  getAccounts() {
    this.web3Service.getAccounts().then(accounts => console.log(accounts));
  }

  getCurrentAccount() {
    this.web3Service.getCurrentAccount().then(accounts => console.log(accounts[0]));
  }

}
