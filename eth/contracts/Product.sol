pragma solidity >=0.7.0 <0.8.0;
import "./Manager.sol";
pragma experimental ABIEncoderV2;

contract Product {
    enum State {
        Financing,
        Choosing,
        Developing,
        Done,
        Canceled
    }

    struct Name_Set {
        string[] names;
        mapping(string => bool) is_in;
        mapping(string => uint256) indexes;
    }


    string private name;
    string private description;
    uint256 private dev;
    uint256 public rev;
    string public expertise_category;
    string public manager;
    State private state;
    mapping (string => uint256) private deposited_amounts;
    uint256 private total_amount;
    Name_Set private depositors;
    Name_Set private applicants;
    mapping (string => uint256) public applicant_amounts;
    string public evaluator;
    string[] private selected_team;
    mapping (string => bool) private valid_team_names;
    String_Utils private s;

    constructor(string memory _name, string memory _description, uint256 _dev, uint256 _rev, string memory _expertise_category, string memory _manager, String_Utils _s) {
        name = _name;
        description = _description;
        dev = _dev;
        rev = _rev;
        expertise_category = _expertise_category;
        manager = _manager;
        state = State.Financing;
        s = _s;
    }

    function reset_team() public {
        require(state == State.Developing, "the team must have already been chosen in order to reset it");
        state = State.Choosing;
        delete selected_team;
    }

    function finish() public {
        require(state == State.Developing, "you cannot finish a product unless you have started developing it");
        state = State.Done;
    }

    function get_selected_team() public view returns (string[] memory) {
        return selected_team;
    }

    function select_team(string[] memory team) public {
        require(state == State.Choosing, "you cannot select a team in this state");
        uint team_sum = 0;
        for(uint i = 0; i < team.length; i++) {
            team_sum += applicant_amounts[team[i]];
            valid_team_names[team[i]] = true;
        }
        require(team_sum == dev, "you chose a team that is too costly or too cheap");
        selected_team = team;
        state = State.Developing;
    }

    function is_valid_team_member(string memory team_member_name) public view returns (bool) {
        return valid_team_names[team_member_name];
    }

    function get_depositors() public view returns(string[] memory) {
        return depositors.names;
    }

    function set_evaluator(string memory _evaluator) public{
        evaluator = _evaluator;
    }

    function deposit(string memory depositor, uint256 amount) public{
        require(state == State.Financing, "you cannot deposit in this phase");
        deposited_amounts[depositor] += amount;
        total_amount += amount;

        add_name_to_set(depositor, depositors);

        if(total_amount >= rev + dev) {
            state = State.Choosing;
        }
    }

    function dev_apply(string memory applicant, uint256 amount) public {
        require(state == State.Choosing, "you cannot apply in this phase");
        require(amount <= dev, "you cannot demand more than the total development amount");
        applicant_amounts[applicant] = amount;
        add_name_to_set(applicant, applicants);
    }

    function withdraw(string memory depositor, uint256 amount) public {
        require(state == State.Financing, "you cannot withdraw in this state");
        deposited_amounts[depositor] -= amount;
        total_amount -= amount;
        if(deposited_amounts[depositor] == 0) {
            remove_name_from_set(depositor, depositors);
        }
    }

    function cancel() public{
        require(state == State.Financing, "The product can only be canceled during the financing phase");
        state = State.Canceled;
        for(uint i = 0; i < depositors.names.length; i++) {
            deposited_amounts[depositors.names[i]] = 0;
            depositors.is_in[depositors.names[i]] = false;
            depositors.indexes[depositors.names[i]] = 0;
        }
        delete depositors.names;
    }

    function get_contribution(string memory contributor) public view returns (uint256) {
        return deposited_amounts[contributor];
    }

    function add_name_to_set(string memory new_name, Name_Set storage name_set) private {
        if(!name_set.is_in[new_name]) {
            name_set.names.push(new_name);
            name_set.is_in[new_name] = true;
            name_set.indexes[new_name] = name_set.names.length; //save the incremented index in this mapping in order to distinguish for 0 values
        }
    }

    function remove_name_from_set(string memory old_name, Name_Set storage name_set) private {
        if(name_set.is_in[old_name]) {
            uint256 index = name_set.indexes[old_name] - 1;
            name_set.names[index] = name_set.names[name_set.names.length - 1];
            name_set.names.pop();
            name_set.is_in[old_name] = false;
            name_set.indexes[old_name] = 0;
        }
    }

    function compare_strings(string memory a, string memory b) private pure returns (bool) {
        return keccak256(bytes(a)) == keccak256(bytes(b));
    }

    function to_string() public view returns (string memory) {
        string memory json = "{\n\"name\": \"";
        json = s.concatenate(json, name);
        json = s.concatenate(json, "\", \n\"description\": \"");
        json = s.concatenate(json, description);
        json = s.concatenate(json, "\", \n\"dev\": ");
        json = s.concatenate(json, s.uint2str(dev));
        json = s.concatenate(json, ", \n\"rev\": ");
        json = s.concatenate(json, s.uint2str(rev));
        json = s.concatenate(json, ", \n\"expertise\": \"");
        json = s.concatenate(json, expertise_category);
        json = s.concatenate(json, "\", \n\"manager\": \"");
        json = s.concatenate(json, manager);
        json = s.concatenate(json, "\", \n\"evaluator\": \"");
        json = s.concatenate(json, evaluator);
        json = s.concatenate(json, "\", \n\"state\": \"");
        if(state == State.Financing) {
            json = s.concatenate(json, "Financing");
        }
        else if(state == State.Choosing) {
            json = s.concatenate(json, "Choosing");
        }
        else if(state == State.Done) {
            json = s.concatenate(json, "Done");
        }
        else if(state == State.Developing){
            json = s.concatenate(json, "Developing");
        }
        else if(state == State.Done) {
            json = s.concatenate(json, "Done");
        }
        else {
            json = s.concatenate(json, "Canceled");
        }

        json = s.concatenate(json, "\", \n\"deposited_amounts\": {");
        if(depositors.names.length > 0){
            for(uint i = 0; i < depositors.names.length - 1; i++) {
                json = s.concatenate(json, "\n\"");
                json = s.concatenate(json, depositors.names[i]);
                json = s.concatenate(json, "\": ");
                json = s.concatenate(json, s.uint2str(deposited_amounts[depositors.names[i]]));
                json = s.concatenate(json, ", ");
            }


            json = s.concatenate(json, "\n\"");
            json = s.concatenate(json, depositors.names[depositors.names.length - 1]);
            json = s.concatenate(json, "\": ");
            json = s.concatenate(json, s.uint2str(deposited_amounts[depositors.names[depositors.names.length - 1]]));
        }

        json = s.concatenate(json, "\n}, \n\"total_amount\": ");
        json = s.concatenate(json, s.uint2str(total_amount));
        json = s.concatenate(json, "\", \n\"applicant_amounts\": {");

        if(applicants.names.length > 0){
            for(uint i = 0; i < applicants.names.length - 1; i++) {
                json = s.concatenate(json, "\n\"");
                json = s.concatenate(json, applicants.names[i]);
                json = s.concatenate(json, "\": ");
                json = s.concatenate(json, s.uint2str(applicant_amounts[applicants.names[i]]));
                json = s.concatenate(json, ", ");
            }


            json = s.concatenate(json, "\n\"");
            json = s.concatenate(json, applicants.names[applicants.names.length - 1]);
            json = s.concatenate(json, "\": ");
            json = s.concatenate(json, s.uint2str(applicant_amounts[applicants.names[applicants.names.length - 1]]));
        }

        json = s.concatenate(json, "\n}, \n\"selected_team\": [");

        if(selected_team.length > 0) {
            json = s.concatenate(json, "\"");
            for(uint i = 0; i < selected_team.length - 1; i++) {
                json = s.concatenate(json, selected_team[i]);
                json = s.concatenate(json, "\", \"");
            }
            json = s.concatenate(json, selected_team[selected_team.length - 1]);
            json = s.concatenate(json, "\"");
        }
        json = s.concatenate(json, "]\n");

        json = s.concatenate(json, "\n}");

        return json;
    }
}
