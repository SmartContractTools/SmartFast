contract Fallbackoutofgas {
    address owner;
    address[] aa;
    function() { //bad
	owner = msg.sender;
	for(uint i=0; i<aa.length; i++)
	{
	    if(address(this).balance > 1 ether) {
	        aa[i].transfer(1 ether);
	    }
	}
    }
}

contract Inhe is Fallbackoutofgas {
    
}


contract Inhe1 is Fallbackoutofgas {
    function() {revert();} //good
}
