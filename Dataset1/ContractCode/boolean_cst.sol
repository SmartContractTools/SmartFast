contract MyConcbase{
    bool cfg = true;
    address _owner;
    bool flag5;
    constructor() {
	flag5 = true;
    }
	    modifier ifowner {
		require(_owner == msg.sender);
		_;
    }
}

contract MyConc is MyConcbase{

    bool flag6;
    function MyConc()
    {
		flag6 = false;
    }

    function ceshi_1() external{
        while(true){
		    flag6 = false;
		    break;
		}
    }
    function bad1() external{
		while(true){
		    flag6 = false;
		}
    }
    function ceshi_2() external{
		while(true){
		    return;
		}
    }
    function ceshi_3() external{
		if(true) {}
    }
    function ceshi_4() external{
		bool flag = false;
		if(flag) {}
    }
    function ceshi_5() external{
		require(true);
    }
    function ceshi_6() external{
		assert(true);
    }
    function ceshi_7() external{
		bool flag7 = true && false;
		bool flag8 = !flag6;
		bool flag9 = flag7 && flag8;
    }
}
