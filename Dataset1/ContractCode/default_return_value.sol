contract C{
    function bad_return() public returns(bool flag){
		address aa = msg.sender;
    }

    function bad_return1() public returns(bool){
		address aa = msg.sender;
    }

    function good_return() public returns(bool){
		address aa = msg.sender;
		return (aa==msg.sender);
    }

    function good_return1() public returns(bool flag){
		address aa = msg.sender;
		flag = (aa==msg.sender);
    }
}
