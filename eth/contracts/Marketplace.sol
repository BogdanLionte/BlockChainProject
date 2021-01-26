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
    mapping(address => Notification_Struct[]) private notifications;
    mapping(uint256 => uint) private notification_indexes;
    uint256 current_notification_id;
    User_Struct[] private user_structs;
    Product_Struct[] private prod_structs;
    mapping(string => uint256) prod_struct_indexes;
    mapping(address => uint256) user_struct_indexes;
    Product_Factory pf;

    struct Notification_Struct {
        uint256 id;
        string message;
        string prod_name;
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
        address[] applicants;
        address evaluator;
        uint256 total_amount;
    }

    constructor(Product_Factory _pf, Manager_Factory mf, Evaluator_Factory ef, Freelancer_Factory frf, Financer_Factory fif) {

        pf = _pf;

        address manager_1_addr = 0xec7935d8d2a5846C6185A40eD515EB2114e62842;
        add_user(manager_1_addr, mf.create_manager(manager_1_addr, "manager_1", 75));

        address financer_1_addr = 0x42Ed7f98B64FF779CEcB9f3c3d3ACeA68db6b0a8;
        add_user(financer_1_addr, fif.create_financer(financer_1_addr, "financer_1", 200));

        address financer_2_addr = 0x5c0268F91544C5982Ea72B9Cdd0132C32F2Ae888;
        add_user(financer_2_addr, fif.create_financer(0x129fEb8F88b85A97112A75F22D6C4eCa6d303c10, "financer_2", 300));

        address financer_3_addr = 0xf57CD336f54C8618AbF5129c5A0eC81504052397;
        add_user(financer_3_addr, fif.create_financer(financer_3_addr, "financer_3", 250));

        address freelancer_1_addr = 0xEf21CC357040F16Ef9B2cC760D62CA41487C6d6a;
        add_user(freelancer_1_addr, frf.create_freelancer(freelancer_1_addr, "freelancer_1", "databases", 50));

        address freelancer_2_addr = 0xB1C73A2BCDcfa26e99AC52232F1Cfcb4257295EC;
        add_user(freelancer_2_addr, frf.create_freelancer(freelancer_2_addr, "freelancer_2", "databases", 50));

        address freelancer_3_addr = 0x557Db40E309d7974365Adae786BEbf9bd4f07ECB;
        add_user(freelancer_3_addr, frf.create_freelancer(freelancer_3_addr, "freelancer_3", "javascript", 25));

        address evaluator_1_addr = 0xEd8702aD6b0E6B90706A1f5f5D90a2AFEF0d098A;
        add_user(evaluator_1_addr, ef.create_evaluator(evaluator_1_addr, "evaluator_1", "databases", 25));

        address evaluator_2_addr = 0x1d14897320Fc61E73675Ac3a8A3f3ff88ff5d10E;
        add_user(evaluator_2_addr, ef.create_evaluator(evaluator_2_addr, "evaluator_2", "javascript", 25));
    }

    function create_product(string memory product_name, string memory product_description, uint256 dev, uint256 rev, string memory expertise_category) public{
        address manager_addr = msg.sender;
        validate_user(manager_addr, 0);
        require(address(name_products[product_name]) == address(0), "the product name is not unique");
        Product prod = pf.create_product(manager_addr, product_name, product_description, dev, rev, expertise_category);
        name_products[product_name] = prod;
        prod_structs.push(get_product_struct(product_name));
        prod_struct_indexes[product_name] = prod_structs.length - 1;
    }

    function deposit(string memory prod_name, uint256 amount) public{
        address financer_addr = msg.sender;
        validate_prod(prod_name);
        validate_user(financer_addr, 1);
        address manager_addr = name_products[prod_name].manager();
        transfer(financer_addr, manager_addr, amount);
        Product prod = name_products[prod_name];
        prod.deposit(financer_addr, amount);
        prod_structs[prod_struct_indexes[prod_name]].depositors = prod.get_depositors();
        prod_structs[prod_struct_indexes[prod_name]].state = prod.get_state();
        prod_structs[prod_struct_indexes[prod_name]].total_amount += amount;
    }

    function withdraw(string memory prod_name, uint256 amount) public{
        address financer_addr = msg.sender;
        validate_prod(prod_name);
        validate_user(financer_addr, 1);
        Product prod = name_products[prod_name];
        transfer(prod.manager(), financer_addr, amount);
        prod.withdraw(financer_addr, amount);
        prod_structs[prod_struct_indexes[prod_name]].depositors = prod.get_depositors();
        prod_structs[prod_struct_indexes[prod_name]].total_amount -= amount;
    }

    function cancel(string memory prod_name) public{
        Product prod = name_products[prod_name];
        validate_prod(prod_name);
        require(msg.sender == prod.manager(), "invalid user");
        address[] memory depositors = prod.get_depositors();
        for(uint i = 0; i < depositors.length; i++) {
            uint amount = prod.get_contribution(depositors[i]);
            transfer(prod.manager(), depositors[i], amount);
        }
        prod.cancel();
        prod_structs[prod_struct_indexes[prod_name]].state = prod.get_state();
        prod_structs[prod_struct_indexes[prod_name]].depositors = prod.get_depositors();
    }

    function apply_freelancer(string memory prod_name, uint256 amount) public{
        address freelancer_addr = msg.sender;
        validate_prod(prod_name);
        validate_user(freelancer_addr, 2);
        Product prod = name_products[prod_name];
        User freelancer = addresses_users[freelancer_addr];
        require(compare_strings(freelancer.expertise_category(), prod.expertise_category()), "you cannot apply for a project in this category");
        prod.dev_apply(freelancer_addr, amount);
        prod_structs[prod_struct_indexes[prod_name]].applicants = prod.get_applicants();
    }

    function register_evaluator(string memory prod_name) public{
        address evaluator_addr = msg.sender;
        validate_prod(prod_name);
        validate_user(evaluator_addr, 3);
        Product prod = name_products[prod_name];
        User evaluator = addresses_users[evaluator_addr];
        require(compare_strings(evaluator.expertise_category(), prod.expertise_category()), "you cannot apply for a project in this category");
        require(prod.evaluator() == address(0), "evaluator was already set");
        prod.set_evaluator(evaluator_addr);
        prod_structs[prod_struct_indexes[prod_name]].evaluator = prod.evaluator();
    }

    function select_team(string memory prod_name, address[] memory team) public{
        validate_prod(prod_name);
        Product prod = name_products[prod_name];
        require(msg.sender == prod.manager(), "invalid user");
        for(uint i = 0; i < team.length; i++) {
            validate_user(team[i], 2);
        }
        prod.select_team(team);
        prod_structs[prod_struct_indexes[prod_name]].team = prod.get_selected_team();
        prod_structs[prod_struct_indexes[prod_name]].state = prod.get_state();
    }

    function notify_manager_of_product(string memory prod_name, string memory message) public{
        validate_prod(prod_name);
        Product prod = name_products[prod_name];
        require(prod.is_valid_team_member(msg.sender), "invalid user");
        add_notification(prod.manager(), message, prod_name);
    }

    function accept_product(string memory prod_name, uint256 notification_id) public{
        validate_prod(prod_name);
        Product prod = name_products[prod_name];
        require(msg.sender == prod.manager());
        address[] memory team = prod.get_selected_team();
        User manager = addresses_users[prod.manager()];
        for(uint i = 0; i < team.length; i++) {
            transfer(prod.manager(), team[i], prod.applicant_amounts(team[i]));
            addresses_users[team[i]].increment_reputation();
            user_structs[user_struct_indexes[team[i]]].reputation++;
        }
        prod.finish();
        remove_notification(prod.manager(), notification_id);
        prod_structs[prod_struct_indexes[prod_name]].state = prod.get_state();
        if(prod.get_arbitrage()) {
            transfer(prod.manager(), prod.evaluator(), prod.rev());
        } else {
            manager.increment_reputation();
            user_structs[user_struct_indexes[prod.manager()]].reputation++;
        }
    }

    function refuse_product(string memory prod_name, string memory message, uint256 notification_id) public{
        validate_prod(prod_name);
        Product prod = name_products[prod_name];
        require(msg.sender == prod.manager(), "invalid user");
        require(prod.evaluator() != address(0), "the evaluator was not set");
        add_notification(prod.evaluator(), message, prod_name);
        remove_notification(prod.manager(), notification_id);
        prod.set_arbitrage(true);
    }

    function arbitrage_accept(string memory prod_name, uint256 notification_id) public{
        validate_prod(prod_name);
        Product prod = name_products[prod_name];
        require(msg.sender == prod.evaluator(), "invalid user");
        address[] memory team = prod.get_selected_team();
        User manager = addresses_users[prod.manager()];
        for(uint i = 0; i < team.length; i++) {
            transfer(prod.manager(), team[i], prod.applicant_amounts(team[i]));
            addresses_users[team[i]].increment_reputation();
            user_structs[user_struct_indexes[team[i]]].reputation++;
        }
        manager.decrement_reputation();
        user_structs[user_struct_indexes[prod.manager()]].reputation--;
        transfer(prod.manager(), prod.evaluator(), prod.rev());
        prod.finish();
        remove_notification(prod.evaluator(), notification_id);
        prod_structs[prod_struct_indexes[prod_name]].state = prod.get_state();
    }

    function arbitrage_deny(string memory prod_name, uint256 notification_id) public{
        validate_prod(prod_name);
        Product prod = name_products[prod_name];
        require(msg.sender == prod.evaluator(), "invalid user");
        address[] memory team = prod.get_selected_team();
        for(uint i = 0; i < team.length; i++) {
            addresses_users[team[i]].decrement_reputation();
            user_structs[user_struct_indexes[team[i]]].reputation--;
        }
        prod.reset_team();
        remove_notification(prod.evaluator(), notification_id);
        prod_structs[prod_struct_indexes[prod_name]].state = prod.get_state();
        prod_structs[prod_struct_indexes[prod_name]].team = prod.get_selected_team();
    }

    function get_users() public view returns (User_Struct[] memory) {
        return user_structs;
    }

    function get_products() public view returns (Product_Struct[] memory) {
        return prod_structs;
    }

    function get_notifications(address addr) public view returns(Notification_Struct[] memory) {
        return notifications[addr];
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
        result.applicants = prod.get_applicants();

        return result;
    }

    function compare_strings(string memory a, string memory b) private pure returns (bool) {
        return keccak256(bytes(a)) == keccak256(bytes(b));
    }

    function add_notification(address addr, string memory message, string memory prod_name) private {
        Notification_Struct memory notif;
        notif.message = message;
        notif.id = current_notification_id;
        notif.prod_name = prod_name;
        current_notification_id++;
        notifications[addr].push(notif);
        notification_indexes[notif.id] = notifications[addr].length;
    }

    function remove_notification(address addr, uint256 id) private {
        require(notification_indexes[id] > 0, "notification does not exist");
        notifications[addr][notification_indexes[id] - 1] = notifications[addr][notifications[addr].length - 1];
        notification_indexes[notifications[addr][notifications[addr].length - 1].id] = notification_indexes[id];
        notifications[addr].pop();
        notification_indexes[id] = 0;
    }

    function add_user(address addr, User user) private {
        addresses_users[addr] = user;
        user_structs.push(get_user_struct(addr));
        user_struct_indexes[addr] = user_structs.length - 1;
    }

    function validate_user(address addr, uint8 user_type) private view{
        require(address(addresses_users[addr]) != address(0) && addresses_users[addr].user_type() == user_type, "invalid user");
    }

    function validate_prod(string memory prod_name) private view{
        require(address(name_products[prod_name]) != address(0), "invalid_prod");
    }

    function transfer(address sender, address recipient, uint256 amount) private {
        addresses_users[sender].transfer(address(addresses_users[recipient]), amount);
        user_structs[user_struct_indexes[sender]].balance = addresses_users[sender].get_balance();
        user_structs[user_struct_indexes[recipient]].balance = addresses_users[recipient].get_balance();
    }
}
