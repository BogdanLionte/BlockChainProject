pragma solidity >=0.7.0 <0.8.0;

import "User.sol";

contract Financer is User {


    function to_string() public view override returns (string memory) {
        string memory json;
        json = "{\n\"name\": \"";
        json = s.concatenate(json, name);
        json = s.concatenate(json, "\", \n\"type\": \"FINANCER\", \n\"balance\": ");
        json = s.concatenate(json, s.uint2str(token.balanceOf(address(this))));
        json = s.concatenate(json, "\n}");
        return json;
    }

    function user_type() public pure override returns (string memory) {
        return "FINANCER";
    }

    constructor (string memory _name, Token _token, String_Utils _s) {
        name = _name;
        token = Token(_token);
        s = String_Utils(_s);
    }
}