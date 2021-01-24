import {Injectable} from '@angular/core';
import {Product} from "./product.model";
import {Web3Service} from "./web3.service";
import {ProductState} from "./product-state.enum";
import {UserService} from "./user.service";

@Injectable({
  providedIn: 'root'
})
export class ProductService {

  public products: Product[] = [];

  constructor(public web3Service: Web3Service,
              public userService: UserService) {

  }

  async getProduct(productName: string) {
    return await this.web3Service.getProduct(productName).then(retrievedProduct => {
      return {
        name: retrievedProduct.name,
        description: retrievedProduct.description,
        dev: retrievedProduct.dev,
        rev: retrievedProduct.rev,
        totalAmount: retrievedProduct.total_amount,
        domain: retrievedProduct.expertise,
        state: ProductState[retrievedProduct.state as string],
        freelancers: this.userService.getUsersFromTeam(retrievedProduct.team),
        manager: this.userService.getUserFromAddress(retrievedProduct.manager)
      } as Product
    });
  }

  async getAllProducts2() {
    const allProductNames = await this.getAllProducts().then(retrievedProducts => {
      const productNames = [];
      retrievedProducts.forEach(product => {
        productNames.push(product.name);
      });
      return productNames;
    });

    var promises = [];
    allProductNames.forEach(productName => {
      promises.push(this.getProduct(productName));
    });

    return Promise.all(promises).then(products => {
      console.log('got all full products', products);
      return [{}] as Product[];
    })
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
          manager: this.userService.getUserFromAddress(product.manager)
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
