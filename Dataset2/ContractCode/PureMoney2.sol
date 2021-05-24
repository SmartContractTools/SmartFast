pragma solidity ^0.4.24;


/**
 * @title ERC20 interface
 * @dev see https://github.com/ethereum/EIPs/issues/20
 */
interface IERC20 {
  function totalSupply() external view returns (uint256);

  function balanceOf(address who) external view returns (uint256);

  function allowance(address owner, address spender)
    external view returns (uint256);

  function transfer(address to, uint256 value) external returns (bool);

  function approve(address spender, uint256 value)
    external returns (bool);

  function transferFrom(address from, address to, uint256 value)
    external returns (bool);

  event Transfer(
    address indexed from,
    address indexed to,
    uint256 value
  );

  event Approval(
    address indexed owner,
    address indexed spender,
    uint256 value
  );
}



/**
 * @title Standard ERC20 token
 *
 * @dev Implementation of the basic standard token.
 * https://github.com/ethereum/EIPs/blob/master/EIPS/eip-20.md
 * Originally based on code by FirstBlood: https://github.com/Firstbloodio/token/blob/master/smart_contract/FirstBloodToken.sol
 */
contract ERC20 is IERC20 {
  using SafeMath for uint256;

  mapping (address => uint256) private _balances;

  mapping (address => mapping (address => uint256)) private _allowed;

  uint256 private _totalSupply;

  /**
  * @dev Total number of tokens in existence
  */
  function totalSupply() public view returns (uint256) {
    return _totalSupply;
  }

  /**
  * @dev Gets the balance of the specified address.
  * @param owner The address to query the balance of.
  * @return An uint256 representing the amount owned by the passed address.
  */
  function balanceOf(address owner) public view returns (uint256) {
    return _balances[owner];
  }

  /**
   * @dev Function to check the amount of tokens that an owner allowed to a spender.
   * @param owner address The address which owns the funds.
   * @param spender address The address which will spend the funds.
   * @return A uint256 specifying the amount of tokens still available for the spender.
   */
  function allowance(
    address owner,
    address spender
   )
    public
    view
    returns (uint256)
  {
    return _allowed[owner][spender];
  }

  /**
  * @dev Transfer token for a specified address
  * @param to The address to transfer to.
  * @param value The amount to be transferred.
  */
  function transfer(address to, uint256 value) public returns (bool) {
    _transfer(msg.sender, to, value);
    return true;
  }

  /**
   * @dev Approve the passed address to spend the specified amount of tokens on behalf of msg.sender.
   * Beware that changing an allowance with this method brings the risk that someone may use both the old
   * and the new allowance by unfortunate transaction ordering. One possible solution to mitigate this
   * race condition is to first reduce the spender's allowance to 0 and set the desired value afterwards:
   * https://github.com/ethereum/EIPs/issues/20#issuecomment-263524729
   * @param spender The address which will spend the funds.
   * @param value The amount of tokens to be spent.
   */
  function approve(address spender, uint256 value) public returns (bool) {
    require(spender != address(0));

    _allowed[msg.sender][spender] = value;
    emit Approval(msg.sender, spender, value);
    return true;
  }

  /**
   * @dev Transfer tokens from one address to another
   * @param from address The address which you want to send tokens from
   * @param to address The address which you want to transfer to
   * @param value uint256 the amount of tokens to be transferred
   */
  function transferFrom(
    address from,
    address to,
    uint256 value
  )
    public
    returns (bool)
  {
    require(value <= _allowed[from][msg.sender]);

    _allowed[from][msg.sender] = _allowed[from][msg.sender].sub(value);
    _transfer(from, to, value);
    return true;
  }

  /**
   * @dev Increase the amount of tokens that an owner allowed to a spender.
   * approve should be called when allowed_[_spender] == 0. To increment
   * allowed value is better to use this function to avoid 2 calls (and wait until
   * the first transaction is mined)
   * From MonolithDAO Token.sol
   * @param spender The address which will spend the funds.
   * @param addedValue The amount of tokens to increase the allowance by.
   */
  function increaseAllowance(
    address spender,
    uint256 addedValue
  )
    public
    returns (bool)
  {
    require(spender != address(0));

    _allowed[msg.sender][spender] = (
      _allowed[msg.sender][spender].add(addedValue));
    emit Approval(msg.sender, spender, _allowed[msg.sender][spender]);
    return true;
  }

  /**
   * @dev Decrease the amount of tokens that an owner allowed to a spender.
   * approve should be called when allowed_[_spender] == 0. To decrement
   * allowed value is better to use this function to avoid 2 calls (and wait until
   * the first transaction is mined)
   * From MonolithDAO Token.sol
   * @param spender The address which will spend the funds.
   * @param subtractedValue The amount of tokens to decrease the allowance by.
   */
  function decreaseAllowance(
    address spender,
    uint256 subtractedValue
  )
    public
    returns (bool)
  {
    require(spender != address(0));

    _allowed[msg.sender][spender] = (
      _allowed[msg.sender][spender].sub(subtractedValue));
    emit Approval(msg.sender, spender, _allowed[msg.sender][spender]);
    return true;
  }

  /**
  * @dev Transfer token for a specified addresses
  * @param from The address to transfer from.
  * @param to The address to transfer to.
  * @param value The amount to be transferred.
  */
  function _transfer(address from, address to, uint256 value) internal {
    require(value <= _balances[from]);
    require(to != address(0));

    _balances[from] = _balances[from].sub(value);
    _balances[to] = _balances[to].add(value);
    emit Transfer(from, to, value);
  }

  /**
   * @dev Internal function that mints an amount of the token and assigns it to
   * an account. This encapsulates the modification of balances such that the
   * proper events are emitted.
   * @param account The account that will receive the created tokens.
   * @param value The amount that will be created.
   */
  function _mint(address account, uint256 value) internal {
    require(account != 0);
    _totalSupply = _totalSupply.add(value);
    _balances[account] = _balances[account].add(value);
    emit Transfer(address(0), account, value);
  }

  /**
   * @dev Internal function that burns an amount of the token of a given
   * account.
   * @param account The account whose tokens will be burnt.
   * @param value The amount that will be burnt.
   */
  function _burn(address account, uint256 value) internal {
    require(account != 0);
    require(value <= _balances[account]);

    _totalSupply = _totalSupply.sub(value);
    _balances[account] = _balances[account].sub(value);
    emit Transfer(account, address(0), value);
  }

  /**
   * @dev Internal function that burns an amount of the token of a given
   * account, deducting from the sender's allowance for said account. Uses the
   * internal burn function.
   * @param account The account whose tokens will be burnt.
   * @param value The amount that will be burnt.
   */
  function _burnFrom(address account, uint256 value) internal {
    require(value <= _allowed[account][msg.sender]);

    // Should https://github.com/OpenZeppelin/zeppelin-solidity/issues/707 be accepted,
    // this function needs to emit an event with the updated approval.
    _allowed[account][msg.sender] = _allowed[account][msg.sender].sub(
      value);
    _burn(account, value);
  }
}


