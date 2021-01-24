import {UserType} from "./user-type.enum";

export class User {

  name: string;
  reputation: number;
  expertise: string;
  address: string;
  type: string;
  selected?: boolean;
}
