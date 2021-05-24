pragma solidity 0.4.24;
contract GreaterOrEqualToZero {
    function infiniteLoop(uint border) returns(uint ans) {
        for (uint i = border; i >= 0; i--) {
            ans += i;
        }
    }
}

contract GreaterOrEqualToZero_1 {
    function infiniteLoop(uint128 border) returns(uint ans) {
        for (uint128 i = border; i >= 0; i--) {
            ans += i;
        }
    }
}