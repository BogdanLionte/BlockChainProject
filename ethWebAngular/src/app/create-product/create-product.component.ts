import { Component, OnInit } from '@angular/core';
import {Product} from "../product.model";
import {Web3Service} from "../web3.service";
import {User} from "../user.model";

@Component({
  selector: 'app-create-product',
  templateUrl: './create-product.component.html',
  styleUrls: ['./create-product.component.css']
})
export class CreateProductComponent implements OnInit {

  dev: number;
  rev: number;
  description: string;
  domain: string;

  constructor(public web3Service: Web3Service) { }

  ngOnInit(): void {
  }

  createProduct() {
    console.log('creating product with', this.description, this.dev, this.rev);

    const newProduct = {
      dev: this.dev,
      rev: this.rev,
      description: this.description,
      domain: this.domain,
      manager: this.web3Service.getCurrentUser()
    } as Product;

    console.log(newProduct);

  }

}
