import { Component, OnInit } from '@angular/core';
import {User} from "../user.model";
import {UserType} from "../user-type.enum";

@Component({
  selector: 'app-freelancers',
  templateUrl: './freelancers.component.html',
  styleUrls: ['./freelancers.component.css']
})
export class FreelancersComponent implements OnInit {

  freelancers: User[] = [];

  constructor() { }

  ngOnInit(): void {

    this.freelancers.push({
      name: 'freelancer1',
      expertise: 'expertise1',
      reputation: 1,
      type: UserType.FREELANCER
    } as User);
    this.freelancers.push({
      name: 'freelancer2',
      expertise: 'expertise2',
      reputation: 2,
      type: UserType.FREELANCER
    } as User);
    this.freelancers.push({
      name: 'freelancer3',
      expertise: 'expertise3',
      reputation: 3,
      type: UserType.FREELANCER
    } as User);

  }


  selectFreelancer(freelancer: User) {

  }
}
