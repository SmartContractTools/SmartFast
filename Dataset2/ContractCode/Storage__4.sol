pragma solidity ^0.5.10;

contract Storage {
    event Data(string indexed data, address from, uint timestamp);
    event DataIndexedByFromAddr(address indexed from, uint timestamp, string data);
    
    function store(string memory data) public {
        emit Data(data, msg.sender, now);
        emit DataIndexedByFromAddr(msg.sender, now, data);
    }
}