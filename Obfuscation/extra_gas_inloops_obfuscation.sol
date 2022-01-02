contract C {
    uint[] aa;
    function f() public {
        uint[] indirect_aa = aa;
        address unuseless_value = 0x0;
        uint unuseless_value1 = 0;
		for(uint a=0; a<indirect_aa.length;a++)
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
