pragma solidity ^0.5.1;

contract ERC20Interface {
    // 
    string public name;
    // 
    string public symbol;
    // 
    uint8 public decimals;
    // 
    uint public totalSupply;

    // 
    function transfer(address to, uint tokens) public returns (bool success);
    // 
    function transferFrom(address from, address to, uint tokens) public returns (bool success);
    // spendertokens
    function approve(address spender, uint tokens) public returns (bool success);
    // spendertokenOwner
    function allowance(address tokenOwner, address spender) public view returns (uint remaining);

    // transfer
    event Transfer(address indexed from, address indexed to, uint tokens);
    // approve
    event Approval(address indexed tokenOwner, address indexed spender, uint tokens);
}

// ERC-20
contract GNC is ERC20Interface {
    // publicbalanceOf
    mapping (address => uint256) public balanceOf;
    // 
    mapping (address => mapping (address => uint256)) internal allowed;

    // 
    constructor() public {
        name = "Grid Network Chain GNC";
        symbol = "GNC"; 
        decimals = 8;
        totalSupply = 100000000 * 10**uint(decimals);
        // 
        balanceOf[msg.sender] = totalSupply;
    }

    function transfer(address to, uint tokens) public returns (bool success) {
        // 
        require(to != address(0));
        // 
        require(balanceOf[msg.sender] >= tokens);
        // 
        require(balanceOf[to] + tokens >= balanceOf[to]);

        // 
        balanceOf[msg.sender] -= tokens;
        // 
        balanceOf[to] += tokens;

        // 
        emit Transfer(msg.sender, to, tokens);

                success = true;
    }

    function transferFrom(address from, address to, uint tokens) public returns (bool success) {
        // 
        require(to != address(0) && from != address(0));
        // 
        require(balanceOf[from] >= tokens);
        // 
        require(allowed[from][msg.sender] <= tokens);
        // 
        require(balanceOf[to] + tokens >= balanceOf[to]);

        // 
        balanceOf[from] -= tokens;
        // 
        balanceOf[to] += tokens;

        // 
        emit Transfer(from, to, tokens);   

        success = true;
    }

    function approve(address spender, uint tokens) public returns (bool success) {
        allowed[msg.sender][spender] = tokens;
        // 
        emit Approval(msg.sender, spender, tokens);

        success = true;
    }

    function allowance(address tokenOwner, address spender) public view returns (uint remaining) {
        return allowed[tokenOwner][spender];
    }
}