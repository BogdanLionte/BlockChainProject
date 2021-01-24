pragma solidity >=0.7.0 <0.8.0;
import "./Token.sol";

abstract contract  User {

    string public name;

    Token internal token;

    uint8 public reputation;

    string public expertise_category;

    address public addr;

    function increment_reputation() public {
        if(reputation < 10) {
            reputation++;
        }
    }

    function decrement_reputation() public {
        if(reputation > 1) {
            reputation--;
        }
    }

    function transfer(address to, uint256 amount) public {
        token.transfer(to, amount);
    }

    function get_balance() public view returns(uint){
        return token.balanceOf(address(this));
    }

    function user_type() public pure virtual returns (uint8);
}