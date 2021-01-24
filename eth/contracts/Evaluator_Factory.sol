pragma solidity >=0.7.0 <0.8.0;
import "./Evaluator.sol";
import "./TokenManager.sol";

contract Evaluator_Factory {

    TokenManager public token_manager;

    constructor(TokenManager _token_manager) {
        token_manager = _token_manager;
    }

    function create_evaluator(address addr, string memory name, string memory expertise, uint256 balance) public returns(Evaluator) {
        Evaluator evaluator = new Evaluator(addr, name, 5, expertise, token_manager.token());
        token_manager.transfer(address(evaluator), balance);
        return evaluator;
    }
}
