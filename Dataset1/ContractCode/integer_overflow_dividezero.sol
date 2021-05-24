pragma solidity ^0.4.11;

contract SolidityUncheckedSend {
    uint x = 5;
    uint q = 2;
    uint w = 3;
    modifier onlyOwner { 
        uint y = q / w * 2;
	   require(y == x);
        _;	
    }
    function operator() private{
        uint a = 2;
        uint b = 3;
        uint y = 5 / a * b;
    }
    function operator1() private{
        uint a = 2;
        uint b = 1;
	   require(5 / a * b == 0);
        while(b<=2)
        {
                b = b + 1;
        }
	   require(5 / a * b != 0);
    }
}
