pragma solidity ^0.4.24;
contract Signature {
    function callFoo(address addr, uint value) public returns (bool) {
        (bool status, ) = addr.call(abi.encodeWithSignature("foo(uint)", value));
		(bool status1, ) = addr.call(bytes4(keccak256("foo(uint)", value)));
        return status;
    }

}
