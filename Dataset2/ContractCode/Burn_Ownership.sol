pragma solidity ^0.5.11;

contract Ownable {
    function acceptOwnership() public;
}

/* This contract has the sole function of accepting the ownership of a contract and has no other method of making use of it, actually making the property burned and thus making it a trustless contract. */

contract Burn_Ownership {
    function burnOwnership(address _contract) public {
        Ownable(_contract).acceptOwnership();
    }
}