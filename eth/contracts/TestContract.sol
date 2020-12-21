pragma solidity >=0.4.22 <0.7.0;

pragma experimental ABIEncoderV2;

contract TestContract {

     uint public fundingGoal;

    constructor(uint _fundingGoal) public {
        fundingGoal = _fundingGoal;
    }


    function getFundingGoal() public view returns (uint) {
        return fundingGoal;
    }

}
