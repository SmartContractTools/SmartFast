pragma solidity 0.4.24;

contract HoneyPot {
    address addr;
    function withdraw() public payable {
        if(!addr.send(42 ether)) {
			revert();
		}
    }
	
}
