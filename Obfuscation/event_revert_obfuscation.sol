contract Callbeforerevert {
    address owner;
    uint aa;
    event EventName(address bidder, uint amount);
    function bad() public {
    	bool unuseless_value1 = false;
		uint unuseless_value2 = 0;
		emit EventName(msg.sender, msg.value); 
		address unuseless_value3 = 0x0;
		revert();
    }
    function bad1() public {
		emit EventName(msg.sender, msg.value); 
		throw;
    }
    function bad2() public {
		if(msg.sender == owner) {
		    emit EventName(msg.sender, msg.value); 
		    throw;
		}
    }
    function bad3() public {
    	bool flag = true;
		while(flag) {
			flag = false;
		    emit EventName(msg.sender, msg.value); 
		    throw;
		}
    }
    function bad4() public {
		if(msg.sender == owner) {
		    emit EventName(msg.sender, msg.value); 
		    revert();
		}
    }
    function good() public {
	if(msg.sender == owner) {
	    emit EventName(msg.sender, msg.value); 
	    if(aa == 1) {
	        revert();
	    }
	}
    }
    function good1() public {
		if(msg.sender == owner) {
		    emit EventName(msg.sender, msg.value); 
		    if(aa == 1) {
		        throw;
		    }
		}
    }
}
