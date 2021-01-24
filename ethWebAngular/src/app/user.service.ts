import {Injectable} from '@angular/core';
import {User} from "./user.model";
import {Web3Service} from "./web3.service";

@Injectable({
  providedIn: 'root'
})
export class UserService {

  userLoaded: Promise<boolean>;

  public users: User[] = [];
  public currentUser: User;

  constructor(public web3Service: Web3Service) {
    this.getCurrentUser().then(user => this.currentUser = user);
  }

  getUserFromAddress(addr) {
    return this.users.filter(user => user.address === addr)[0];
  }

  getUsersFromTeam(team) {
    return [];
  }

  async getCurrentUser() {
    console.log('getting current user???');
    if (this.currentUser) {
      return this.currentUser;
    }

    console.log('skip??');
    this.currentUser = await this.web3Service.getCurrentAccount().then(accounts => {
      console.log('crt acc', accounts[0]);
      return this.getUsers().then(users => {
        console.log('uzz', users);
        console.log('acc 0', accounts[0]);
        this.userLoaded = Promise.resolve(true);
        return users.filter(user => user.address === accounts[0])[0];
      });
    });

    console.log('????', this.currentUser);
    return this.currentUser;
  }

  async getUsers() {
    if (this.users.length !== 0) {
      return this.users;
    }

    this.users = await this.web3Service.getAllUsers().then(users => {
      console.log('all users', users);
      let serializedUsers: User[] = [];
      users.forEach(user => {
        serializedUsers.push({
          name: user[0],
          reputation: user[1],
          expertise: user[2],
          address: user[3],
          type: user[5]
        } as User)
      });

      return serializedUsers;
    });

    return this.users;
  }
}
