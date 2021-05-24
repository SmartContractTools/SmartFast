//pragma solidity ^0.4.24;

contract B
{
    function test() public pure
    {
        test1(/*A‮/*B*/2 , 1/*‭
		        /*C */,3);
    }
    
    function test1(uint a, uint b, uint c) internal pure
    {
		a = b + c;
    }
}
