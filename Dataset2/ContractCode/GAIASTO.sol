pragma solidity ^0.4.24;

/**
 * Utility library of inline functions on addresses
 */
library AddressUtilsLib {

    /**
    * Returns whether there is code in the target address
    * @dev This function will return false if invoked during the constructor of a contract,
    *  as the code is not actually created until after the constructor finishes.
    * @param _addr address address to check
    * @return bool whether there is code in the target address
    */
    function isContract(address _addr) internal view returns (bool) {
        uint256 size;
        assembly {
            size := extcodesize(_addr)
        }

        return size > 0;
    }
    
}

pragma solidity ^0.4.24;


/**
 * @title Ownable
 * @dev The Ownable contract has an owner address, and provides basic authorization control
 * functions, this simplifies the implementation of "user permissions".
 */
contract Ownable {

    address public owner;
    using AddressUtilsLib for address;
    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);


    /**
    * @dev The Ownable constructor sets the original `owner` of the contract to the sender
    * account.
    */
    constructor() public {
        owner = msg.sender;
    }


    /**
    * @dev Throws if called by any account other than the owner.
    */
    modifier onlyOwner() {
        require(msg.sender == owner);
        _;
    }

    
    /**
    * @dev Allows the current owner to transfer control of the contract to a newOwner.
    * @param _newOwner The address to transfer ownership to.
    */
    function transferOwnership(address _newOwner) public onlyOwner {
        require(!_newOwner.isContract());
        emit    OwnershipTransferred(owner, _newOwner);
        owner = _newOwner;
    }
}

pragma solidity ^0.4.24;


/**
 * Math operations with safety checks
 */
library SafeMathLib {

    /**
    * @dev uint256
    */
    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a * b;
        assert(a == 0 || c / a == b);
        return c;
    }

    /**
    * @dev 
    */
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        assert(0==b);
        uint256 c = a / b;
        // assert(a == b * c + a % b); // There is no case in which this doesn't hold
        return c;
    }

    /**
    * @dev 
    */
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        assert(b <= a);
        return a - b;
    }

    /**
    * @dev 
    */
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        assert(c >= a);
        return c;
    }

    /**
    * @dev 64bit
    */
    function max64(uint64 a, uint64 b) internal pure returns (uint64) {
        return a >= b ? a : b;
    }

    /**
    * @dev 64bit
    */
    function min64(uint64 a, uint64 b) internal pure returns (uint64) {
        return a < b ? a : b;
    }

    /**
    * @dev uint256
    */
    function max256(uint256 a, uint256 b) internal pure returns (uint256) {
        return a >= b ? a : b;
    }

    /**
    * @dev uint256
    */
    function min256(uint256 a, uint256 b) internal pure returns (uint256) {
        return a < b ? a : b;
    }
}

pragma solidity ^0.4.24;
contract ERC20Basic {
    /**
    * @dev 
    */
    event Transfer(address indexed _from,address indexed _to,uint256 value);

    //  
    uint256 public  totalSupply;

    //
    mapping(address => uint256) public balances;

    /**
    *@dev 
     */
    function name() public view returns (string);

    /**
    *@dev 
     */
    function symbol() public view returns (string);

    /**
    *@dev 
     */
    function decimals() public view returns (uint8);

    /**
    *@dev 
     */
    function totalSupply() public view returns (uint256){
        return totalSupply;
    }

    /**
    * @dev 
    * @param _owner  
    * @return uint256 
    */
    function balanceOf(address _owner) public view returns (uint256 balance) {
        return balances[_owner];
    }

    /**
    * @dev 
    * @param _to 
    * @param _value 
    */
    function transfer(address _to, uint256 _value) public returns (bool);
}

pragma solidity ^0.4.24;

/**
 * @title Basic token
 */
