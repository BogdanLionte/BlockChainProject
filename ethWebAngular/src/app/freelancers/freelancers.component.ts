import { Component, OnInit } from '@angular/core';
import {User} from "../user.model";
import {UserType} from "../user-type.enum";
import {Product} from "../product.model";
import {Web3Service} from "../web3.service";
import {UserService} from "../user.service";
import {ActivatedRouteSnapshot, Resolve, RouterStateSnapshot} from "@angular/router";
import {Observable} from "rxjs";

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
              public userService: UserService) { }

  ngOnInit(): void {

    this.products.push({
      name: 'prod1'
    } as Product);

    this.products.push({
      name: 'prod2'
    } as Product);

    this.freelancers.push({
      name: 'freelancer1',
      expertise: 'expertise1',
      reputation: 1,
      type: UserType.FREELANCER,
      selected: true
    } as User);
    this.freelancers.push({
      name: 'freelancer2',
      expertise: 'expertise2',
      reputation: 2,
      type: UserType.FREELANCER
    } as User);
    this.freelancers.push({
      name: 'freelancer3',
      expertise: 'expertise3',
      reputation: 3,
      type: UserType.FREELANCER
    } as User);

  }


  selectFreelancer(freelancer: User) {
    freelancer.selected = !freelancer.selected;
  }

  submitFreelancers() {
    const selectedFreelancers = this.freelancers.filter(freelancer => freelancer.selected);
    this.web3Service.selectFreelancer(selectedFreelancers, this.selectedProduct);
  }

  resolve(route: ActivatedRouteSnapshot, state: RouterStateSnapshot): Observable<User> | Promise<User> | User {
    return this.userService.getCurrentUser().then(user => user);
  }
}
