import {User} from "./user.model";

export class Product {

  description: string;
  rev: number;
  dev: number;
  manager: User;
  domain: string;
  finalized: boolean;
  workInProgress: boolean;
  freelancers: User[];

}
