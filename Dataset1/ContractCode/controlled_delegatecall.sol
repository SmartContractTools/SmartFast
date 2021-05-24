contract C{

    address owner;
    address addr_good = address(0x41);
    address addr_bad ;
    bytes database;

    bytes4 func_id;

    function bad_delegate_call(bytes memory data) public{
        addr_good.delegatecall(data);
        addr_bad.delegatecall(data);
    }

    function set(bytes4 id) public{
        func_id = id;
        addr_bad = msg.sender;
    }

    function bad_delegate_call2(bytes memory data) public{
        addr_bad.delegatecall(abi.encode(func_id, data));
    }

    function good_delegate_call(bytes memory data) public{
        addr_good.delegatecall(abi.encode(bytes4(""), data));
    }

    function good_delegate_call1(bytes memory data) public{
        addr_good.delegatecall(abi.encode(bytes4(""), data));
	require(msg.sender == owner);
	msg.sender.delegatecall(data);
    }

    modifier ifowner() {
	require(msg.sender == owner);
	_;
    }

    function bad_delegate_call3(bytes memory data) public{
	address cc = msg.sender;
	cc = addr_bad;
	require(cc == owner);
	address dd = addr_bad;
        dd.delegatecall(abi.encode(bytes4(""), data));
    }


    function good_delegate_call2(bytes memory data) ifowner public{
        msg.sender.delegatecall(abi.encode(bytes4(""), data));
    }

    function good_delegate_call3(address kk,bytes memory data) ifowner public{
        kk.delegatecall(abi.encode(bytes4(""), data));
    }

    function good_delegate_call4(address kk1,bytes memory data) public{
        require(kk1 == owner);
	kk1.delegatecall(abi.encode(bytes4(""), data));
    }

    function good_delegate_call5(address kk1,bytes memory data) public{
	address a = msg.sender;        
	require(a == owner);
	kk1.delegatecall(abi.encode(bytes4(""), data));
    }

    //function(){
	
	//owner.delegatecall(database);
    //}
}