/**
 * @title Roles
 * @dev Library for managing addresses assigned to a Role.
 */
library Roles {
  struct Role {
    mapping (address => bool) bearer;
  }

  /**
   * @dev give an account access to this role
   */
  function add(Role storage role, address account) internal {
    require(account != address(0));
    require(!has(role, account));

    role.bearer[account] = true;
  }

  /**
   * @dev remove an account's access to this role
   */
  function remove(Role storage role, address account) internal {
    require(account != address(0));
    require(has(role, account));

    role.bearer[account] = false;
  }

  /**
   * @dev check if an account has this role
   * @return bool
   */
  function has(Role storage role, address account)
    internal
    view
    returns (bool)
  {
    require(account != address(0));
    return role.bearer[account];
  }
}


contract CapperRole {
  using Roles for Roles.Role;

  event CapperAdded(address indexed account);
  event CapperRemoved(address indexed account);

  Roles.Role private cappers;

  constructor() internal {
    _addCapper(msg.sender);
  }

  modifier onlyCapper() {
    require(isCapper(msg.sender));
    _;
  }

  function isCapper(address account) public view returns (bool) {
    return cappers.has(account);
  }

  function addCapper(address account) public onlyCapper {
    _addCapper(account);
  }

  function renounceCapper() public {
    _removeCapper(msg.sender);
  }

  function _addCapper(address account) internal {
    cappers.add(account);
    emit CapperAdded(account);
  }

  function _removeCapper(address account) internal {
    cappers.remove(account);
    emit CapperRemoved(account);
  }
}

