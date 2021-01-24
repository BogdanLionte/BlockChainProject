import {Component, OnInit, ViewChild} from '@angular/core';
import {ProductsComponent} from "../products/products.component";

@Component({
  selector: 'app-navigation',
  templateUrl: './navigation.component.html',
  styleUrls: ['./navigation.component.css']
})
export class NavigationComponent implements OnInit {

  @ViewChild(ProductsComponent)
  private productsComponent: ProductsComponent;

  refreshProducts(event) {
    console.log('eventtt', event);
    console.log('refrehs products from parent');
    if (event.index === 1) {
      this.productsComponent.refreshProducts();
    }
  }

  constructor() { }

  ngOnInit(): void {
  }

}
