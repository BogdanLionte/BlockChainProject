import {User} from "./user.model";

export class Product {

  description: string;
  rev: number;
  dev: number;
  manager: User;
  domain: string;
  state: string;
  freelancers: User[];
  name: string;
  totalAmount: number;

}
