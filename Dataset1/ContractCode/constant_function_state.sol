pragma solidity ^0.4.24; 
contract Constant {
   
    uint a;
    
    function test_view_bug() public view{
        a = 0;
    }
    
    function test_constant_bug() public constant{
        a = 0;
    }

    function test_pure_bug() public pure{
        //uint b = a;
        //a = 0;
    }

    function test_view_shadow() public view{
        uint a;
        a = 0;
    }

    function test_view() public view{
        a;
    }

    function test_view_send(address ss) public view{
        ss.send(5);
    }

    function test_assembly_bug() public view{
        assembly{}
    }

    function test_assembly_bug_pure() public pure{
        assembly{}
    }
}
