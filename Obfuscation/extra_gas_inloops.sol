contract C {
    uint[] aa;
    function f() public {
		for(uint a=0; a<aa.length;a++)
		{
			uint c = aa[a];
		}
    }
    function g() public {
		for(uint a=0; a<msg.sender.balance;a++)
		{
			uint c = aa[a];
		}
    }

    uint[5] T = [1,2,3,4,5];
    function numbers() constant public returns (uint) {
        uint num = 0;
        for(uint i = 0; i < T.length; i++) {
            num = num + T[i];
        }
        return num;
    }
}
