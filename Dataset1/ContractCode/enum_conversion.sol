pragma solidity ^0.4.3;
contract Test{
    
    enum E{a}
    
    function bug(uint a) public returns(E){
        return E(a);   
    }
}

contract Test_1{
    
    enum E{a}
    
    function bug(int128 a) public returns(E){
        return E(a);   
    }
}
