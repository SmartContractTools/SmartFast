//pragma solidity ^0.4.24;

contract A{
    address unused;
    address public unused2;
    address private unused3;
    address unused4;
    address used;

    function ceshi1 () external{
        unused3 = address(0);
    }
}

contract B is A{

    function ceshi1 () external{
        used = address(0);
    }
}
