import {Component, OnInit} from '@angular/core';
import {Product} from "../product.model";
import {Notification} from "../notification.model";
import {Web3Service} from "../web3.service";
import {ProductService} from "../product.service";
import {UserService} from "../user.service";
import {InputDialogComponent} from "../input-dialog/input-dialog.component";
import {MatDialog} from "@angular/material/dialog";

@Component({
  selector: 'app-notifications',
  templateUrl: './notifications.component.html',
  styleUrls: ['./notifications.component.css']
})
export class NotificationsComponent implements OnInit {

  notifications: Notification[] = [];

  constructor(public web3Service: Web3Service,
              public productService: ProductService,
              public userService: UserService,
              public dialog: MatDialog) {
  }

  ngOnInit(): void {

  }

  async refreshNotifications() {
    this.notifications = [];
    await this.web3Service.getNotifications().then(notifications => {
      console.log(notifications);
      if (Array.isArray(notifications)) {
        notifications.forEach(notification => {
            console.log('notification', notification);
            this.notifications.push({
              id: notification.id,
              result: notification.message,
              product: this.productService.getProductByName(notification.prod_name)
            });
          }
        );
      }
    });
  }


  approveProductArbitrage(product: Product, notification: Notification) {
    this.web3Service.approveProductArbitrage(product, notification).then(result => {
      console.log('approved product arbitrage', product
        , 'notification ', notification, result)
      this.refreshNotifications();
    });
  }

  rejectProductArbitrage(product: Product, notification: Notification) {
    this.web3Service.rejectProductArbitrage(product, notification).then(result => {
      console.log('rejected product arbitrage ', product
        , 'notification ', notification, result)
      this.refreshNotifications();
    });
  }

  approveProduct(product: Product, notification: Notification) {
    this.web3Service.approveProduct(product, notification).then(result => {
      console.log('approved product ', product
        , 'notification ', notification, result);
      this.refreshNotifications();
    });
  }

  rejectProduct(product: Product, notification: Notification) {

    const dialogRef = this.dialog.open(InputDialogComponent, {
      data: {
        inputName: 'Reject reason'
      },
      width: '250px',
    });

    dialogRef.afterClosed().subscribe(result => {
      console.log('The dialog was closed');
      this.web3Service.rejectProduct(product, result, notification).then(result => {
        console.log('rejected product ', product
          , 'notification ', notification, result);
        this.refreshNotifications();
      });
    });


  }
}