/**
 * @title Depot
 * @dev Minting can only be directed to Depot accounts.
 */
contract Depot is CapperRole {

  mapping(address => bool) private _depotAddress;

  modifier onlyDepot(address depot) {
    require(_isDepot(depot), "not a depot address");
    _;
  }

  function addDepot(address depot)
    public
    onlyCapper
  {
    _addDepot(depot);
  }

  function removeDepot(address depot)
    public
    onlyCapper
    onlyDepot(depot)
  {
    _removeDepot(depot);
  }

  function isDepot(address someAddr) public view returns (bool) {
    return _isDepot(someAddr);
  }

  /**
   * Add a depot address.
   */
  function _addDepot(address depot) internal {
    require(depot != address(0), "depot cannot be null");
    _depotAddress[depot] = true;
  }

  function _removeDepot(address depot) internal {
    _depotAddress[depot] = false;
  }

  function _isDepot(address someAddr) internal view returns (bool) {
    return _depotAddress[someAddr];
  }

}


contract MinterRole {
  using Roles for Roles.Role;

  event MinterAdded(address indexed account);
  event MinterRemoved(address indexed account);

  Roles.Role private minters;

  constructor() internal {
    _addMinter(msg.sender);
  }

  modifier onlyMinter() {
    require(isMinter(msg.sender));
    _;
  }

  function isMinter(address account) public view returns (bool) {
    return minters.has(account);
  }

  function addMinter(address account) public onlyMinter {
    _addMinter(account);
  }

  function renounceMinter() public {
    _removeMinter(msg.sender);
  }

  function _addMinter(address account) internal {
    minters.add(account);
    emit MinterAdded(account);
  }

  function _removeMinter(address account) internal {
    minters.remove(account);
    emit MinterRemoved(account);
  }
}



contract PauserRole {
  using Roles for Roles.Role;

  event PauserAdded(address indexed account);
  event PauserRemoved(address indexed account);

  Roles.Role private pausers;

  constructor() internal {
    _addPauser(msg.sender);
  }

  modifier onlyPauser() {
    require(isPauser(msg.sender));
    _;
  }

  function isPauser(address account) public view returns (bool) {
    return pausers.has(account);
  }

  function addPauser(address account) public onlyPauser {
    _addPauser(account);
  }

  function renouncePauser() public {
    _removePauser(msg.sender);
  }

  function _addPauser(address account) internal {
    pausers.add(account);
    emit PauserAdded(account);
  }

  function _removePauser(address account) internal {
    pausers.remove(account);
    emit PauserRemoved(account);
  }
}


/**
 * @title Ownable
 * @dev The Ownable contract has an owner address, and provides basic authorization control
 * functions, this simplifies the implementation of "user permissions".
 */
contract Ownable {
  address private _owner;

  event OwnershipTransferred(
    address indexed previousOwner,
    address indexed newOwner
  );

  /**
   * @dev The Ownable constructor sets the original `owner` of the contract to the sender
   * account.
   */
  constructor() internal {
    _owner = msg.sender;
    emit OwnershipTransferred(address(0), _owner);
  }

  /**
   * @return the address of the owner.
   */
  function owner() public view returns(address) {
    return _owner;
  }

  /**
   * @dev Throws if called by any account other than the owner.
   */
  modifier onlyOwner() {
    require(isOwner());
    _;
  }

  /**
   * @return true if `msg.sender` is the owner of the contract.
   */
  function isOwner() public view returns(bool) {
    return msg.sender == _owner;
  }

  /**
   * @dev Allows the current owner to relinquish control of the contract.
   * @notice Renouncing to ownership will leave the contract without an owner.
   * It will not be possible to call the functions with the `onlyOwner`
   * modifier anymore.
   */
  function renounceOwnership() public onlyOwner {
    emit OwnershipTransferred(_owner, address(0));
    _owner = address(0);
  }

  /**
   * @dev Allows the current owner to transfer control of the contract to a newOwner.
   * @param newOwner The address to transfer ownership to.
   */
  function transferOwnership(address newOwner) public onlyOwner {
    _transferOwnership(newOwner);
  }

  /**
   * @dev Transfers control of the contract to a newOwner.
   * @param newOwner The address to transfer ownership to.
   */
  function _transferOwnership(address newOwner) internal {
    require(newOwner != address(0));
    emit OwnershipTransferred(_owner, newOwner);
    _owner = newOwner;
  }
}


