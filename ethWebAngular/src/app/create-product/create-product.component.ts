import { Component, OnInit } from '@angular/core';
import {Product} from "../product.model";
import {Web3Service} from "../web3.service";
import {UserService} from "../user.service";
import {ActivatedRouteSnapshot, Resolve, RouterStateSnapshot} from "@angular/router";
import {Observable} from "rxjs";
import {User} from "../user.model";

@Component({
  selector: 'app-create-product',
  templateUrl: './create-product.component.html',
  styleUrls: ['./create-product.component.css']
})
export class CreateProductComponent implements OnInit, Resolve<User> {

  dev: number;
  rev: number;
  description: string;
  domain: string;
  name: string;

  constructor(public web3Service: Web3Service,
              public userService: UserService) { }

  ngOnInit(): void {
  }

  async createProduct() {
    console.log('creating product with', this.description, this.dev, this.rev);

    const newProduct = {
      name: this.name,
      dev: this.dev,
      rev: this.rev,
      description: this.description,
      domain: this.domain,
      manager: await this.userService.getCurrentUser()
    } as Product;

    this.web3Service.createProduct(newProduct);
    console.log(newProduct);

  }

  resolve(route: ActivatedRouteSnapshot, state: RouterStateSnapshot): Observable<User> | Promise<User> | User {
    return this.userService.getCurrentUser().then(user => user);
  }

}
