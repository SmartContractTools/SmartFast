pragma solidity ^0.4.16;

interface tokenRecipient { function receiveApproval(address _from, uint256 _value, address _token, bytes _extraData) external; }

/**
 *  ERC-20-2 
 */
contract ERC_20_2 {
    //- Token 
    string public name; 
    //- Token 
    string public symbol;
    //- Token 
    uint8 public decimals;
    //- Token 
    uint256 public totalSupply;
    //- 
    bool public lockAll = false;
    //- 
    address public creator;
    //- 
    address public owner;
    //- 
    address internal newOwner = 0x0;

    //- 
    mapping (address => uint256) public balanceOf;
    //-  Token
    mapping (address => mapping (address => uint256)) public allowance;
    //- 
    mapping (address => bool) public frozens;

    //- Token 
    event Transfer(address indexed _from, address indexed _to, uint256 _value);
    //- Token 
    event TransferExtra(address indexed _from, address indexed _to, uint256 _value, bytes _extraData);
    //- Token 
    event Approval(address indexed _owner, address indexed _spender, uint256 _value);
    //- Token 
    event Burn(address indexed _from, uint256 _value);
    //- Token 
    event Offer(uint256 _supplyTM);
    //- 
    event OwnerChanged(address _oldOwner, address _newOwner);
    //- 
    event FreezeAddress(address indexed _target, bool _frozen);

    /**
     * 
     *
     * 
     * @param initialSupplyHM 
     * @param tokenName Token 
     * @param tokenSymbol Token 
     * @param tokenDecimals Token 
     */
    constructor(uint256 initialSupplyHM, string tokenName, string tokenSymbol, uint8 tokenDecimals) public {
        name = tokenName;
        symbol = tokenSymbol;
        decimals = tokenDecimals;
        totalSupply = initialSupplyHM * 100 * 10000 * 10 ** uint256(decimals);
        
        balanceOf[msg.sender] = totalSupply;
        owner = msg.sender;
        creator = msg.sender;
    }

    /**
     * 
     */
    modifier onlyOwner {
        require(msg.sender == owner, "");
        _;
    }
	
    /**
     * 
     * @param _supplyTM 
     */
    function offer(uint256 _supplyTM) onlyOwner public returns (bool success){
		uint256 tm = _supplyTM * 1000 * 10000 * 10 ** uint256(decimals);
        totalSupply += tm;
        balanceOf[msg.sender] += tm;
        emit Offer(_supplyTM);
        return true;
    }

    /**
     * 
     * @param _newOwner 
     */
    function transferOwnership(address _newOwner) onlyOwner public returns (bool success){
        require(owner != _newOwner, "");
        newOwner = _newOwner;
        return true;
    }
    
    /**
     * 
     */
    function acceptOwnership() public returns (bool success){
        require(msg.sender == newOwner && newOwner != 0x0, "");
        address oldOwner = owner;
        owner = newOwner;
        newOwner = 0x0;
        emit OwnerChanged(oldOwner, owner);
        return true;
    }

    /**
     * 
     * @param _lockAll 
     */
    function setLockAll(bool _lockAll) onlyOwner public returns (bool success){
        lockAll = _lockAll;
        return true;
    }

    /**
     * 
     * @param _target 
     * @param _freeze 
     */
    function setFreezeAddress(address _target, bool _freeze) onlyOwner public returns (bool success){
        frozens[_target] = _freeze;
        emit FreezeAddress(_target, _freeze);
        return true;
    }

    /**
     *  Token 
     * @param _from 
     * @param _to 
     * @param _value 
     */
    function _transfer(address _from, address _to, uint256 _value) internal {
        //- 
        require(!lockAll, "");
        //- 
        require(_to != 0x0, "");
        //- 
        require(balanceOf[_from] >= _value, "");
        //- 
        require(!frozens[_from], ""); 
        //- 
        //require(!frozenAccount[_to]); 

        //- 
        uint256 previousBalances = balanceOf[_from] + balanceOf[_to];
        //- 
        balanceOf[_from] -= _value;
        //- 
        balanceOf[_to] += _value;
        //- 
		emit Transfer(_from, _to, _value);

        //- 
        assert(balanceOf[_from] + balanceOf[_to] == previousBalances);
    }

    /**
     *  Token 
     *
     * @param _to 
     * @param _value 
     */
    function transfer(address _to, uint256 _value) public returns (bool success) {
        _transfer(msg.sender, _to, _value);
        return true;
    }
	
    /**
     *  Token 
     *
     * @param _to 
     * @param _value 
     * @param _extraData 
     */
    function transferExtra(address _to, uint256 _value, bytes _extraData) public returns (bool success) {
        _transfer(msg.sender, _to, _value);
		emit TransferExtra(msg.sender, _to, _value, _extraData);
        return true;
    }

    /**
     *  Token 
     *
     * @param _from 
     * @param _to 
     * @param _value 
     */
    function transferFrom(address _from, address _to, uint256 _value) public returns (bool success) {
        //- 
        require(_value <= allowance[_from][msg.sender], "");

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
        emit Approval(msg.sender, _spender, _value);
        return true;
    }

    /**
     * 
     *
     * @param _spender 
     * @param _value 
     * @param _extraData 
     */
    function approveAndCall(address _spender, uint256 _value, bytes _extraData) public returns (bool success) {
        tokenRecipient spender = tokenRecipient(_spender);//- 
        if (approve(_spender, _value)) {
            spender.receiveApproval(msg.sender, _value, this, _extraData);
            return true;
        }
    }

    function _burn(address _from, uint256 _value) internal {
        //- 
        require(!lockAll, "");
        //- 
        require(balanceOf[_from] >= _value, "");
        //- 
        require(!frozens[_from], ""); 

        //-  Token
        balanceOf[_from] -= _value;
        //- 
        totalSupply -= _value;

        emit Burn(_from, _value);
    }

    /**
     *  Token
     *
     * @param _value 
     */
    function burn(uint256 _value) public returns (bool success) {

        _burn(msg.sender, _value);
        return true;
    }

    /**
     *  Token
     *
     * @param _from 
     * @param _value 
     */
    function burnFrom(address _from, uint256 _value) public returns (bool success) {
        //- 
        require(_value <= allowance[_from][msg.sender], "");
      
        allowance[_from][msg.sender] -= _value;

        _burn(_from, _value);
        return true;
    }

    function() payable public{
    }
}