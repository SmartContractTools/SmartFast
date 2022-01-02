//pragma solidity ^0.4.24;


contract Sender {
    address owner;

    modifier onlyceshi() {
	owner.callcode(bytes4(keccak256("inc()")));
	_;
    }

    function send(address _receiver) payable external {
        _receiver.call.value(msg.value).gas(7777)("");
    }

    function sendceshi(address _receiver) payable external {
        if(_receiver.call.value(msg.value).gas(7777)("")){
		revert();
	}
    }

    function sendvalue(address _receiver) payable external {
        if(!_receiver.send(msg.value)){
		revert();
	}
	_receiver.transfer(msg.value);
    }

    function callvalue(address _receiver) payable external {
        if(_receiver.call.value(msg.value).gas(7777)("")){
		revert();
	}
    }

    function diaoyong (bool returnvalue){
	require(returnvalue);
    }

    function sendvaluerequire(address _receiver) payable external {
        require(_receiver.send(msg.value));
    }

    function callvaluerequire(address _receiver) payable external {
        require(_receiver.call.value(msg.value).gas(7777)(""));
    }

    function sendvalueassert(address _receiver) payable external {
        assert(_receiver.send(msg.value));
    }

    function callvalueassert(address _receiver) payable external {
        assert(_receiver.call.value(msg.value).gas(7777)(""));
    }

    function sendvaluereturn(address _receiver) payable external returns(bool){
        return _receiver.send(msg.value);
    }

    function callvaluereturn(address _receiver) payable external returns(bool){
        return _receiver.call.value(msg.value).gas(7777)("");
    }

    function functionceshi(address _receiver) payable external {
        diaoyong(_receiver.send(msg.value));
    }

    function sendvalueceshi(address _receiver) payable external {
        _receiver.send(msg.value);
    }

    function callvalueceshi(address _receiver) payable external {
        _receiver.call.value(msg.value).gas(7777)("");
    }

    function inc_callcode(address _contractAddress) public {
        _contractAddress.callcode(bytes4(keccak256("inc()")));
    }

    function inc_delegatecall(address _contractAddress) public {
        _contractAddress.delegatecall(bytes4(keccak256("inc()")));
    }

    function destroy() { // so funds not locked in contract forever
	if (msg.sender == owner) { 
		suicide(owner); // send funds to organizer
	}
    }

    function kill()  { //如果后面加上constant的时候，刚创建就会把他销毁掉了
	if (owner==msg.sender){
		//析构函数
		selfdestruct(msg.sender);
	}
    }

    function callvaluefuzhi(address _contractAddress) payable external{
        bool kk = _contractAddress.callcode(bytes4(keccak256("inc()")));
    }

    function sendvaluefuzhi(address _receiver) payable external{
        bool kk = _receiver.send(msg.value);
    }
}


contract Receiver {
    uint public balance = 0;

    function () payable external{
        balance += msg.value;
    }
}
