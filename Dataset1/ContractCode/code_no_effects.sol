/*
 * @author: Kaden Zipfel
 */

pragma solidity ^0.5.0;

contract Wallet {
    mapping(address => uint) balance;

    // Deposit funds in contract
    function deposit(uint amount) public payable {
        require(msg.value == amount, 'msg.value must be equal to amount');
        balance[msg.sender] = amount;
    }

    // Withdraw funds from contract
    function withdraw(uint amount) public {
        require(amount <= balance[msg.sender], 'amount must be less than balance');

        uint previousBalance = balance[msg.sender];
        balance[msg.sender] = previousBalance - amount;

        // Attempt to send amount from the contract to msg.sender
        msg.sender.call.value(amount);
    }

    // Withdraw funds from contract
    function withdraw_bad1(uint amount) public {
        require(amount <= balance[msg.sender], 'amount must be less than balance');

        uint previousBalance = balance[msg.sender];
        balance[msg.sender] = previousBalance - amount;

        address withdraw_address = msg.sender;

        // Attempt to send amount from the contract to msg.sender
        withdraw_address.call.value(amount);
    }

    // Withdraw funds from contract
    function withdraw_good(uint amount) public {
        require(amount <= balance[msg.sender], 'amount must be less than balance');

        uint previousBalance = balance[msg.sender];
        balance[msg.sender] = previousBalance - amount;

        // Attempt to send amount from the contract to msg.sender
        (bool success, ) = msg.sender.call.value(amount)("");
        require(success, 'transfer failed');
    }
}
