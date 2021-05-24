/**
 *Submitted for verification at Etherscan.io on 2019-06-04
*/

pragma solidity ^ 0.4.21;

contract Token{
    // tokenpublicgettertotalSupply().
    uint256 public totalSupply;

    /// _ownertoken 
    function balanceOf(address _owner) public constant returns (uint256 balance);

    //_to_valuetoken
    function transfer(address _to, uint256 _value) public returns(bool success);

    //_from_to_valuetokenapprove
    function transferFrom(address _from, address _to, uint256 _value) public returns
        (bool success);

    //_spender_valuetoken
    function approve(address _spender, uint256 _value) public returns(bool success);

    //_spender_ownertoken
    function allowance(address _owner, address _spender) public constant returns 
        (uint256 remaining);

    // 
    event Transfer(address indexed _from, address indexed _to, uint256 _value);

    //approve(address _spender, uint256 _value)
    event Approval(address indexed _owner, address indexed _spender, uint256 
    _value);
}

contract SafeMath {
    uint256 constant public MAX_UINT256 =
        0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF;

    function safeAdd(uint256 x, uint256 y) pure internal returns (uint256 z) {
        if (x > MAX_UINT256 - y) revert();
        return x + y;
    }

    function safeSub(uint256 x, uint256 y) pure internal returns (uint256 z) {
        if (x < y) revert();
        return x - y;
    }

    function safeMul(uint256 x, uint256 y) pure internal returns (uint256 z) {
        if (y == 0) return 0;
        if (x > MAX_UINT256 / y) revert();
        return x * y;
    }
}

contract StandardToken is Token, SafeMath {
    function transfer(address _to, uint256 _value) public returns(bool success) {
        //totalSupply  (2^256 - 1).
        require(balances[msg.sender] >= _value);
        balances[msg.sender] = safeSub(balances[msg.sender], _value);//token_value
        balances[_to] = safeAdd(balances[_to], _value);//token_value
        emit Transfer(msg.sender, _to, _value);//
        return true;
    }


    function transferFrom(address _from, address _to, uint256 _value) public returns
        (bool success) {
       
        require(balances[_from] >= _value && allowed[_from][msg.sender] >= _value);
        balances[_to] = safeAdd(balances[_to], _value);//token_value
        balances[_from] = safeSub(balances[_from], _value); //_fromtoken_value
        allowed[_from][msg.sender] = safeSub(allowed[_from][msg.sender], _value);//_from_value
        emit Transfer(_from, _to, _value);//
        return true;
    }
    function balanceOf(address _owner) public constant returns (uint256 balance) {
        return balances[_owner];
    }


    function approve(address _spender, uint256 _value) public returns(bool success)
    {
        allowed[msg.sender][_spender] = _value;
        emit Approval(msg.sender, _spender, _value);
        return true;
    }


    function allowance(address _owner, address _spender) public constant returns (uint256 remaining) {
        return allowed[_owner][_spender];//_spender_ownertoken
    }
    mapping(address => uint256) balances;
    mapping(address => mapping(address => uint256)) allowed;
}

contract CNZT is StandardToken { 

    /* Public variables of the token */
    string public name;                   //
    uint8 public decimals;               //
    string public symbol;               //token
    string public version = '1.0.0';    //

    function CNZT(uint256 _initialAmount, string _tokenName, uint8 _decimalUnits, string _tokenSymbol) public {
        balances[msg.sender] = _initialAmount; // token
        totalSupply = _initialAmount;         // 
        name = _tokenName;                   // token
        decimals = _decimalUnits;           // 
        symbol = _tokenSymbol;             // token
    }

    /* Approves and then calls the receiving contract */

    function approveAndCall(address _spender, uint256 _value, bytes _extraData) public returns(bool success) {
        allowed[msg.sender][_spender] = _value;
        emit Approval(msg.sender, _spender, _value);
        require(_spender.call(bytes4(bytes32(keccak256("receiveApproval(address,uint256,address,bytes)"))), msg.sender, _value, this, _extraData));
        return true;
    }

}