pragma solidity >=0.7.0 <0.8.0;
import "Evaluator.sol";
import "TokenManager.sol";

contract Evaluator_Factory {

    String_Utils s;
    TokenManager public token_manager;

    constructor(String_Utils _s, TokenManager _token_manager) {
        s = _s;
        token_manager = _token_manager;
    }

    function create_evaluator(string memory name, string memory expertise, uint256 balance) public returns(Evaluator) {
        Evaluator evaluator = new Evaluator(name, 5, expertise, token_manager.token(), s);
        token_manager.transfer(address(evaluator), balance);
        return evaluator;
    }
}