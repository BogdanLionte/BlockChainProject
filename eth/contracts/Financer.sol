pragma solidity >=0.7.0 <0.8.0;

import "./User.sol";

contract Financer is User {

    function user_type() public pure override returns (uint8) {
        return 1;
    }

    constructor (address _addr, string memory _name, Token _token) {
        addr = _addr;
        name = _name;
        token = Token(_token);
    }
}