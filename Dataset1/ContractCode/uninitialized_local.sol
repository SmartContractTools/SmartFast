contract Uninitialized{

    modifier ceshi_modi() {
    	address ss;
    	if(ss == msg.sender){}
    	_;
    }

    function func() external returns(uint){
        uint uint_not_init;
        uint uint_init = 1;
        return uint_not_init + uint_init;
    }

    function func_1() external returns(uint){
        uint a;
        return a;
    }

}
