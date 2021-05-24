pragma solidity 0.4.24;

contract Crowdsale {

    address public owner;

    uint rate;
    uint cap;

    constructor() {
        owner = msg.sender;
    }

    modifier onlyOwner {
	require(msg.sender == owner);
	_;
    }

    function setRate(uint _rate) public onlyOwner {
        rate = _rate;
    }

    function setCap(uint _cap) public {
        require (msg.sender == owner);
        cap = _cap;
    }
}
