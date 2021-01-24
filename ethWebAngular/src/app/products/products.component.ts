import {Component, OnInit} from '@angular/core';
import {Product} from "../product.model";
import {User} from "../user.model";
import {UserType} from "../user-type.enum";
import {Web3Service} from "../web3.service";
import {MatDialog} from "@angular/material/dialog";
import {InputDialogComponent} from "../input-dialog/input-dialog.component";
import {UserService} from "../user.service";
import {ProductService} from "../product.service";
import {ProductState} from "../product-state.enum";
import {ActivatedRouteSnapshot, Resolve, RouterStateSnapshot} from "@angular/router";
import {Observable} from "rxjs";

@Component({
  selector: 'app-products',
  templateUrl: './products.component.html',
  styleUrls: ['./products.component.css']
})
export class ProductsComponent implements OnInit, Resolve<User> {

  products: Product[] = [];
  inputDev: number;
  productState = ProductState;
  userType = UserType;

  constructor(public web3Service: Web3Service,
              public dialog: MatDialog,
              public userService: UserService,
              public productService: ProductService) {
  }

  ngOnInit(): void {
    this.userService.getUsers().then(users => {
      console.log('users', users);
    });
  }

  refreshProducts() {
    console.log('refresh products from child');
    this.productService.getAllProducts().then(
      products => this.products = products
    );
  }

  applyForProduct(product: Product) {
    const dialogRef = this.dialog.open(InputDialogComponent, {
      data: {
        inputName: 'DEV'
      },
      width: '250px',
    });

    dialogRef.afterClosed().subscribe(result => {
      console.log('The dialog was closed');
      this.inputDev = result;
      console.log('user ' + this.userService.currentUser.name + ' is applying for product ' +
        product.description + ' with dev ', this.inputDev);
      this.web3Service.applyForProduct(product, result).then(result => console.log('applied for product ' + product +
      ' with dev ' + result));
      product.dev -= result;
    });

  }

  acceptProduct(product: Product) {

  }

  rejectProduct(product: Product) {

  }

  removeProduct(product: Product) {
    this.productService.removeProduct(product).then(result => {
      console.log('removed product', result);
      this.refreshProducts();
    });
  }

  sendNotification(product: Product) {
    const dialogRef = this.dialog.open(InputDialogComponent, {
      data: {
        inputName: 'Message'
      },
      width: '250px',
    });

    dialogRef.afterClosed().subscribe(result => {
      console.log('The dialog was closed');
      console.log('sending message:', result, ' to manager ', product.manager.name);
      this.web3Service.sendNotification(product, result);

    });
  }

  financeProduct(product: Product) {
    const dialogRef = this.dialog.open(InputDialogComponent, {
      data: {
        inputName: 'Amount'
      },
      width: '250px',
    });

    dialogRef.afterClosed().subscribe(result => {
      console.log('The dialog was closed');
      this.web3Service.financeProduct(product, result);
    });

  }

  withdrawFinanceProduct(product: Product) {
    const dialogRef = this.dialog.open(InputDialogComponent, {
      data: {
        inputName: 'Amount'
      },
      width: '250px',
    });

    dialogRef.afterClosed().subscribe(result => {
      console.log('The dialog was closed');
      this.web3Service.withdrawFinanceProduct(product, result);
    });

  }

  applyForEvaluatingProduct(product: Product) {
    this.web3Service.applyForEvaluatingProduct(product);
  }

  resolve(route: ActivatedRouteSnapshot, state: RouterStateSnapshot): Observable<User> | Promise<User> | User {
    return this.userService.getCurrentUser().then(user => user);
  }
}
