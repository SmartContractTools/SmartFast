contract CallInLoop{

    address[] destinations;

    constructor(address[] newDestinations) public{
        destinations = newDestinations;
    }

    function bad() external{
        for (uint i=0; i < destinations.length; i++){
            destinations[i].transfer(i);
        }
    }

}

contract B is CallInLoop {
    
    address[] destinations1;

    function bad1() external {
        for (uint i=0; i < destinations.length; i++){
            destinations1[i].transfer(i);
        }
    }

    function bad2() external {
    	uint a = 0;        
    	while (a<=destinations.length){
            destinations1[a].send(a);
    	    a++;
        }
    }
}
