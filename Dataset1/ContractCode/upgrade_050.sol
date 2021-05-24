contract Token {
    uint totalSupply;

    function Token() {
        totalSupply = +1e18;
    }

    function () payable {}
}