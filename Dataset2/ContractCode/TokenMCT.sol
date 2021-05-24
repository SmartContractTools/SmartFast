pragma solidity ^0.4.19;

library SafeMath
{
    function mul(uint256 a, uint256 b) internal pure
        returns (uint256)
    {
        uint256 c = a * b;
        assert(a == 0 || c / a == b);
        return c;
    }

    function div(uint256 a, uint256 b) internal pure
        returns (uint256)
    {
        uint256 c = a / b;
        return c;
    }

    function sub(uint256 a, uint256 b) internal pure
        returns (uint256)
    {
        assert(b <= a);
        return a - b;
    }

    function add(uint256 a, uint256 b) internal pure
        returns (uint256)
    {
        uint256 c = a + b;
        assert(c >= a);
        return c;
    }
}


interface tokenRecipient { function receiveApproval(address _from, uint256 _value, address _token, bytes _extraData) public; }

contract TokenMCT{
	using SafeMath for uint;
	
    string public name;

    string public symbol;

    uint8 public decimals = 18;  // 18 

    uint256 public totalSupply;

    mapping (address => uint256) public balanceOf;  //

    mapping (address => mapping (address => uint256)) public allowance;

    event Transfer(address indexed from, address indexed to, uint256 value);

    event Burn(address indexed from, uint256 value);

    function TokenMCT(uint256 initialSupply, string tokenName, string tokenSymbol) public {

        totalSupply = initialSupply * 10 ** uint256(decimals);

        balanceOf[msg.sender] = totalSupply;

        name = tokenName;

        symbol = tokenSymbol;

    }

    function _transfer(address _from, address _to, uint _value) internal {
	
        require(_to != address(0));
        
        require(_value > 0);
        
        require(balanceOf[_from] >= _value);

        require(balanceOf[_to] + _value > balanceOf[_to]);

        uint previousBalances = balanceOf[_from] + balanceOf[_to];

        balanceOf[_from] -= _value;

        balanceOf[_to] += _value;

        Transfer(_from, _to, _value);

        assert(balanceOf[_from] + balanceOf[_to] == previousBalances);

    }

    function transfer(address _to, uint256 _value) public {

        _transfer(msg.sender, _to, _value);

    }

    function transferFrom(address _from, address _to, uint256 _value) public returns (bool success) {

        require(_value <= allowance[_from][msg.sender]);     // Check allowance

        allowance[_from][msg.sender] -= _value;

        _transfer(_from, _to, _value);

        return true;

    }

    function approve(address _spender, uint256 _value) public

        returns (bool success) {

        allowance[msg.sender][_spender] = _value;

        return true;

    }

    function approveAndCall(address _spender, uint256 _value, bytes _extraData) public returns (bool success) {

        tokenRecipient spender = tokenRecipient(_spender);

        if (approve(_spender, _value)) {

            spender.receiveApproval(msg.sender, _value, this, _extraData);

            return true;

        }

    }

    function burn(uint256 _value) public returns (bool success) {

        require(balanceOf[msg.sender] >= _value);

        balanceOf[msg.sender] -= _value;

        totalSupply -= _value;

        Burn(msg.sender, _value);

        return true;

    }

    function burnFrom(address _from, uint256 _value) public returns (bool success) {

        require(balanceOf[_from] >= _value);

        require(_value <= allowance[_from][msg.sender]);

        balanceOf[_from] -= _value;

        allowance[_from][msg.sender] -= _value;

        totalSupply -= _value;

        Burn(_from, _value);

        return true;
    }
}