pragma solidity 0.4.24;

contract TestContract {

    function test() internal returns(uint a, address b, bool c, int d) {
        a = 1;
        b = msg.sender;
        c = true;
		d = 2;
    }

    function test_1() internal returns(uint a, address b, bool c, int d, int128 e) {
        a = 1;
        b = msg.sender;
        c = true;
		d = 2;
    }
}
