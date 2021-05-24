contract MyConc{
    function bad(address payable dst) external payable{
        dst.call.value(msg.value)("");
    }

    function bad_1() external payable{
        msg.sender.call.value(msg.value)("");
    }

    function good(address payable dst) external payable{
        (bool ret, bytes memory _) = dst.call.value(msg.value)("");
        require(ret);
    }

    function badfunction(address payable dst) external payable{
        (bool ret, bytes memory _) = dst.call.value(msg.value)("");
    }
}
