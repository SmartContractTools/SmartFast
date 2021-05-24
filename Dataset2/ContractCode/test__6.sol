pragma solidity ^0.5.10;

contract test {
    int _multiplier;

    constructor (int multiplier) public {
        _multiplier = multiplier;
    }

    function multiply(int val) public view returns (int d) {
        return val * _multiplier;
    } 
}