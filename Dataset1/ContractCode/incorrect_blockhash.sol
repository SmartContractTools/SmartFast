pragma solidity 0.4.24;

contract MyContract {

    function currentBlockHash() public view returns(bytes32) {
        return blockhash(block.number);
    }
}
