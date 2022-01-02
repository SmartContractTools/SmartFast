pragma solidity ^0.4.22;

contract Auction {
	address public currentLeader;
	uint256 public highestBid;
    
	function bid() public payable{ //竞选方法
		require(msg.value > highestBid); //判断当前投入eth是否大于之前的最大值
		require(currentLeader.send(highestBid));//如果大于 把原有的王位拥有者的金钱退回
		currentLeader =msg.sender; //当选新的国王
		highestBid =msg.value;
	}
}