/**
 * @title ERC20Mintable
 * @dev ERC20 minting logic
 */
contract ERC20Mintable is ERC20, MinterRole {
  /**
   * @dev Function to mint tokens
   * @param to The address that will receive the minted tokens.
   * @param value The amount of tokens to mint.
   * @return A boolean that indicates if the operation was successful.
   */
  function mint(
    address to,
    uint256 value
  )
    public
    onlyMinter
    returns (bool)
  {
    _mint(to, value);
    return true;
  }
}



/**
 * @title Pausable
 * @dev Base contract which allows children to implement an emergency stop mechanism.
 */
contract Pausable is PauserRole {
  event Paused(address account);
  event Unpaused(address account);

  bool private _paused;

  constructor() internal {
    _paused = false;
  }

  /**
   * @return true if the contract is paused, false otherwise.
   */
  function paused() public view returns(bool) {
    return _paused;
  }

  /**
   * @dev Modifier to make a function callable only when the contract is not paused.
   */
  modifier whenNotPaused() {
    require(!_paused);
    _;
  }

  /**
   * @dev Modifier to make a function callable only when the contract is paused.
   */
  modifier whenPaused() {
    require(_paused);
    _;
  }

  /**
   * @dev called by the owner to pause, triggers stopped state
   */
  function pause() public onlyPauser whenNotPaused {
    _paused = true;
    emit Paused(msg.sender);
  }

  /**
   * @dev called by the owner to unpause, returns to normal state
   */
  function unpause() public onlyPauser whenPaused {
    _paused = false;
    emit Unpaused(msg.sender);
  }
}



/**
 * @title Pausable token
 * @dev ERC20 modified with pausable transfers.
 **/
contract ERC20Pausable is ERC20, Pausable {

  function transfer(
    address to,
    uint256 value
  )
    public
    whenNotPaused
    returns (bool)
  {
    return super.transfer(to, value);
  }

  function transferFrom(
    address from,
    address to,
    uint256 value
  )
    public
    whenNotPaused
    returns (bool)
  {
    return super.transferFrom(from, to, value);
  }

  function approve(
    address spender,
    uint256 value
  )
    public
    whenNotPaused
    returns (bool)
  {
    return super.approve(spender, value);
  }

  function increaseAllowance(
    address spender,
    uint addedValue
  )
    public
    whenNotPaused
    returns (bool success)
  {
    return super.increaseAllowance(spender, addedValue);
  }

  function decreaseAllowance(
    address spender,
    uint subtractedValue
  )
    public
    whenNotPaused
    returns (bool success)
  {
    return super.decreaseAllowance(spender, subtractedValue);
  }
}


/**
 * @title Capped token - also, limit minting targets to depots.
 * @dev Mintable token with a token cap.
 */
contract Capped is Depot, ERC20Mintable {

  uint256 private _cap;

  constructor(uint256 cap)
    public
  {
    require(cap > 0, 'Cap cannot be zero');
    _cap = cap;
  }

  /**
   * @return the cap for the token minting.
   */
  function cap() public view returns(uint256) {
    return _cap;
  }

  function setCap(uint256 newCap)
    public
    onlyCapper
  {
    _setCap(newCap);
  }

  /**
   * Cap cannot be reduced, can only be increased.
   */
  function _setCap(uint256 newCap) internal {
    if (newCap > _cap) _cap = newCap;
  }

  /**
   * @dev Function to mint tokens
   * @param to The address that will receive the minted tokens.
   * @param value The amount of tokens to mint.
   * @return A boolean that indicates if the operation was successful.
   */
  function mint(
    address to,
    uint256 value
  )
    public
    onlyMinter
    onlyDepot(to)
    returns (bool)
  {
    require(totalSupply().add(value) <= _cap, "mint value limit exceeded");

    return super.mint(to, value);
  }

}