contract BasicToken is ERC20Basic {
    //SafeMathLib
    using SafeMathLib for uint256;
    using AddressUtilsLib for address;
    
    /**
    * @dev 
    * @param _from 
    * @param _to 
    * @param _value 
    */
    function _transfer(address _from,address _to, uint256 _value) public returns (bool){
        require(!_from.isContract());
        require(!_to.isContract());
        require(0 < _value);
        require(balances[_from] >= _value);

        balances[_from] = balances[_from].sub(_value);
        balances[_to] = balances[_to].add(_value);
        emit Transfer(_from, _to, _value);
        return true;
    }

    /**
    * @dev 
    * @param _to 
    * @param _value 
    */
    function transfer(address _to, uint256 _value) public returns (bool){
        return   _transfer(msg.sender,_to,_value);
    }
}

pragma solidity ^0.4.24;

contract ERC20 is ERC20Basic {

    mapping (address => mapping (address => uint256)) allowed;
    
    /**
    * @dev 
    */
    event Approval(address indexed _owner, address indexed _spender, uint256 _value);

     /**
    * @dev _owner_spender
    * @param _owner 
    * @param _spender 
    * @return uint256 
    */
    function allowance(address _owner, address _spender) public view returns (uint256);

    /**
    * @dev approve_from_value
    * @param _from 
    * @param _to 
    * @param _value 
    */
    function transferFrom(address _from, address _to, uint256 _value) public returns (bool);

    /**
    * @dev _spender_value
    * @param _spender 
    * @param _value 
    */
    function approve(address _spender, uint256 _value) public returns (bool);
}

pragma solidity ^0.4.24;

contract WSBasic is ERC20,BasicToken{
    /**
    * @dev approvetransferFromtoken
    * @param _from token
    * @param _to 
    * @param _value 
    */
    function transferFrom(address _from, address _to, uint256 _value) public returns (bool){
        //
        require(0 < _value);
        //
        require(address(0) != _from && address(0) != _to);
        //
        require(allowed[_from][msg.sender] >= _value);
        //
        require(balances[_from] >= _value);
        //
        require(!_from.isContract());
        //
        require(!_to.isContract());

        //
        uint256 _allowance = allowed[_from][msg.sender];

        balances[_to] = balances[_to].add(_value);
        balances[_from] = balances[_from].sub(_value);
        allowed[_from][msg.sender] = _allowance.sub(_value);
        emit Transfer(_from, _to, _value);
        return true;
    }

    /**
    * @dev address
    * @dev 0 address 
    * @dev token
    * @dev token
    * @param _spender 
    * @param _value uint256 
    */
    function approve(address _spender, uint256 _value) public returns (bool){
        require(address(0) != _spender);
        require(!_spender.isContract());
        require(msg.sender != _spender);
        require(0 != _value);

        allowed[msg.sender][_spender] = _value;
        emit Approval(msg.sender, _spender, _value);
        return true;
    }

   /**
    * @dev _owner_spender
    * @param _owner 
    * @param _spender 
    * @return uint256 
    */
    function allowance(address _owner, address _spender) public view returns (uint256) {
        //
        require(!_owner.isContract());
        //
        require(!_spender.isContract());

        return allowed[_owner][_spender];
    }
}

pragma solidity ^0.4.24;
contract GAIASTO is WSBasic,Ownable{
    using SafeMathLib for uint256;
    //
    string constant public tokenName = "GAIA-STO";
    //
    string constant public tokenSymbol = "STO";
    //10
    uint256 constant public totalTokens = 10*10000*10000;
    //
    uint8 constant public  totalDecimals = 18;   
    //
    string constant private version = "20190728";

    constructor() public {
        totalSupply = totalTokens*10**uint256(totalDecimals);
        balances[msg.sender] = totalSupply;
    }

    /**
    *@dev 
     */
    function name() public view returns (string){
        return tokenName;
    }

    /**
    *@dev 
     */
    function symbol() public view returns (string){
        return tokenSymbol;
    }

    /**
    *@dev 
     */
    function decimals() public view returns (uint8){
        return totalDecimals;
    }
}