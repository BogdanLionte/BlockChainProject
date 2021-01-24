pragma solidity >=0.7.0 <0.8.0;

import "./Product.sol";

contract Product_Factory {

    function create_product(address manager_addr, string memory product_name, string memory product_description, uint256 dev, uint256 rev, string memory expertise_category) public returns (Product){
        return new Product(product_name, product_description, dev, rev, expertise_category, manager_addr);
    }
}