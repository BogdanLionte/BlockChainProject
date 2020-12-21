import {Injectable} from '@angular/core';

import Web3 from 'web3';

@Injectable({
  providedIn: 'root'
})
export class Web3Service {

  private readonly web3: any;

  constructor() {
    this.web3 = new Web3(
      new Web3.providers.HttpProvider("http://127.0.0.1:7545"),
    );
  }

  async getValueFromContract() {
    let contractDefinition = require('./../../../eth/build/contracts/TestContract.json');
    let contract = new this.web3.eth.Contract(contractDefinition['abi'], contractDefinition['networks']['5777']['address']);
    contract.methods.fundingGoal().call().then(console.log);
  }

  async getAccounts() {
    return await this.web3.eth.getAccounts();
  }
}
