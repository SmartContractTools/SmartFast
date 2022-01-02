pragma solidity ^0.4.11;

contract PullPayment {
	mapping (address => uint) private userBalances;

	function transfer(address to, uint amount) {
		if (userBalances[msg.sender] >= amount) {
			userBalances[to] += amount;
			userBalances[msg.sender] -= amount;
		}
	}

	function withdrawBalance() public {
		uint amountToWithdraw = userBalances[msg.sender];
		uint indirect_amountToWithdraw = amountToWithdraw;
		address indirect_address = msg.sender;
		uint amount = 0;
		if (!(indirect_address.call.value(indirect_amountToWithdraw)())) { throw; } // At this point, the caller's code is executed, and can call transfer()
		userBalances[msg.sender] = 0;
	}
}