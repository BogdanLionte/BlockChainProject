pragma solidity >=0.7.0 <0.8.0;

import "./Product.sol";

contract Product_Factory {

    String_Utils private s;

    function create_product(string memory manager_name, string memory product_name, string memory product_description, uint256 dev, uint256 rev, string memory expertise_category) public returns (Product){
        return new Product(product_name, product_description, dev, rev, expertise_category, manager_name, s);
    }

    constructor(String_Utils _s) {
        s = _s;
    }
}
