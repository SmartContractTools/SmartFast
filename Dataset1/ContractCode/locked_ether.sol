pragma solidity ^0.4.24;
contract Locked{

    function receive() payable public{
        require(msg.value > 0);
    }

}

contract Send{
    address owner = msg.sender;
    
    function withdraw() public{	
        owner.transfer(address(this).balance);
    }
}

contract Unlocked is Locked, Send{

    function withdraw() public{
        super.withdraw();
    }
}

contract OnlyLocked is Locked{ }

contract testbase{
    address owner = msg.sender;
    function withdraw() public{	
        owner.transfer(address(this).balance);
    }
}

contract test is testbase{
    function withdraw() public{
    }

    function receive() payable public{
        require(msg.value > 0);
    }
}

contract test1{
    function callvaluerequire(address _receiver) payable external {
        require(_receiver.call.value(0).gas(7777)(""));
    }

    function receive() payable public{
        require(msg.value > 0);
    }
}

contract test2{

    function callvaluerequire(address _receiver) payable external {
	//(uint sendvalue,uint sendvalue1) = (0,1);
        _receiver.transfer(sendvalue);
    }

    uint sendvalue = 0;
    
    function receive() payable public{
        require(msg.value > 0);
    }
}

contract test3{
    function callvaluerequire(address _receiver) payable external {
        _receiver.transfer(0);
    }

    function receive() payable public{
        require(msg.value > 0);
    }
}

contract test4{

    function returnvalue() returns(uint,uint) {
	return (1,1);
    }

    function callvaluerequire(address _receiver) payable external {
	uint sendvalue = 0;
	uint sendvalue1 = 1;
        (sendvalue,sendvalue1) = returnvalue();
	_receiver.transfer(sendvalue);
    }
    
    function receive() payable public{
        require(msg.value > 0);
    }
}

contract test5{

    function() payable {}
}
