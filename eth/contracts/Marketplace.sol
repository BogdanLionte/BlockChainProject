pragma solidity >=0.7.0 <0.8.0;

import "./User.sol";
import "./Freelancer.sol";
import "./Financer.sol";
import "./Evaluator.sol";
import "./Product.sol";
import "./Product_Factory.sol";
import "./Manager_Factory.sol";
import "./Evaluator_Factory.sol";
import "./Freelancer_Factory.sol";
import "./Financer_Factory.sol";
import "./Manager.sol";

pragma experimental ABIEncoderV2;

contract Marketplace {

    mapping(address => User) private addresses_users;
    mapping(string => Product) private name_products;
    string[] private prod_names;
    address[] private user_addresses;
    mapping(address => bool) private valid_addresses;
    mapping(string => bool) private valid_products;
    mapping(address => Notification_Struct[]) private notifications;
    mapping(uint256 => uint) private notification_indexes;
    uint256 current_notification_id;
    User_Struct[] private user_structs;
    Product_Struct[] private prod_structs;

    Product_Factory private pf;
    Manager_Factory private mf;
    Evaluator_Factory private ef;
    Freelancer_Factory private frf;
    Financer_Factory private fif;

    struct Notification_Struct {
        uint256 id;
        string message;
    }

    struct User_Struct {
        string name;
        uint8 reputation;
        string expertise;
        address addr;
        uint balance;
        string user_type;
    }

    struct Product_Struct {
        string name;
        string description;
        uint256 dev;
        uint256 rev;
        string expertise;
        address manager;
        string state;
        address[] depositors;
        address[] team;
        address evaluator;
        uint256 total_amount;
    }

    constructor(Product_Factory _pf, Manager_Factory _mf, Evaluator_Factory _ef, Freelancer_Factory _frf, Financer_Factory _fif) {
        pf = _pf;
        mf = _mf;
        ef = _ef;
        frf = _frf;
        fif = _fif;

        address manager_1_addr = 0x00EEE5B6d925Eeedff2f4A4AC5f6bd361e2ff1ab;
        Manager manager = mf.create_manager(manager_1_addr, "manager_1", 75);
        add_user(manager_1_addr, manager);

        address financer_1_addr = 0x5f1546f27111f9D4785ebF6ebc2FD8f48AE3eB93;
        Financer financer_1 = fif.create_financer(financer_1_addr, "financer_1", 200);
        add_user(financer_1_addr, financer_1);

        address financer_2_addr = 0x129fEb8F88b85A97112A75F22D6C4eCa6d303c10;
        Financer financer_2 = fif.create_financer(financer_2_addr, "financer_2", 300);
        add_user(financer_2_addr, financer_2);

        address financer_3_addr = 0x1D4b0B98112F4C7039Fc83BF9E8e72D2509FC5f4;
        Financer financer_3 = fif.create_financer(financer_3_addr, "financer_3", 250);
        add_user(financer_3_addr, financer_3);

        address freelancer_1_addr = 0x5BE58C8cd70f07f9Ad8Eac2473e5ca8338f1A471;
        Freelancer freelancer_1 = frf.create_freelancer(freelancer_1_addr, "freelancer_1", "databases", 50);
        add_user(freelancer_1_addr, freelancer_1);

        address freelancer_2_addr = 0xA204D42966deE8Ee61B3193924904203Ab981F30;
        Freelancer freelancer_2 = frf.create_freelancer(freelancer_2_addr, "freelancer_2", "databases", 50);
        add_user(freelancer_2_addr, freelancer_2);

        address freelancer_3_addr = 0x30b33dD0C4880D601D690af786cbf160ee06BcC2;
        Freelancer freelancer_3 = frf.create_freelancer(freelancer_3_addr, "freelancer_3", "javascript", 25);
        add_user(freelancer_3_addr, freelancer_3);

        address evaluator_1_addr = 0xD8f6CFADaDB075e639c4d6163D7b4F8cD1E306ae;
        Evaluator evaluator_1 = ef.create_evaluator(evaluator_1_addr, "evaluator_1", "databases", 25);
        add_user(evaluator_1_addr, evaluator_1);

        address evaluator_2_addr = 0xc7A09e3bfAD1E19e219291EA10b8762Ad7498D38;
        Evaluator evaluator_2 = ef.create_evaluator(evaluator_2_addr, "evaluator_2", "javascript", 25);
        add_user(evaluator_2_addr, evaluator_2);
    }

    function create_product(address manager_addr, string memory product_name, string memory product_description, uint256 dev, uint256 rev, string memory expertise_category) public{
        require(is_user_valid(manager_addr, 0), "invalid user address");
        require(!valid_products[product_name], "the product name is not unique");
        Product prod = pf.create_product(manager_addr, product_name, product_description, dev, rev, expertise_category);
        name_products[product_name] = prod;
        prod_names.push(product_name);
        valid_products[product_name] = true;
        prod_structs.push(get_product_struct(product_name));
    }

    function deposit(string memory prod_name, address financer_addr, uint256 amount) public {
        require(valid_products[prod_name], "you must provide a valid product name");
        require(is_user_valid(financer_addr, 1), "invalid user address");
        address manager_addr = name_products[prod_name].manager();
        address recipient = address(addresses_users[manager_addr]);
        User sender = addresses_users[financer_addr];
        sender.transfer(recipient, amount);
        Product prod = name_products[prod_name];
        prod.deposit(financer_addr, amount);
    }

    function withdraw(string memory prod_name, address financer_addr, uint256 amount) public {
        require(valid_products[prod_name], "you must provide a valid product name");
        require(is_user_valid(financer_addr, 1), "invalid user addr");
        address recipient = address(addresses_users[financer_addr]);
        Product prod = name_products[prod_name];
        User sender = addresses_users[prod.manager()];
        sender.transfer(recipient, amount);
        prod.withdraw(financer_addr, amount);
    }

    function cancel(address manager_addr, string memory prod_name) public {
        require(valid_products[prod_name], "you must provide a valid product name");
        require(is_user_valid(manager_addr, 0), "invalid user addr");
        require(manager_addr == name_products[prod_name].manager(), "the manager you provided is not in charge of this project");
        Product prod = name_products[prod_name];
        address[] memory depositors = prod.get_depositors();
        User sender = addresses_users[prod.manager()];
        for(uint i = 0; i < depositors.length; i++) {
            address recipient = address(addresses_users[depositors[i]]);
            uint amount = prod.get_contribution(depositors[i]);
            sender.transfer(recipient, amount);
        }
        prod.cancel();
    }

    function apply_freelancer(address freelancer_addr, string memory prod_name, uint256 amount) public {
        require(valid_products[prod_name], "you must provide a valid product name");
        require(is_user_valid(freelancer_addr, 2), "invalid user addr");
        Product prod = name_products[prod_name];
        User freelancer = addresses_users[freelancer_addr];
        require(compare_strings(freelancer.expertise_category(), prod.expertise_category()), "you cannot apply for a project in this category");
        prod.dev_apply(freelancer_addr, amount);
    }

    function register_evaluator(address evaluator_addr, string memory prod_name) public {
        require(valid_products[prod_name], "you must provide a valid product name");
        require(is_user_valid(evaluator_addr, 3), "invalid user addr");
        Product prod = name_products[prod_name];
        User evaluator = addresses_users[evaluator_addr];
        require(compare_strings(evaluator.expertise_category(), prod.expertise_category()), "you cannot apply for a project in this category");
        prod.set_evaluator(evaluator_addr);
    }

    function select_team(string memory prod_name, address[] memory team) public{
        require(valid_products[prod_name], "you must provide a valid product name");
        Product prod = name_products[prod_name];
        for(uint i = 0; i < team.length; i++) {
            require(valid_addresses[team[i]], "one of the team members is not a valid user");
            require(addresses_users[team[i]].user_type() == 2, "one of the team members is not a freelancer");
        }
        prod.select_team(team);
    }

    function notify_manager_of_product(string memory prod_name, string memory message) public {
        require(valid_products[prod_name], "you must provide a valid product name");
        Product prod = name_products[prod_name];
        add_notification(prod.manager(), message);
    }

    function accept_product(string memory prod_name, uint256 notification_id) public {
        require(valid_products[prod_name], "you must provide a valid product name");
        Product prod = name_products[prod_name];
        address[] memory team = prod.get_selected_team();
        User manager = addresses_users[prod.manager()];
        for(uint i = 0; i < team.length; i++) {
            User team_member = addresses_users[team[i]];
            manager.transfer(address(team_member), prod.applicant_amounts(team[i]));
            team_member.increment_reputation();
        }
        prod.finish();
        remove_notification(prod.manager(), notification_id);
    }

    function refuse_product(string memory prod_name, string memory message, uint256 notification_id) public {
        require(valid_products[prod_name], "you must provide a valid product name");
        Product prod = name_products[prod_name];
        require(prod.evaluator() != address(0), "the evaluator was not set");
        add_notification(prod.evaluator(), message);
        remove_notification(prod.manager(), notification_id);

    }

    function arbitrage_accept(string memory prod_name, uint256 notification_id) public {
        require(valid_products[prod_name], "you must provide a valid product name");
        Product prod = name_products[prod_name];
        address[] memory team = prod.get_selected_team();
        User manager = addresses_users[prod.manager()];
        for(uint i = 0; i < team.length; i++) {
            User team_member = addresses_users[team[i]];
            manager.transfer(address(team_member), prod.applicant_amounts(team[i]));
            team_member.increment_reputation();
        }
        manager.decrement_reputation();
        address evaluator = address(addresses_users[prod.evaluator()]);
        manager.transfer(evaluator, prod.rev());
        prod.finish();
        remove_notification(prod.evaluator(), notification_id);
    }

    function arbitrage_deny(string memory prod_name, uint256 notification_id) public {
        require(valid_products[prod_name], "you must provide a valid product name");
        Product prod = name_products[prod_name];
        prod.reset_team();
        remove_notification(prod.evaluator(), notification_id);
    }

    function get_users() public view returns (User_Struct[] memory) {
        return user_structs;
    }

    function get_products() public view returns (Product_Struct[] memory) {
        return prod_structs;
    }

    function get_notifications(address user_addr) public view returns(Notification_Struct[] memory) {
        return notifications[user_addr];
    }

    function get_depositor_amount(string memory prod_name, address depositor_addr) public view returns (uint256) {
        return name_products[prod_name].deposited_amounts(depositor_addr);
    }

    function get_applicant_amount(string memory prod_name, address applicant_addr) public view returns (uint256) {
        return name_products[prod_name].applicant_amounts(applicant_addr);
    }

    function get_user_struct(address user_addr) private view returns (User_Struct memory) {
        User_Struct memory result;
        User user = addresses_users[user_addr];
        result.name = user.name();
        result.reputation = user.reputation();
        result.expertise = user.expertise_category();
        result.addr = user_addr;
        result.balance = user.get_balance();

        if(user.user_type() == 0) {
            result.user_type = "MANAGER";
        } else if(user.user_type() == 1) {
            result.user_type = "FINANCER";
        } else if(user.user_type() == 2) {
            result.user_type = "FREELANCER";
        } else {
            result.user_type = "EVALUATOR";
        }

        return result;
    }

    function get_product_struct(string memory name) private view returns (Product_Struct memory) {
        Product prod = name_products[name];
        Product_Struct memory result;
        result.name = prod.name();
        result.description = prod.description();
        result.dev = prod.dev();
        result.rev = prod.rev();
        result.expertise = prod.expertise_category();
        result.manager = prod.manager();
        result.state = prod.get_state();
        result.depositors = prod.get_depositors();
        result.team = prod.get_selected_team();
        result.evaluator = prod.evaluator();
        result.total_amount = prod.total_amount();

        return result;
    }

    function compare_strings(string memory a, string memory b) private pure returns (bool) {
        return keccak256(bytes(a)) == keccak256(bytes(b));
    }

    function add_notification(address addr, string memory message) private {
        Notification_Struct memory notif;
        notif.message = message;
        notif.id = current_notification_id;
        current_notification_id++;
        notifications[addr].push(notif);
        notification_indexes[notif.id] = notifications[addr].length;
    }

    function remove_notification(address addr, uint256 id) private {
        notifications[addr][notification_indexes[id] - 1] = notifications[addr][notifications[addr].length - 1];
        notification_indexes[notifications[addr][notifications[addr].length - 1].id] = notification_indexes[id];
        notifications[addr].pop();
        notification_indexes[id] = 0;
    }

    function add_user(address addr, User user) private {
        addresses_users[addr] = user;
        user_addresses.push(addr);
        valid_addresses[addr] = true;
        user_structs.push(get_user_struct(addr));
    }

    function is_user_valid(address addr, uint8 user_type) private view returns (bool) {
        return valid_addresses[addr] && addresses_users[addr].user_type() == user_type;
    }
}