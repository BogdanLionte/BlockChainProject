import {Component, OnInit} from '@angular/core';
import {Product} from "../product.model";
import {User} from "../user.model";
import {UserType} from "../user-type.enum";
import {Web3Service} from "../web3.service";
import {MatDialog} from "@angular/material/dialog";
import {InputDialogComponent} from "../input-dialog/input-dialog.component";

@Component({
  selector: 'app-products',
  templateUrl: './products.component.html',
  styleUrls: ['./products.component.css']
})
export class ProductsComponent implements OnInit {

  products: Product[] = [];
  inputDev: number;

  constructor(public web3Service: Web3Service,
              public dialog: MatDialog) { }

  ngOnInit(): void {

    this.products.push({
      description: 'product1',
      dev: 10,
      rev: 10,
      domain: 'domain1',
      manager: {
        name: 'manager1',
        expertise: 'all',
        reputation: 9999,
        type: UserType.MANAGER
      } as User
    } as Product);

    this.products.push({
      description: 'product2',
      dev: 20,
      rev: 20,
      domain: 'domain2',
      manager: {
        name: 'manager2',
        expertise: 'all2',
        reputation: 2,
        type: UserType.MANAGER
      } as User
    } as Product);

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
      console.log('user ' + this.web3Service.getCurrentUser().name + ' is applying for product ' +
        product.description + ' with dev ', this.inputDev);
      product.dev -= result;
    });


  }

  evaluateProduct(product: Product) {

  }

  removeProduct(product: Product) {

  }

  sendNotification(manager: User) {
    const dialogRef = this.dialog.open(InputDialogComponent, {
      data: {
        inputName: 'Message'
      },
      width: '250px',
    });

    dialogRef.afterClosed().subscribe(result => {
      console.log('The dialog was closed');

      console.log('sending message:', result, ' to manager ', manager.name);

    });
  }
}
