pragma solidity >=0.7.0 <0.8.0;
import "./Token.sol";

// contract responsible for the initial dissemination of the tokens
contract TokenManager {

    Token public token;

    constructor() {
        token = new Token(1000);
    }

    function transfer(address to, uint256 amount) public {
        token.transfer(to, amount);
    }
}
