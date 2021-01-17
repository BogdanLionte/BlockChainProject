import { Component, OnInit } from '@angular/core';
import {Product} from "../product.model";
import {Notification} from "../notification.model";
import {UserType} from "../user-type.enum";
import {User} from "../user.model";

@Component({
  selector: 'app-notifications',
  templateUrl: './notifications.component.html',
  styleUrls: ['./notifications.component.css']
})
export class NotificationsComponent implements OnInit {

  notifications: Notification[] = [];

  constructor() { }

  ngOnInit(): void {

    this.notifications.push({
      product: {
        description: 'product1',
        dev: 10,
        rev: 10,
        domain: 'domain1',
        finalized: true,
        manager: {
          name: 'manager1',
          expertise: 'all',
          reputation: 9999,
          type: UserType.MANAGER
        } as User
      } as Product,
      result: 'good looking product'
    } as Notification );

    this.notifications.push({
      product: {
        description: 'product2',
        dev: 10,
        rev: 10,
        domain: 'domain1',
        finalized: true,
        manager: {
          name: 'manager1',
          expertise: 'all',
          reputation: 9999,
          type: UserType.MANAGER
        } as User
      } as Product,
      result: 'bad looking product'
    } as Notification );

  }

  approveProduct(product: Product) {

  }

  rejectProduct(product: Product) {

  }
}
