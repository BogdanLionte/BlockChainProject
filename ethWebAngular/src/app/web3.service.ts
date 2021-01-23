import {Injectable} from '@angular/core';

import Web3 from 'web3';
import {User} from "./user.model";
import {UserType} from "./user-type.enum";

@Injectable({
  providedIn: 'root'
})
export class Web3Service {

  private readonly web3: any;
  private readonly web3Meta: any;

  constructor() {
    this.web3 = new Web3(
      new Web3.providers.HttpProvider("http://127.0.0.1:7545"),
    );

    this.web3Meta = new Web3((window as any).ethereum);
  }

  async getValueFromContract() {
    let contractDefinition;
    let contract;

    contractDefinition = require('./../../../eth/build/contracts/TestContract.json');
    contract = new this.web3.eth.Contract(contractDefinition['abi'], contractDefinition['networks']['5777']['address']);
    contract.methods.getFundingGoal().call().then(console.log);

    contractDefinition = require('./../../../eth/build/contracts/Marketplace.json');
    contract = new this.web3.eth.Contract(contractDefinition['abi'], contractDefinition['networks']['5777']['address']);
    console.log(contract);
    contract.methods.getSomething().call().then(console.log);


  }

  async getAccounts() {
    return await this.web3.eth.getAccounts();
  }

  async getCurrentAccount() {
    return await this.web3Meta.eth.getAccounts();
  }

  getCurrentUser() {
    //get from smart contract based on currentAccount address
    return {
      name: 'user1',
      expertise: 'all',
      reputation: 9999,
      type: UserType.MANAGER
    } as User;
  }
}
