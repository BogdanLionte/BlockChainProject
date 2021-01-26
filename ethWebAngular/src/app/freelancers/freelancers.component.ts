import { Component, OnInit } from '@angular/core';
import {User} from "../user.model";
import {Product} from "../product.model";
import {Web3Service} from "../web3.service";
import {UserService} from "../user.service";
import {ActivatedRouteSnapshot, Resolve, RouterStateSnapshot} from "@angular/router";
import {Observable} from "rxjs";
import {ProductService} from "../product.service";
import {MatOptionSelectionChange} from "@angular/material/core";

@Component({
  selector: 'app-freelancers',
  templateUrl: './freelancers.component.html',
  styleUrls: ['./freelancers.component.css']
})
export class FreelancersComponent implements OnInit, Resolve<User> {

  freelancers: User[] = [];
  products: Product[] = [];
  selectedProduct: Product;

  constructor(public web3Service: Web3Service,
              public userService: UserService,
              public productService: ProductService) { }

  ngOnInit(): void {
    this.productService.getAllProducts()
      .then(products => this.products = products);
  }

  async refreshProducts() {
    console.log('refresh products from child');
    this.products = await this.productService.getAllProducts().then(
      products => products
    );
  }

  selectFreelancer(freelancer: User) {
    freelancer.selected = !freelancer.selected;
  }

  submitFreelancers() {
    const selectedFreelancers = this.freelancers.filter(freelancer => freelancer.selected);

    console.log('selected freelancers', selectedFreelancers);
    console.log('chose ', this.selectedProduct);
    this.web3Service.selectFreelancer(selectedFreelancers, this.selectedProduct);
  }

  resolve(route: ActivatedRouteSnapshot, state: RouterStateSnapshot): Observable<User> | Promise<User> | User {
    return this.userService.getCurrentUser().then(user => user);
  }

  async productSelected(product : Product) {
    this.freelancers = [];
    this.userService.users.forEach(user => {
      if (product.applicants.includes(user.address)) {
        this.web3Service.getApplicantAmount(product, user.address).then(result => {
          user.dev = result;
          this.freelancers.push(user);
        });
      }
    });
  }
}
