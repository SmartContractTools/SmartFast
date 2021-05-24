contract C {
    function f_1(uint a, uint b) public{
	uint a = 0;
	do {    
    	    continue; //bad
	    a++;
	} while(a<10);
    }

    function m_1(uint a, uint b) public{
	uint a = 0;
	uint b = 0;
	do {
    	    continue; //bad
	    b++;
	} while(a<10);
    }

    function forcontinue(uint a, uint b) public{
	uint _sum = 0;
	for(uint i = 0; i < 10; i++){
            _sum = _sum + i; //good
        }
    }

    function whilecontinue(uint a, uint b) public{
	uint a = 0;
	while(a < 10)
	{
	    continue; //bad
	    a++;
	}
    }

    function e_1(uint a, uint b) public{
	uint a = 0;
	do {    
    	    continue; //good
	} while(a++<10);
    }

    function q_1(uint a, uint b) public{
	uint a = 0;
	do {
	    a++;    
    	    continue; //good
	} while(a<10);
    }

    //function l_1(uint a, uint b) public{
	//uint a = 0;
	//do {
	    //return;
    	    //continue; //good
	//} while(a<10);
    //}

    function twowhile() public{
	uint a = 0;
	uint b = 0;
	do {
    	    continue; //bad
	    a++;
	} while(a<10);
	do {
    	    continue; //bad
	    b++;
	} while(b<10);
    }

    function twowhileqiantao() public{
	uint a = 0;
	uint b = 0;
	do {
	    while(b<10)
	    {
		continue; //bad
		b++;
	    }
    	    continue; //bad
	    a++;
	} while(a<10);
    }
}