/**
 * @title SafeMath
 * @dev Math operations with safety checks that revert on error
 */
library SafeMath {

  /**
  * @dev Multiplies two numbers, reverts on overflow.
  */
  function mul(uint256 a, uint256 b) internal pure returns (uint256) {
    // Gas optimization: this is cheaper than requiring 'a' not being zero, but the
    // benefit is lost if 'b' is also tested.
    // See: https://github.com/OpenZeppelin/openzeppelin-solidity/pull/522
    if (a == 0) {
      return 0;
    }

    uint256 c = a * b;
    require(c / a == b);

    return c;
  }

  /**
  * @dev Integer division of two numbers truncating the quotient, reverts on division by zero.
  */
  function div(uint256 a, uint256 b) internal pure returns (uint256) {
    require(b > 0); // Solidity only automatically asserts when dividing by 0
    uint256 c = a / b;
    // assert(a == b * c + a % b); // There is no case in which this doesn't hold

    return c;
  }

  /**
  * @dev Subtracts two numbers, reverts on overflow (i.e. if subtrahend is greater than minuend).
  */
  function sub(uint256 a, uint256 b) internal pure returns (uint256) {
    require(b <= a);
    uint256 c = a - b;

    return c;
  }

  /**
  * @dev Adds two numbers, reverts on overflow.
  */
  function add(uint256 a, uint256 b) internal pure returns (uint256) {
    uint256 c = a + b;
    require(c >= a);

    return c;
  }

  /**
  * @dev Divides two numbers and returns the remainder (unsigned integer modulo),
  * reverts when dividing by zero.
  */
  function mod(uint256 a, uint256 b) internal pure returns (uint256) {
    require(b != 0);
    return a % b;
  }
}


/// token.sol - base class for all Rock Stable tokens

// Copyright (C) 2018, 2019 Rock Stable Token Inc

// This is based on OpenZeppelin code.
// You may not use this file except in compliance with the MIT License.

// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND (express or implied).


contract Constants {
    uint public constant DENOMINATOR = 10000; // deprecated
    uint public constant DECIMALS = 18;
    uint public constant WAD = 10**DECIMALS;
}

contract Token is Constants, Ownable, ERC20Pausable, Capped {
    string  public symbol;
    uint256 public decimals;
    string  public name;

    modifier condition(bool _condition) {
      require(_condition, "condition not met");
      _;
    }

    constructor(address _owner, uint256 _cap)
        public
        Capped(_cap)
    {
      require(_owner != 0, "proposed owner is null");
      if (msg.sender != _owner) {
        super.transferOwnership(_owner);
        super.addCapper(_owner);
        super.addPauser(_owner);
      }
    }

}




// Universal Token
contract UniversalToken is Token {
    using SafeMath for uint256;

    uint public xactionFeeNumerator;
    uint public xactionFeeShare;

    event ModifyTransFeeCalled(uint newFee);
    event ModifyFeeShareCalled(uint newShare);

    // Note: the constructor only sets the Cap, but does not set the initial supply.
    //
    constructor( 
        uint initialCap,
        uint feeMult,
        uint feeShare
        )
          public
          Token(msg.sender, initialCap)
    {
        require(initialCap > 0, "initial supply must be greater than 0");
        require(feeMult > 0, "fee multiplier must be non-zero");
        symbol = "UETR";
        name = "Universal Evangelist Token - by Rock Stable Token Inc";
        decimals = DECIMALS;
        xactionFeeNumerator = feeMult;
        xactionFeeShare = feeShare;
    }

    function modifyTransFee(uint _xactionFeeMult) public
        onlyOwner
    {
        require(DENOMINATOR > _xactionFeeMult.mul(4), 'cannot modify transaction fee to more than 0.25');
        xactionFeeNumerator = _xactionFeeMult;
        emit ModifyTransFeeCalled(_xactionFeeMult);
    }

    function modifyFeeShare(uint _share) public
        onlyOwner
    {
        require(DENOMINATOR > _share.mul(3), 'RSTI share must be less than one-third');
        xactionFeeShare = _share;
        emit ModifyFeeShareCalled(_share);
    }
}



