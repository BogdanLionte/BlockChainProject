pragma solidity >=0.7.0 <0.8.0;

import "./User.sol";

contract Evaluator is User {

    function user_type() public pure override returns (uint8) {
        return 3;
    }

    constructor (address _addr, string memory _name, uint8 _reputation, string memory _expertise_category, Token _token) {
        require(_reputation >= 1 && _reputation <= 10, "reputation must be between 1 and 10");
        addr = _addr;
        name = _name;
        reputation = _reputation;
        expertise_category = _expertise_category;
        token = _token;
    }
}