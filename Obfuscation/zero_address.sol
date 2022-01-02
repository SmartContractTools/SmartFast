contract Transfertozeroaddress {
    address owner;
    function bad() {
		address aa = 0x0;
		aa.transfer(msg.value);
    }
    function bad1() {
		address aa = address(0x0);
		aa.transfer(msg.value);
    }
    function bad2() {
		address aa = address(0);
		aa.transfer(msg.value);
    }
    function bad3() {
		address(0).transfer(msg.value);
    }
    function bad4() {
		address(0x0).transfer(msg.value);
    }
    function good() {
		address aa = 0x0;
		if(aa != 0x0) {revert();}
		aa.transfer(msg.value);
    }
    function good1() {
		address aa = 0x0;
		if(aa != address(0x0)) {address pp = owner; revert();}
		aa.transfer(msg.value);
    }
    function good2() {
		address aa = 0x0;
		if(aa != address(0)) {revert();}
		aa.transfer(msg.value);
    }
}