// Local Token
contract LocalToken is Token {
    using SafeMath for uint256;

    string  public localityCode;
    uint    public taxRateNumerator = 0;
    address public govtAccount = 0;
    address public pmtAccount = 0;
    UniversalToken public universalToken;

    constructor(
            uint _maxTokens,
            uint _taxRateMult,
            string _tokenSymbol,
            string _tokenName,
            string _localityCode,
            address _govt,
            address _pmt,
            address _universalToken
            )
            public
            condition(_maxTokens > 0)
            condition(DENOMINATOR > _taxRateMult.mul(2))
            condition((_taxRateMult > 0 && _govt != 0) || _taxRateMult == 0)
            condition(_universalToken != 0)
            Token(msg.sender, _maxTokens)
    {
        universalToken = UniversalToken(_universalToken);
        // require(msg.sender == universalToken.owner(), "owner must be the same owner for UniversalToken");
        decimals = DECIMALS;
        symbol = _tokenSymbol;
        name = _tokenName;
        localityCode = _localityCode;
        govtAccount = _govt;
        pmtAccount = _pmt;
        if (_taxRateMult > 0) {
            taxRateNumerator = _taxRateMult;
        }
    }

    // Modify Territory
    // This should only be used when the name of the territory that covers the same
    // area changes in Bing maps.
    // The location of the territory itself should not be modified; in other words,
    // a local token, once created, has a fixed territory.
    function modifyLocality(string newLocality) public
        onlyMinter
    {
        localityCode = newLocality;
    }

    function modifyTaxRate(uint _taxMult) public
        onlyMinter
        condition(DENOMINATOR > _taxMult.mul(2))
    {
        taxRateNumerator = _taxMult;
    }

    // To reset govtAccount when taxRateNumerator is not zero, 
    // must reset taxRateNumerator first.
    // To set govtAccount when taxRateNumerator is zero,
    // must set taxRateNumerator first to non-zero value.
    function modifyGovtAccount(address govt) public
        onlyMinter
    {
        if ((taxRateNumerator > 0 && govt == address(0)) 
            || (taxRateNumerator == 0 && govt != address(0))) revert('invalid input');
        govtAccount = govt;
    }

    function modifyPMTAccount(address _pmt) public
        onlyOwner
    {
        require(_pmt != 0, 'cannot set RockStable address to zero');
        pmtAccount = _pmt;
    }
}



interface IPayment2 {
    // This event should always emit because it is necessary for getting everybody paid in PUR.
    event PaymentConfirmed(address indexed _customerAddr, address indexed _paymentContract, uint _ethValue, uint _roks);

    // Payment created event
    event PaymentContract(bool _payTax, address _evangelist, address _localToken, address _vendor, address _pmntCenter);

    // contract refreshed
    event PaymentContractRefreshed(address _contract);

    // Vendor transferred
    event VendorTransferred(address _fromEvangelist, address _toEvangelist);

    // temporary, for debugging only
    event DebugEvent(address from, address to, uint value);

    function getVendor() external view returns (address);

    function getPmtAccount() external view returns (address);

    // Transfer this vendor to another evangelist.
    // Acquiring evangelist must first approve at least single local token for source vendor.
    function transferThisVendor(address toAnotherEvangelist) external;

    function setPayTax(bool pay) external;

    // Refresh all parameters for calculating transaction fee and taxes.
    // This allows these parameters to be modified in a single place.
    // This refresh routine cost is charged to the evangelist or vendor, but it needs to be done
    // only once a month.
    function refreshFeeParams() external;

    function depositLocalToken() external;

    function destroy() external;

    function getEthPrice() external view returns (uint);

    function setEthPrice(uint ethPrice) external;

    function getRoksExpected() external view returns (uint);

    function setRoksExpected(uint roksExpected) external;

