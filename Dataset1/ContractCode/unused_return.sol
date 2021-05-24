//pragma solidity ^0.4.24;

library SafeMath{
    function add(uint a, uint b) public returns(uint){
        return a+b;
    }
}

contract Target{
    uint _c;
    function f() public returns(uint);
    function g(uint a) public {
        _c = a;
    }
}

contract User{

    using SafeMath for uint;

    function test1(uint a,uint b) public returns(uint){
	return a+b;
    }

    function inc_callcode(address _contractAddress) public {
        _contractAddress.callcode(bytes4(keccak256("inc()")));
    }

    function test(Target t) public{
        t.f();
   
        // example with library usage
        uint a=0;
        a.add(0);
    	test1(a,0);
    	a + 0;
    	t.g(a);
    	keccak256("inc()");
    	bytes4(keccak256("inc()"));
        // The value is not used
        // But the detector should not detect it
        // As the value returned by the call is stored
        // (unused local variable should be another issue) 
        uint b = a.add(1);
    	require(true);
    }

    function kill()  {	
        selfdestruct(msg.sender);
    }
}
