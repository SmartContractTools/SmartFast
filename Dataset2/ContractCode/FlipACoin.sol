pragma solidity >=0.5.1 <0.6.0;

contract FlipACoin {
    function coinFlip(uint256 _blockNumber) public view returns (uint8 hort) {
        if (_blockNumber >= block.number){
            hort=0; // not ready
        } else {
            if((uint256(blockhash(_blockNumber))%2)==1){
                hort = 1; // heads
            } else {
                hort = 2; // tails
            }
        }
    }
}