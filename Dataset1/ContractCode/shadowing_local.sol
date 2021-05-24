pragma solidity ^0.4.24;

contract BaseContract {
    uint x = 5;
    uint y = 5;
    function yy() public pure;
    constructor(){}
    function shadowingParent_1() public pure { int x;}
    function shadowingParent_2() public pure { uint y;}
}

contract ExtendedContract is BaseContract {
    uint x = 7;

    modifier z() {
    	if(x==5){}
    	_;
    }

    event v();
}

contract FurtherExtendedContract is ExtendedContract {
    uint x = 7;

    modifier w {
        assert(msg.sender != address(0));
        _;
    }

    function shadowingParent(uint x) public pure { int y; uint z; uint w; uint v; }
}
