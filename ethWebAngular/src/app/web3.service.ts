import {Injectable} from '@angular/core';

import Web3 from 'web3';
import {Product} from "./product.model";
import {User} from "./user.model";
import {Notification} from "./notification.model";

@Injectable({
  providedIn: 'root'
})
export class Web3Service {

  private readonly web3: any;
  private readonly web3Meta: any;
  private contract: any;

  constructor() {
    this.web3 = new Web3(
      new Web3.providers.HttpProvider("http://127.0.0.1:7545"),
    );

    this.web3Meta = new Web3((window as any).ethereum);

    //prompt user to enable metamask
    (window as any).ethereum.enable();

    let contractDefinition = require('./../../../eth/build/contracts/Marketplace.json');
    this.contract = new this.web3.eth.Contract(contractDefinition['abi'], contractDefinition['networks']['5777']['address']);
    console.log(this.contract);
  }

  async getAllUsers() {
    return this.contract.methods.get_users().call();
  }

  async getAllProducts() {
    return this.contract.methods.get_products().call();
  }

  async getProduct(product: string) {
    return this.contract.methods.get_product_struct(product).call();
  }

  async createProduct(product: Product) {
    let currentAccount = await this.getCurrentAccount().then(accounts => accounts[0]);
    this.contract.methods.create_product(
      product.name,
      product.description,
      product.dev,
      product.rev,
      product.domain
    ).send({from: currentAccount, gas: 20000000}).then(result => console.log('created product', result));
  }

  async selectFreelancer(freelancers: User[], product: Product) {
    let currentAccount = await this.getCurrentAccount().then(accounts => accounts[0]);
    return this.contract.methods.select_team(
      product.name,
      freelancers.map(freelancer => freelancer.address)
    ).send({from: currentAccount, gas: 20000000});
  }

  async applyForProduct(product: Product, amount: number) {
    let currentAccount = await this.getCurrentAccount().then(accounts => accounts[0]);
    return this.contract.methods.apply_freelancer(
      product.name,
      amount
    ).send({from: currentAccount, gas: 20000000});
  }

  async removeProduct(product: Product) {
    let currentAccount = await this.getCurrentAccount().then(accounts => accounts[0]);
    console.log('removing product', product.name);
    return this.contract.methods.cancel(
      product.name
    ).send({from: currentAccount, gas: 20000000});
  }

  async sendNotification(product: Product, message: string) {
    let currentAccount = await this.getCurrentAccount().then(accounts => accounts[0]);
    return this.contract.methods.notify_manager_of_product(
      product.name,
      message
    ).send({from: currentAccount, gas: 20000000});
  }

  async financeProduct(product: Product, value: number) {
    let currentAccount = await this.getCurrentAccount().then(accounts => accounts[0]);
    console.log('financer ' + currentAccount + ' is financing product ' +
      product.description + ' with ', value);
    console.log('financing product', product.name);
    return this.contract.methods.deposit(
      product.name,
      value
    ).send({from: currentAccount, gas: 20000000});
  }

  async getAccounts() {
    return await this.web3.eth.getAccounts();
  }

  async getCurrentAccount() {
    return await this.web3Meta.eth.getAccounts();
  }

  async withdrawFinanceProduct(product: Product, value: any) {
    let currentAccount = await this.getCurrentAccount().then(accounts => accounts[0]);
    console.log('financer ' + currentAccount + ' is withdrawing finance product ' +
      product.description + ' with ', value);
    console.log('withdraw financing product', product.name);
    return this.contract.methods.withdraw(
      product.name,
      value
    ).send({from: currentAccount, gas: 20000000});
  }

  async approveProduct(product: Product, notification: Notification) {
    let currentAccount = await this.getCurrentAccount().then(accounts => accounts[0]);
    this.contract.methods.arbitrage_accept(
      product.name,
      notification.id
    ).send({from: currentAccount, gas: 20000000});
  }

  async rejectProduct(product: Product, notification: Notification) {
    let currentAccount = await this.getCurrentAccount().then(accounts => accounts[0]);
    this.contract.methods.arbitrage_deny(
      product.name,
      notification.id
    ).send({from: currentAccount, gas: 20000000});
  }

  async applyForEvaluatingProduct(product: Product) {
    let currentAccount = await this.getCurrentAccount().then(accounts => accounts[0]);
    this.contract.methods.register_evaluator(
      product.name,
    ).send({from: currentAccount, gas: 20000000});
  }


}
