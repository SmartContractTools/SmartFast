contract MyConc{
    function bad(address dst) external payable{
        dst.call.value(msg.value)("");
    }

    function bad_1() external payable{
        msg.sender.call.value(msg.value)("");
    }

    function good(address dst) external payable{
        require(dst.call.value(msg.value)());
    }

    function good_1(address dst) external payable{
        if(dst.call.value(msg.value)()) {revert();}
    }
}
