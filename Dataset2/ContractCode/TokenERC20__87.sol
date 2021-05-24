pragma solidity ^0.4.16;
 
interface tokenRecipient { function receiveApproval(address _from, uint256 _value, address _token, bytes _extraData) external; }
/**
 * owned
 */
contract owned {
    address public owner;
 
    /**
     * 
     */
    function owned () public {
        owner = msg.sender;
    }
 
    /**
     * 
     */
    modifier onlyOwner {
        require (msg.sender == owner);
        _;
    }
 
    /**
     * 
     * @param  newOwner address 
     */
    function transferOwnership(address newOwner) onlyOwner public {
        if (newOwner != address(0)) {
        owner = newOwner;
      }
    }
}
 
/**
 * 
 */
contract TokenERC20 is owned {
    string public name; //
    string public symbol; //
    uint8 public decimals = 8;  //0
    uint256 public totalSupply; //
 
    /**/
    mapping (address => uint256) public balanceOf;
    mapping (address => mapping (address => uint256)) public allowance;
 
    /* */
    //
    event Transfer(address indexed from, address indexed to, uint256 value);  
    event Burn(address indexed from, uint256 value);  //
 
    /* 
     * @param initialSupply 
     * @param tokenName 
     * @param tokenSymbol 
     */
    function TokenERC20(uint256 initialSupply, string tokenName, string tokenSymbol) public {
        //
        totalSupply = initialSupply * 10 ** uint256(decimals);   
        //
        balanceOf[msg.sender] = totalSupply;
        name = tokenName;
        symbol = tokenSymbol;
    }
 
 
    /**
     * 
     * @param  _from address 
     * @param  _to address 
     * @param  _value uint256 
     */
    function _transfer(address _from, address _to, uint256 _value) internal {
 
      //0x0
      require(_to != 0x0);
 
      //
      require(balanceOf[_from] >= _value);
 
      //
      require(balanceOf[_to] + _value > balanceOf[_to]);
 
      //
      uint previousBalances = balanceOf[_from] + balanceOf[_to];
 
      //
      balanceOf[_from] -= _value;
 
      //
      balanceOf[_to] += _value;
 
      //
      Transfer(_from, _to, _value);
 
      //
      assert(balanceOf[_from] + balanceOf[_to] == previousBalances);
 
    }
 
    /**
     * 
     * @param  _to address 
     * @param  _value uint256 
     */
    function transfer(address _to, uint256 _value) public {
        _transfer(msg.sender, _to, _value);
    }
 
    /**
     * 
     * 
     * @param  _from address 
     * @param  _to address 
     * @param  _value uint256 
     * @return success        
     */
    function transferFrom(address _from, address _to, uint256 _value) public returns (bool success) {
        //
        require(_value <= allowance[_from][msg.sender]);
        allowance[_from][msg.sender] -= _value;
        _transfer(_from, _to, _value);
        return true;
    }
 
    /**
     * 
     * 
     * @param _spender 
     * @param _value 
     */
    function approve(address _spender, uint256 _value) public returns (bool success) {
        allowance[msg.sender][_spender] = _value;
        return true;
    }
 
    /**
     * 
     *  tokenRecipient 
     * @param _spender 
     * @param _value 
     * @param _extraData 
     */
    function approveAndCall(address _spender, uint256 _value, bytes _extraData) public returns (bool success) {
        tokenRecipient spender = tokenRecipient(_spender);
        if (approve(_spender, _value)) {
            spender.receiveApproval(msg.sender, _value, this, _extraData);
            return true;
        }
    }
 
    /**
     * 
     * 
     * @param _value 
     */
    function burn(uint256 _value) public returns (bool success) {
        //
        require(balanceOf[msg.sender] >= _value);
        //
        balanceOf[msg.sender] -= _value;
        //
        totalSupply -= _value;
        Burn(msg.sender, _value);
        return true;
    }
 
    /**
     * 
     * 
     * @param _from 
     * @param _value 
     */
    function burnFrom(address _from, uint256 _value) public returns (bool success) {
        //
        require(balanceOf[_from] >= _value);
        //  
        require(_value <= allowance[_from][msg.sender]);
        //
        balanceOf[_from] -= _value;
        allowance[_from][msg.sender] -= _value;
        //
        totalSupply -= _value;
        Burn(_from, _value);
        return true;
    }
}