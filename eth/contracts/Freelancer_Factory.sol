pragma solidity >=0.7.0 <0.8.0;
import "./Freelancer.sol";
import "./TokenManager.sol";

contract Freelancer_Factory {

    TokenManager public token_manager;

    constructor(TokenManager _token_manager) {
        token_manager = _token_manager;
    }

    function create_freelancer(address addr, string memory name, string memory expertise, uint256 balance) public returns(Freelancer) {
        Freelancer freelancer = new Freelancer(addr, name, 5, expertise, token_manager.token());
        token_manager.transfer(address(freelancer), balance);
        return freelancer;
    }
}