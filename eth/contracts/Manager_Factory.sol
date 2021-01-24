pragma solidity >=0.7.0 <0.8.0;
import "./Manager.sol";
import "./TokenManager.sol";

contract Manager_Factory {

    TokenManager public token_manager;

    constructor(TokenManager _token_manager) {
        token_manager = _token_manager;
    }

    function create_manager(address addr, string memory name, uint256 balance) public returns (Manager) {
        Manager manager = new Manager(addr, name, 5, token_manager.token());
        token_manager.transfer(address(manager), balance);
        return manager;
    }
}