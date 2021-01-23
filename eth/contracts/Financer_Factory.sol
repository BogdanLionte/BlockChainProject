pragma solidity >=0.7.0 <0.8.0;
import "./Financer.sol";
import "./TokenManager.sol";

contract Financer_Factory {

    String_Utils s;
    TokenManager public token_manager;

    constructor(String_Utils _s, TokenManager _token_manager) {
        s = _s;
        token_manager = _token_manager;
    }

    function create_financer(string memory name, uint256 balance) public returns (Financer) {
        Financer financer = new Financer(name, token_manager.token(), s);
        token_manager.transfer(address(financer), balance);
        return financer;
    }
}
