pragma solidity ^0.5.0;

contract Mulvarlenarguments {
    function addUsers(
        address[] calldata admins,
        address[] calldata regularUsers,
        bytes calldata signature
    )
        external
    {       
		bytes32 hash = keccak256(abi.encodePacked(admins, regularUsers));
    }
}
