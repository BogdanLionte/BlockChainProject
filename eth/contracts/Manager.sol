pragma solidity >=0.7.0 <0.8.0;

import "./User.sol";

contract Manager is User {

    function user_type() public pure override returns (uint8) {
        return 0;
    }

    constructor (address _addr, string memory _name, uint8 _reputation, Token _token) {
        require(_reputation >= 1 && _reputation <= 10, "reputation must be between 1 and 10");
        addr = _addr;
        name = _name;
        reputation = _reputation;
        token = _token;
    }
}