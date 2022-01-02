contract A{
	address owner;
	mapping(address => uint256) balances;
    constructor() {
		owner = msg.sender;
    }
	function B() returns (uint256){
		address unuseless_value = 0x0;
		uint unuseless_value1 = 0;
		uint unuseless_value2 = 1;
		if(msg.value == 0) {
			return 0;
		}
		balances[msg.sender] += msg.value;
		return balances[msg.sender];
	}
}
