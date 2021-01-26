import {Injectable} from '@angular/core';
import {Product} from "./product.model";
import {Web3Service} from "./web3.service";
import {UserService} from "./user.service";

@Injectable({
  providedIn: 'root'
})
export class ProductService {

  public products: Product[] = [];

  constructor(public web3Service: Web3Service,
              public userService: UserService) {

  }

  public getProductByName(productName: string) :Product {
    return this.products.find(product => product.name === productName);
  }

  async getAllProducts() {
    this.products = await this.web3Service.getAllProducts().then(products => {
      const retrievedProducts: Product[] = [];
      console.log('productzz', products);
      products.forEach(product => {
        retrievedProducts.push({
          name: product.name,
          description: product.description,
          dev: product.dev,
          rev: product.rev,
          totalAmount: product.total_amount,
          domain: product.expertise,
          state: product.state,
          freelancers: this.userService.getUsersFromTeam(product.team),
          manager: this.userService.getUserFromAddress(product.manager),
          evaluator: product.evaluator,
          applicants: product.applicants
        } as Product);
      });

      return retrievedProducts;
    });

    return this.products;
  }

  removeProduct(product: Product) {
    return this.web3Service.removeProduct(product);
  }
}
