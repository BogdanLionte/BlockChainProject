pragma solidity >=0.7.0 <0.8.0;
import "./Freelancer.sol";
import "./TokenManager.sol";

contract Freelancer_Factory {

    String_Utils s;
    TokenManager public token_manager;

    constructor(String_Utils _s, TokenManager _token_manager) {
        s = _s;
        token_manager = _token_manager;
    }

    function create_freelancer(string memory name, string memory expertise, uint256 balance) public returns(Freelancer) {
        Freelancer freelancer = new Freelancer(name, 5, expertise, token_manager.token(), s);
        token_manager.transfer(address(freelancer), balance);
        return freelancer;
    }
}
