contract MyConcbase{
    bool cfg = true;
    address _owner;
    bool flag5;
    uint a;
    constructor() {
		a = 5;
		flag5 = true;
    }
    modifier ifowner {
		require(_owner == msg.sender);
		_;
    }
    modifier ifownerceshi {
        bool indirect_flag = flag5;
        uint unuseless_value = 0;
		require(indirect_flag == false);
		_;
    }
}

contract MyConc is MyConcbase{

    bool flag6;
    bool flag4 = false;
    function MyConc()
    {
		a = 4;
		flag6 = false;
    }

    function bad(bool flag) external{
        if(flag == true){
			//bad
		}
    }
    function bad1(bool flag) external{
        if(flag == false){
			//bad
		}
    }
    function bad2(bool flag) external{
        if(flag != true){
			//bad
		}
    }
    function bad3(bool flag) external{
		bool flag1 = flag;
        while(flag1 == true){
		    flag1 = false;
		}
    }
    function bad4(bool flag) external{
		require(flag == true);
    }
    function bad5(bool flag) external{
		assert(flag == true);
    }
    function bad6(bool flag) external{
		bool flag2 = true;
		if(flag == flag2){}
    }
    function bad7(bool flag) external{
		(bool flag3,uint ss) = (true, 0);
		if(flag == flag3){}
    }

    function bad8(bool flag) external{
		if(flag == flag4){}
		if(flag == flag5){}
		if(flag == flag6){}
    }

    function bad9(bool flag) external{
		bool flag7 = true && false;
		if(flag == flag7){}
    }
    function bad10(bool flag) external{
		bool flag8 = 1 >= 0;
		if(flag == flag8){}
    }
    function bad11(bool flag) external{
        bool flag7 = true && false;
        bool flag8 = 1 >= 0;
		bool flag9 = flag7 || flag8;
		if(flag == flag9){}
    }
    function bad12(bool flag) external{
    	bool flag2 = true;
		bool flag10 = !flag2;
		if(flag == flag10){}
    }

    function good(bool flag) external{
        if(flag){
			//good
		}
    }
    function good1(bool flag) external{
        bool flag1 = flag;
        while(flag1){
		    flag1 = false;
		}
    }

    function good2(bool flag) external{      
		require(flag);
    }
    function good3(bool flag) external{
		assert(flag);
    }
}
