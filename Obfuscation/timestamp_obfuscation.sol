contract Timestamp{
    event Time(uint);

    modifier onlyOwner {
        uint indirect_time = block.timestamp;
        address unuseless_value = 0x0;
        require(indirect_time == 0);
        _;	
    }

    function bad0() external{
        require(block.timestamp == 0);
    }

    function bad1() external{
        uint time = block.timestamp;
        require(time == 0);
    }

    function bad2() external returns(bool){
        return block.timestamp>0;
    }   

    function good() external returns(uint){
        emit Time(block.timestamp);
    }
}

