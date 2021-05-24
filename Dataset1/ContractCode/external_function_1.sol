
contract InfoFeed {
    function info() payable returns (uint ret) {
		return msg.value;
    }
}
contract Consumer {
    function deposit() payable returns (uint ret) {
		return msg.value;
    }
    function left() constant returns (uint ret) {
		return this.balance;
    }
    function callFeed(address addr) returns (uint ret) {
		return InfoFeed(addr).info.value(1).gas(8000)();
    }
}
