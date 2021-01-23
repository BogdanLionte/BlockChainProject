pragma solidity >=0.7.0 <0.8.0;
import "./Token.sol";
import "./String_Utils.sol";

abstract contract  User {

    string internal name;

    Token internal token;

    bool public was_notified;

    uint8 internal reputation;

    string public expertise_category;

    String_Utils internal s;

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

    function notify() public {
        was_notified = true;
    }

    function denotify() public {
        was_notified = false;
    }

    function transfer(address to, uint256 amount) public {
        token.transfer(to, amount);
    }

    function to_string() public view virtual returns (string memory);

    function user_type() public pure virtual returns (string memory);
}
