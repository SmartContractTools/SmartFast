contract Test{

    address destination;
    address owner;

    mapping (address => uint) balances;

    constructor(){
        balances[msg.sender] = 0;
	owner = msg.sender;
    }

    function direct() public{ //bad
        msg.sender.send(address(this).balance);
    }

    function init() public{
        destination = msg.sender;
    }

    modifier isowner() {
	address aa = msg.sender;
	require(owner == aa);
	_;
    }

    function indirect() public{ //bad
        destination.send(address(this).balance);
    }

    function directceshi_1() public{
	require(owner == msg.sender);
        destination.send(address(this).balance);
    }

    function directceshi_2() isowner public{
        destination.send(address(this).balance);
    }

    function directceshi_3() public{
        destination.send(msg.value);
    }

    function directceshi_4() public{
        destination.send(balances[msg.sender]);
    }

    function directceshi_5() public{
        destination.send(0);
    }

    function directceshi_6() public{
	uint avalue = 0;
        destination.send(avalue);
    }

    // these are legitimate calls
    // and should not be detected
    function repay() payable public{
        msg.sender.transfer(msg.value);
    }

    function withdraw() public{
        uint val = balances[msg.sender];
        msg.sender.send(val);
    }

    function withdraw_direct() public{
        uint val = msg.value;
        msg.sender.send(val);
    }

    function withdraw_inderect() public{ //bad
        uint val = address(this).balance;
        msg.sender.send(val);
    }

    function indirect_ceshi1() public{ //bad
	address cc = msg.sender;
	cc = owner;
	require(cc == owner);
	address dd = msg.sender;
        uint val = address(this).balance;
        dd.send(val);
    }

    function buy() payable public{
        uint value_send = msg.value;
        uint value_spent = 0 ; // simulate a buy of tokens
        uint remaining = value_send - value_spent;
        msg.sender.send(remaining);
    }

}
