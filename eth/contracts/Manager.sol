pragma solidity >=0.7.0 <0.8.0;

import "./User.sol";

contract Manager is User {

    function to_string() public view override returns (string memory) {
        string memory json;
        json = "{\n\"name\": \"";
        json = s.concatenate(json, name);
        json = s.concatenate(json, "\" , \n\"reputation\": ");
        json = s.concatenate(json, s.uint2str(reputation));
        json = s.concatenate(json, ", \n\"type\": \"MANAGER\" , \n\"notified\": ");
        if(was_notified) {
            json = s.concatenate(json, "true, \n\"balance\": ");
        }
        else {
            json = s.concatenate(json, "false, \n\"balance\": ");
        }
        json = s.concatenate(json, s.uint2str(token.balanceOf(address(this))));
        json = s.concatenate(json, "\n}");
        return json;
    }

    function user_type() public pure override returns (string memory) {
        return "MANAGER";
    }

    constructor (string memory _name, uint8 _reputation, Token _token, String_Utils _s) {
        require(_reputation >= 1 && _reputation <= 10, "reputation must be between 1 and 10");
        name = _name;
        reputation = _reputation;
        token = _token;
        s = _s;
    }
}
