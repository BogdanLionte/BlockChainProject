pragma solidity >=0.7.0 <0.8.0;
pragma experimental ABIEncoderV2;

contract Product {
    enum State {
        Financing,
        Choosing,
        Developing,
        Done,
        Canceled
    }

    struct Address_Set {
        address[] addresses;
        mapping(address => bool) is_in;
        mapping(address => uint256) indexes;
    }


    string public name;
    string public description;
    uint256 public dev;
    uint256 public rev;
    string public expertise_category;
    address public manager;
    State private state;
    mapping (address => uint256) public deposited_amounts;
    uint256 public total_amount;
    Address_Set private depositors;
    Address_Set private applicants;
    mapping (address => uint256) public applicant_amounts;
    address public evaluator;
    address[] private selected_team;
    mapping (address => bool) private valid_team_addresses;
    bool private arbitrage;

    constructor(string memory _name, string memory _description, uint256 _dev, uint256 _rev, string memory _expertise_category, address _manager) {
        name = _name;
        description = _description;
        dev = _dev;
        rev = _rev;
        expertise_category = _expertise_category;
        manager = _manager;
        state = State.Financing;
    }

    function set_arbitrage(bool _arbitrage) public {
        arbitrage = _arbitrage;
    }

    function get_arbitrage() public view returns(bool){
        return arbitrage;
    }

    function get_state() public view returns (string memory) {
        if(state == State.Financing) {
            return "FINANCING";
        }else if(state == State.Choosing) {
            return "CHOOSING";
        }else if(state == State.Developing) {
            return "DEVELOPING";
        }else if(state == State.Done) {
            return "DONE";
        }else {
            return "CANCELED";
        }
    }

    function reset_team() public {
        require(state == State.Developing, "the team must have already been chosen in order to reset it");
        state = State.Choosing;
        for(uint i = 0; i < selected_team.length; i++) {
            valid_team_addresses[selected_team[i]] = false;
        }
        delete selected_team;
    }

    function finish() public {
        require(state == State.Developing, "you cannot finish a product unless you have started developing it");
        state = State.Done;
    }

    function get_selected_team() public view returns (address[] memory) {
        return selected_team;
    }

    function get_applicants() public view returns (address[] memory) {
        return applicants.addresses;
    }

    function select_team(address[] memory team) public {
        require(state == State.Choosing, "you cannot select a team in this state");
        uint team_sum = 0;
        for(uint i = 0; i < team.length; i++) {
            require(applicants.is_in[team[i]], "you cannot select a freelancer who did not apply");
            team_sum += applicant_amounts[team[i]];
            valid_team_addresses[team[i]] = true;
        }
        require(team_sum == dev, "you chose a team that is too costly or too cheap");
        selected_team = team;
        state = State.Developing;
    }

    function is_valid_team_member(address team_member_addr) public view returns (bool) {
        return valid_team_addresses[team_member_addr];
    }

    function get_depositors() public view returns(address[] memory) {
        return depositors.addresses;
    }

    function set_evaluator(address _evaluator) public{
        evaluator = _evaluator;
    }

    function deposit(address depositor, uint256 amount) public{
        require(state == State.Financing, "you cannot deposit in this phase");
        deposited_amounts[depositor] += amount;
        total_amount += amount;

        add_addr_to_set(depositor, depositors);

        if(total_amount >= rev + dev) {
            state = State.Choosing;
        }
    }

    function dev_apply(address applicant, uint256 amount) public {
        require(state == State.Choosing, "you cannot apply in this phase");
        require(amount <= dev, "you cannot demand more than the total development amount");
        applicant_amounts[applicant] = amount;
        add_addr_to_set(applicant, applicants);
    }

    function withdraw(address depositor, uint256 amount) public {
        require(state == State.Financing, "you cannot withdraw in this state");
        require(amount <= deposited_amounts[depositor], "you cannot withdraw more than you deposited!");
        deposited_amounts[depositor] -= amount;
        total_amount -= amount;
        if(deposited_amounts[depositor] == 0) {
            remove_addr_from_set(depositor, depositors);
        }
    }

    function cancel() public{
        require(state == State.Financing, "The product can only be canceled during the financing phase");
        state = State.Canceled;
        for(uint i = 0; i < depositors.addresses.length; i++) {
            deposited_amounts[depositors.addresses[i]] = 0;
            depositors.is_in[depositors.addresses[i]] = false;
            depositors.indexes[depositors.addresses[i]] = 0;
        }
        delete depositors.addresses;
    }

    function get_contribution(address contributor) public view returns (uint256) {
        return deposited_amounts[contributor];
    }

    function add_addr_to_set(address new_addr, Address_Set storage addr_set) private {
        if(!addr_set.is_in[new_addr]) {
            addr_set.addresses.push(new_addr);
            addr_set.is_in[new_addr] = true;
            addr_set.indexes[new_addr] = addr_set.addresses.length; //save the incremented index in this mapping in order to distinguish for 0 values
        }
    }

    function remove_addr_from_set(address old_addr, Address_Set storage addr_set) private {
        if(addr_set.is_in[old_addr]) {
            uint256 index = addr_set.indexes[old_addr] - 1;
            addr_set.addresses[index] = addr_set.addresses[addr_set.addresses.length - 1];
            addr_set.addresses.pop();
            addr_set.is_in[old_addr] = false;
            addr_set.indexes[old_addr] = 0;
        }
    }

}