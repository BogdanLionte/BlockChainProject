pragma solidity >=0.7.0 <0.8.0;
import "./Financer.sol";
import "./TokenManager.sol";

contract Financer_Factory {

    TokenManager public token_manager;

    constructor(TokenManager _token_manager) {
        token_manager = _token_manager;
    }

    function create_financer(address addr, string memory name, uint256 balance) public returns (Financer) {
        Financer financer = new Financer(addr, name, token_manager.token());
        token_manager.transfer(address(financer), balance);
        return financer;
    }
}