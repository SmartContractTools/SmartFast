//pragma solidity ^0.4.24;

contract TxOrigin {

    address owner;

    constructor() { owner = msg.sender; }

    modifier onlyOwner {
        require(tx.origin == owner);
        _;	
    }

    function bug0() {
        require(tx.origin == owner);
    }

    function bug2() {
        if (tx.origin == owner) {
            revert();
        }
    }

    function bug3() {
        if ((tx.origin != owner) || (tx.origin != msg.sender)) {
            revert();
        }
    }

    function bug4() {
        assert(tx.origin != owner);
    }

    function bug5() {
        while(tx.origin != owner)
    	{
    	    break;
    	}
    }

    function bug6() {
	   address medi = tx.origin;
        require(medi == owner);
    }

    function legit0(){
        require(tx.origin == msg.sender);
    }
    
    function legit1(){
        tx.origin.transfer(address(this).balance);
    }
}
