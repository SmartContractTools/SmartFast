pragma solidity ^0.4.24;

contract BaseContract {
    uint blockhash;
    uint now;

    event revert(bool condition);
}

contract ExtendedContract is BaseContract {
    uint ecrecover = 7;

    function assert(bool condition) public {
        uint msg;
    }
}

contract FurtherExtendedContract is ExtendedContract {
    uint blockhash = 7;
    uint this = 5;
    uint abi;
    uint year;

    modifier require {
        assert(msg.sender != address(0));
        _;
    }

    modifier require1 {
        uint keccak256;
        _;
    }

    modifier require2 {
        uint sha3;
        _;
    }
}

contract Reserved{
    address mutable;

}