    function getLocalToken() external view returns (LocalToken);
}



contract PureMoney2 is Token {

    event DebugEvent(address from, address to, uint value);

    // Payment contract registered
    event PaymentContractRegistered(address _contract, uint amountApproved);

    constructor( 
        uint initialCap)
          public
          condition(initialCap > 0)
          Token(msg.sender, initialCap)
    {
        symbol = "ROKS";
        name = "Rock Stable Token";
        decimals = DECIMALS;
    }

    // Register Vendor
    // Call this from API server, right after creating a Payment contract.
    // Deposit local token to payment contract.
    // An contract that is deregistered cannot be re-registered.
    // The second param is a count of how many ROKS to approve (in wei units) for the
    // payment contract to transferFrom owner.
    //
    function registerVendor(address _contract, uint amountToApprove)
        public
        onlyOwner
    {
        require(_contract != address(0), 'null contract address');
        require(!this.isRegistered(_contract), 'payment contract is already registered');
        // address source = msg.sender;
        // emit DebugEvent(address(_contract), source, 0);
        IPayment2 pmnt = IPayment2(_contract); // reverts if _contract is not a Payment
        require(pmnt.getVendor() != address(0), 'vendor not set in payment contract');
        require(pmnt.getPmtAccount() != address(0), 'RSTI account not set in payment contract');
        pmnt.depositLocalToken();
        super.approve(address(pmnt), amountToApprove);
        // emit DebugEvent(pmnt.getVendor(), source, 0);
        emit PaymentContractRegistered(_contract, amountToApprove);
    }

    // Deregister a vendor.
    // Vendor's Payment contract will be destroyed and cnnot be revived.
    // If input address is not a Payment contract address, nothing happens.
    // NOTE: Use this with care, only if absolutely necessary. We don't want too many deregistered
    // Payment contracts lying around because if ROKS payment is made to such contracts, the payment
    // is accumulated but can never be taken out.
    //
    function deregisterVendor(address _contract)
        public
        onlyOwner
    {
        require(_contract != address(0), 'null contract address');
        IPayment2 pmnt = IPayment2(_contract); // reverts if _contract is not a Payment
        pmnt.destroy();
        emit DebugEvent(pmnt.getPmtAccount(), address(0), 0);
    }

    // determine if a payment contract is registered
    function isRegistered(address _contract)
        public
        view
        returns (bool)
    {
        return (this.allowance(this.owner(), _contract) > WAD);
    }

    // Determine if TO address is a contract;
    // If it is a Payment contract return vendor address.
    // Otherwise, return the input TO address.
    // The ultimate purpose of this function is to allow direct ROKS payment to vendor address,
    // not just to vendor payment contract address.
    // NOTE: If the destination is an unregistered / deregistered / destroyed Payment contract, 
    // transferred ROKS tokens are accumulated in the Payment contract itself and maybe lost forever.
    // (If the destination is an as yet unregistered Payment contract, the only way to retrieve
    // the ROKS tokens is to first register and then deregister the Payment contract.)
    //
    function getAccountIfContract(address to) internal view returns (address account)
    {
        // fail early
        require(to != address(0), 'destination address is null');
        // is it a Payment contract?
        if (this.isRegistered(to)) {
            IPayment2 pmnt = IPayment2(to);
            LocalToken local = LocalToken(pmnt.getLocalToken());
            require(local.balanceOf(to) >= WAD, 'destination address is an unregistered payment contract');
            return pmnt.getVendor();
        } else {
            return to; // 'to' can be anything
        }
    }

    // Base function override.
    function transfer(address to, uint tokens) public returns (bool success)
    {
        emit DebugEvent(msg.sender, to, tokens);
        address addr = getAccountIfContract(to);
        require(addr != address(0), 'vendor address is zero');
        require(balanceOf(msg.sender) > tokens, 'not enough tokens');
        super._transfer(msg.sender, addr, tokens);
        return true;
    }

    // Base function override.
    function transferFrom(address from, address to, uint tokens) public returns (bool success)
    {
        emit DebugEvent(from, to, tokens);
        return super.transferFrom(from, getAccountIfContract(to), tokens);
    }

}