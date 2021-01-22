pragma solidity >=0.7.0 <0.8.0;

import "User.sol";
import "Freelancer.sol";
import "Financer.sol";
import "Evaluator.sol";
import "Product.sol";
import "Product_Factory.sol";
import "Manager_Factory.sol";
import "Evaluator_Factory.sol";
import "Freelancer_Factory.sol";
import "Financer_Factory.sol";

pragma experimental ABIEncoderV2;

contract Marketplace {

    mapping(string => User) private name_users;
    mapping(string => Product) private name_products;
    string[] private prod_names;
    string[] private user_names;
    mapping(string => bool) private valid_users;
    mapping(string => bool) private valid_products;
    String_Utils private s;
    Product_Factory private pf;
    Manager_Factory private mf;
    Evaluator_Factory private ef;
    Freelancer_Factory private frf;
    Financer_Factory private fif;

    constructor(Product_Factory _pf, Manager_Factory _mf, Evaluator_Factory _ef, Freelancer_Factory _frf, Financer_Factory _fif, String_Utils _s) {
        pf = _pf;
        mf = _mf;
        ef = _ef;
        frf = _frf;
        fif = _fif;
        s = _s;


        Manager manager = mf.create_manager('"manager_1', 75);
        name_users["manager_1"] = manager;
        user_names.push("manager_1");
        valid_users["manager_1"] = true;


        Financer financer_1 = fif.create_financer("financer_1", 200);
        name_users["financer_1"] = financer_1;
        user_names.push("financer_1");
        valid_users["financer_1"] = true;


        Financer financer_2 = fif.create_financer("financer_2", 300);
        name_users["financer_2"] = financer_2;
        user_names.push("financer_2");
        valid_users["financer_2"] = true;

        Financer financer_3 = fif.create_financer("financer_3", 250);
        name_users["financer_3"] = financer_3;
        user_names.push("financer_3");
        valid_users["financer_3"] = true;

        Freelancer freelancer_1 = frf.create_freelancer("freelancer_1", "databases", 50);
        name_users["freelancer_1"] = freelancer_1;
        user_names.push("freelancer_1");
        valid_users["freelancer_1"] = true;

        Freelancer freelancer_2 = frf.create_freelancer("freelancer_2", "databases", 50);
        name_users["freelancer_2"] = freelancer_2;
        user_names.push("freelancer_2");
        valid_users["freelancer_2"] = true;

        Freelancer freelancer_3 = frf.create_freelancer("freelancer_3", "javascript", 25);
        name_users["freelancer_3"] = freelancer_3;
        user_names.push("freelancer_3");
        valid_users["freelancer_3"] = true;

        Evaluator evaluator_1 = ef.create_evaluator("evaluator_1", "databases", 25);
        name_users["evaluator_1"] = evaluator_1;
        user_names.push("evaluator_1");
        valid_users["evaluator_1"] = true;

        Evaluator evaluator_2 = ef.create_evaluator("evaluator_2", "javascript", 25);
        name_users["evaluator_2"] = evaluator_2;
        user_names.push("evaluator_2");
        valid_users["evaluator_2"] = true;
    }

    function get_user_json(string memory name) public view returns(string memory) {
        return name_users[name].to_string();
    }

    function get_product_json(string memory name) public view returns(string memory) {
        return name_products[name].to_string();
    }

    function get_all_usernames() public view returns(string memory) {
        return s.arr2str(user_names);
    }

    function get_all_product_names() public view returns(string memory) {
        return s.arr2str(prod_names);
    }

    function create_product(string memory manager_name, string memory product_name, string memory product_description, uint256 dev, uint256 rev, string memory expertise_category) public{
        require(valid_users[manager_name], "the name you provide must be a user name");
        require(s.compare_strings(name_users[manager_name].user_type(), "MANAGER"), "products can only be created by managers");
        Product prod = pf.create_product(manager_name, product_name, product_description, dev, rev, expertise_category);
        name_products[product_name] = prod;
        prod_names.push(product_name);
        valid_products[product_name] = true;
    }

    function deposit(string memory prod_name, string memory financer_name, uint256 amount) public {
        require(valid_products[prod_name], "you must provide a valid product name");
        require(valid_users[financer_name], "you must provide a valid user name");
        require(s.compare_strings("FINANCER", name_users[financer_name].user_type()), "the user you provided is not a financer");
        string memory manager_name = name_products[prod_name].manager();
        address recipient = address(name_users[manager_name]);
        User sender = name_users[financer_name];
        sender.transfer(recipient, amount);
        Product prod = name_products[prod_name];
        prod.deposit(financer_name, amount);
    }

    function withdraw(string memory prod_name, string memory financer_name, uint256 amount) public {
        require(valid_products[prod_name], "you must provide a valid product name");
        require(valid_users[financer_name], "you must provide a valid user name");
        require(s.compare_strings("FINANCER", name_users[financer_name].user_type()), "the user you provided is not a financer");
        address recipient = address(name_users[financer_name]);
        Product prod = name_products[prod_name];
        User sender = name_users[prod.manager()];
        sender.transfer(recipient, amount);
        prod.withdraw(financer_name, amount);
    }

    function cancel(string memory manager_name, string memory prod_name) public {
        require(valid_products[prod_name], "you must provide a valid product name");
        require(valid_users[manager_name], "you must provide a valid user name");
        require(s.compare_strings("MANAGER", name_users[manager_name].user_type()), "the user you provided is not a manager");
        require(s.compare_strings(manager_name, name_products[prod_name].manager()), "the manager you provided is not in charge of this project");
        Product prod = name_products[prod_name];
        string[] memory depositors = prod.get_depositors();
        User sender = name_users[prod.manager()];
        for(uint i = 0; i < depositors.length; i++) {
            address recipient = address(name_users[depositors[i]]);
            uint amount = prod.get_contribution(depositors[i]);
            sender.transfer(recipient, amount);
        }
        prod.cancel();
    }

    function apply_freelancer(string memory freelancer_name, string memory prod_name, uint256 amount) public {
        require(valid_products[prod_name], "you must provide a valid product name");
        require(valid_users[freelancer_name], "you must provide a valid user name");
        require(s.compare_strings("FREELANCER", name_users[freelancer_name].user_type()), "the user you provided is not a freelancer");
        Product prod = name_products[prod_name];
        User freelancer = name_users[freelancer_name];
        require(s.compare_strings(freelancer.expertise_category(), prod.expertise_category()), "you cannot apply for a project in this category");
        prod.dev_apply(freelancer_name, amount);
    }

    function register_evaluator(string memory evaluator_name, string memory prod_name) public {
        require(valid_products[prod_name], "you must provide a valid product name");
        require(valid_users[evaluator_name], "you must provide a valid user name");
        require(s.compare_strings("EVALUATOR", name_users[evaluator_name].user_type()), "the user you provided is not an evaluator");
        Product prod = name_products[prod_name];
        User evaluator = name_users[evaluator_name];
        require(s.compare_strings(evaluator.expertise_category(), prod.expertise_category()), "you cannot apply for a project in this category");
        prod.set_evaluator(evaluator_name);
    }

    function select_team(string memory manager_name, string memory prod_name, string memory team) public{
        require(valid_products[prod_name], "you must provide a valid product name");
        require(valid_users[manager_name], "you must provide a valid user name");
        require(s.compare_strings("MANAGER", name_users[manager_name].user_type()), "the user you provided is not a manager");
        Product prod = name_products[prod_name];
        require(s.compare_strings(manager_name, prod.manager()), "this is not the right manager for the product");
        string[] memory team_names = s.splitString(team);
        for(uint i = 0; i < team_names.length; i++) {
            require(valid_users[team_names[i]], "one of the team members is not a valid user");
            require(s.compare_strings("FREELANCER", name_users[team_names[i]].user_type()), "one of the team members is not a freelancer");
        }
        prod.select_team(team_names);
    }

    function notify_manager_of_product(string memory prod_name, string memory team_member) public {
        require(valid_products[prod_name], "you must provide a valid product name");
        require(valid_users[team_member], "you must provide a valid user name");
        require(s.compare_strings("FREELANCER", name_users[team_member].user_type()), "the user you provided is not a freelancer");
        Product prod = name_products[prod_name];
        require(prod.is_valid_team_member(team_member), "the user you provided is not part of the team assigned to this product");
        User manager = name_users[prod.manager()];
        require(!manager.was_notified(), "the manager was already notified");
        manager.notify();

    }

    function accept_product(string memory manager_name, string memory prod_name) public {
        require(valid_products[prod_name], "you must provide a valid product name");
        require(valid_users[manager_name], "you must provide a valid user name");
        require(s.compare_strings("MANAGER", name_users[manager_name].user_type()), "the user you provided is not a manager");
        Product prod = name_products[prod_name];
        require(s.compare_strings(manager_name, prod.manager()), "you have not provided the right manager");
        string[] memory team = prod.get_selected_team();
        User manager = name_users[manager_name];
        require(manager.was_notified(), "the manager was not notified");
        for(uint i = 0; i < team.length; i++) {
            User team_member = name_users[team[i]];
            manager.transfer(address(team_member), prod.applicant_amounts(team[i]));
            team_member.increment_reputation();
        }
        prod.finish();
    }

    function refuse_product(string memory manager_name, string memory prod_name) public {
        require(valid_products[prod_name], "you must provide a valid product name");
        require(valid_users[manager_name], "you must provide a valid user name");
        require(s.compare_strings("MANAGER", name_users[manager_name].user_type()), "the user you provided is not a manager");
        Product prod = name_products[prod_name];
        require(!s.compare_strings(prod.evaluator(), ""), "the evaluator was not set");
        require(s.compare_strings(manager_name, prod.manager()), "you have not provided the right manager");
        User evaluator = name_users[prod.evaluator()];
        require(!evaluator.was_notified(), "the evaluator was already notified");
        evaluator.notify();

    }

    function arbitrage_accept(string memory evaluator_name, string memory prod_name) public {
        require(valid_products[prod_name], "you must provide a valid product name");
        require(valid_users[evaluator_name], "you must provide a valid user name");
        require(s.compare_strings("EVALUATOR", name_users[evaluator_name].user_type()), "the user you provided is not an evaluator");
        Product prod = name_products[prod_name];
        require(s.compare_strings(evaluator_name, prod.evaluator()), "you have not provided the right evaluator");
        require(name_users[prod.evaluator()].was_notified(), "the evaluator must be notified before the arbitrage");
        string[] memory team = prod.get_selected_team();
        User manager = name_users[prod.manager()];
        for(uint i = 0; i < team.length; i++) {
            User team_member = name_users[team[i]];
            manager.transfer(address(team_member), prod.applicant_amounts(team[i]));
            team_member.increment_reputation();
        }
        manager.decrement_reputation();
        address evaluator = address(name_users[prod.evaluator()]);
        manager.transfer(evaluator, prod.rev());
        prod.finish();

    }

    function arbitrage_deny(string memory evaluator_name, string memory prod_name) public {
        require(valid_products[prod_name], "you must provide a valid product name");
        require(valid_users[evaluator_name], "you must provide a valid user name");
        require(s.compare_strings("EVALUATOR", name_users[evaluator_name].user_type()), "the user you provided is not an evaluator");
        Product prod = name_products[prod_name];
        require(s.compare_strings(evaluator_name, prod.evaluator()), "you have not provided the right evaluator");
        require(name_users[prod.evaluator()].was_notified(), "the evaluator must be notified before the arbitrage");
        prod.reset_team();
        name_users[prod.manager()].denotify();
        name_users[prod.evaluator()].denotify();
    }
}