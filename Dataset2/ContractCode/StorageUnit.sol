/**

    This contract is based on the original work of Shuffle Monster token https://shuffle.monster/ (0x3A9FfF453d50D4Ac52A6890647b823379ba36B9E)

*/

// File: contracts/commons/StorageUnit.sol

pragma solidity ^0.5.11;


contract StorageUnit {
    address private owner;
    mapping(bytes32 => bytes32) private store;

    constructor() public {
        owner = msg.sender;
    }

    function write(bytes32 _key, bytes32 _value) external {
        /* solium-disable-next-line */
        require(msg.sender == owner);
        store[_key] = _value;
    }

    function read(bytes32 _key) external view returns (bytes32) {
        return store[_key];
    }
}