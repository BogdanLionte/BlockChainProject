pragma solidity >=0.7.0 <0.8.0;
import "Manager.sol";
import "TokenManager.sol";

contract Manager_Factory {

    String_Utils s;
    TokenManager public token_manager;

    constructor(String_Utils _s, TokenManager _token_manager) {
        s = _s;
        token_manager = _token_manager;
    }

    function create_manager(string memory name, uint256 balance) public returns (Manager) {
        Manager manager = new Manager(name, 5, token_manager.token(), s);
        token_manager.transfer(address(manager), balance);
        return manager;
    }
}