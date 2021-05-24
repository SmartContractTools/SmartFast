contract A{
	address owner;
	mapping(address => uint256) balances;
    constructor() {
		owner = msg.sender;
    }
	function B() returns (uint256){
		if(msg.value == 0) {
			return 0;
		}
		balances[msg.sender] += msg.value;
		return balances[msg.sender];
	}
}
