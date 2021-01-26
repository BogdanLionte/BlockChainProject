import {Component, OnInit, ViewChild} from '@angular/core';
import {ProductsComponent} from "../products/products.component";
import {FreelancersComponent} from "../freelancers/freelancers.component";
import {NotificationsComponent} from "../notifications/notifications.component";

@Component({
  selector: 'app-navigation',
  templateUrl: './navigation.component.html',
  styleUrls: ['./navigation.component.css']
})
export class NavigationComponent implements OnInit {

  @ViewChild(ProductsComponent)
  private productsComponent: ProductsComponent;

  @ViewChild(FreelancersComponent)
  private freelancersComponent: FreelancersComponent;

  @ViewChild(NotificationsComponent)
  private notificationsComponent : NotificationsComponent;

  refresh(event) {
    console.log('eventtt', event);
    console.log('refrehs products from parent');
    if (event.index === 1) {
      this.productsComponent.refreshProducts();
    }

    if (event.index === 2) {
      this.freelancersComponent.refreshProducts();
    }

    if (event.index === 3) {
      this.notificationsComponent.refreshNotifications();
    }
  }

  constructor() { }

  ngOnInit(): void {
  }

}
