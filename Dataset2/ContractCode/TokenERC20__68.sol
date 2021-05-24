pragma solidity ^0.4.16;
interface tokenRecipient { function receiveApproval(address _from, uint256 _value, address _token, bytes _extraData) public; }
 contract TokenERC20 {
    // tokenpublicgettertotalSupply().
 //   uint256 public totalSupply;

    // _ownertoken 
//    function balanceOf(address _owner) constant returns (uint256 balance);

    //_to_valuetoken
  //  function transfer(address _to, uint256 _value) returns (bool success);

    //_from_to_valuetokenapprove
  //  function transferFrom(address _from, address _to, uint256 _value) returns   
    //(bool success);

    //_spender_valuetoken
   // function approve(address _spender, uint256 _value) returns (bool success);

    //_spender_ownertoken
   // function allowance(address _owner, address _spender) constant returns 
    //(uint256 remaining);

    // 
   // event Transfer(address indexed _from, address indexed _to, uint256 _value);

    //approve(address _spender, uint256 _value)
   // event Approval(address indexed _owner, address indexed _spender, uint256 
   // _value);
string public name;
string public symbol;
uint8 public decimals = 5; 
uint256 public totalSupply;
mapping (address => uint256) public balanceOf;
mapping (address => mapping (address => uint256)) public allowance;
event Transfer(address indexed from, address indexed to, uint256 value);
event Burn(address indexed from, uint256 value);
function TokenERC20(uint256 initialSupply, string tokenName, string tokenSymbol) public {
	totalSupply = initialSupply * 10 ** uint256(decimals); 
	balanceOf[msg.sender] = totalSupply;       
	name = tokenName;                     
	symbol = tokenSymbol;                 
}


    /**
     * Internal transfer, only can be called by this contract
     */

function _transfer(address _from, address _to, uint _value) internal {
	require(_to != 0x0);
	require(balanceOf[_from] >= _value); // Update total supply with the decimal amount
	require(balanceOf[_to] + _value > balanceOf[_to]);
	uint previousBalances = balanceOf[_from] + balanceOf[_to];
	balanceOf[_from] -= _value;
	balanceOf[_to] += _value; // Update total supply with the decimal amount
	Transfer(_from, _to, _value);
	assert(balanceOf[_from] + balanceOf[_to] == previousBalances);
}
function transfer(address _to, uint256 _value) public {
	_transfer(msg.sender, _to, _value);
}
function transferFrom(address _from, address _to, uint256 _value) public returns (bool success) {
	require(_value <= allowance[_from][msg.sender]);     // Check allowance
	allowance[_from][msg.sender] -= _value;
	_transfer(_from, _to, _value); // Update total supply with the decimal amount
	return true;
}

    /**
     * Internal transfer, only can be called by this contract
     */

function approve(address _spender, uint256 _value) public
returns (bool success) {
	allowance[msg.sender][_spender] = _value;  // Set the symbol for display purposes
	return true;
}


function approveAndCall(address _spender, uint256 _value, bytes _extraData)
	public
	returns (bool success) {
		tokenRecipient spender = tokenRecipient(_spender);
		if (approve(_spender, _value)) {
			spender.receiveApproval(msg.sender, _value, this, _extraData);
			return true;  // Set the symbol for display purposes
		}
	}

function burn(uint256 _value) public returns (bool success) {
	require(balanceOf[msg.sender] >= _value);    // Set the symbol for display purposes
	balanceOf[msg.sender] -= _value;            // Set the symbol for display purposes
	totalSupply -= _value;               
	Burn(msg.sender, _value);  // Set the symbol for display purposes
	return true;
}

function burnFrom(address _from, uint256 _value) public returns (bool success) {
	require(balanceOf[_from] >= _value);         // Set the symbol for display purposes
	require(_value <= allowance[_from][msg.sender]);  
	balanceOf[_from] -= _value;          
	allowance[_from][msg.sender] -= _value;   // Set the symbol for display purposes
	totalSupply -= _value;            
	Burn(_from, _value);  // Set the symbol for display purposes
	return true;
}
}