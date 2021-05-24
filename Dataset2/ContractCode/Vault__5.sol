/*

 Copyright 2017-2018 RigoBlock, Rigo Investment Sagl.

 Licensed under the Apache License, Version 2.0 (the "License");
 you may not use this file except in compliance with the License.
 You may obtain a copy of the License at

     http://www.apache.org/licenses/LICENSE-2.0

 Unless required by applicable law or agreed to in writing, software
 distributed under the License is distributed on an "AS IS" BASIS,
 WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 See the License for the specific language governing permissions and
 limitations under the License.

*/

pragma solidity 0.4.25;
pragma experimental "v0.5.0";

interface Authority {

    /*
     * EVENTS
     */
    event AuthoritySet(address indexed authority);
    event WhitelisterSet(address indexed whitelister);
    event WhitelistedUser(address indexed target, bool approved);
    event WhitelistedRegistry(address indexed registry, bool approved);
    event WhitelistedFactory(address indexed factory, bool approved);
    event WhitelistedVault(address indexed vault, bool approved);
    event WhitelistedDrago(address indexed drago, bool isWhitelisted);
    event NewDragoEventful(address indexed dragoEventful);
    event NewVaultEventful(address indexed vaultEventful);
    event NewNavVerifier(address indexed navVerifier);
    event NewExchangesAuthority(address indexed exchangesAuthority);

    /*
     * CORE FUNCTIONS
     */
    function setAuthority(address _authority, bool _isWhitelisted) external;
    function setWhitelister(address _whitelister, bool _isWhitelisted) external;
    function whitelistUser(address _target, bool _isWhitelisted) external;
    function whitelistDrago(address _drago, bool _isWhitelisted) external;
    function whitelistVault(address _vault, bool _isWhitelisted) external;
    function whitelistRegistry(address _registry, bool _isWhitelisted) external;
    function whitelistFactory(address _factory, bool _isWhitelisted) external;
    function setDragoEventful(address _dragoEventful) external;
    function setVaultEventful(address _vaultEventful) external;
    function setNavVerifier(address _navVerifier) external;
    function setExchangesAuthority(address _exchangesAuthority) external;

    /*
     * CONSTANT PUBLIC FUNCTIONS
     */
    function isWhitelistedUser(address _target) external view returns (bool);
    function isAuthority(address _authority) external view returns (bool);
    function isWhitelistedRegistry(address _registry) external view returns (bool);
    function isWhitelistedDrago(address _drago) external view returns (bool);
    function isWhitelistedVault(address _vault) external view returns (bool);
    function isWhitelistedFactory(address _factory) external view returns (bool);
    function getDragoEventful() external view returns (address);
    function getVaultEventful() external view returns (address);
    function getNavVerifier() external view returns (address);
    function getExchangesAuthority() external view returns (address);
}

interface VaultEventful {

    /*
     * EVENTS
     */
    event BuyVault(address indexed vault, address indexed from, address indexed to, uint256 amount, uint256 revenue, bytes name, bytes symbol);
    event SellVault(address indexed vault, address indexed from, address indexed to, uint256 amount, uint256 revenue, bytes name, bytes symbol);
    event NewRatio(address indexed vault, address indexed from, uint256 newRatio);
    event NewFee(address indexed vault, address indexed from, address indexed to, uint256 fee);
    event NewCollector(address indexed vault, address indexed from, address indexed to, address collector);
    event VaultDao(address indexed vault, address indexed from, address indexed to, address vaultDao);
    event VaultCreated(address indexed vault, address indexed group, address indexed owner, uint256 vaultId, string name, string symbol);

    /*
     * CORE FUNCTIONS
     */
    function buyVault(address _who, address _targetVault, uint256 _value, uint256 _amount, bytes _name, bytes _symbol) external returns (bool success);
    function sellVault(address _who, address _targetVault, uint256 _amount, uint256 _revenue, bytes _name, bytes _symbol) external returns(bool success);
    function changeRatio(address _who, address _targetVault, uint256 _ratio) external returns(bool success);
    function setTransactionFee(address _who, address _targetVault, uint256 _transactionFee) external returns(bool success);
    function changeFeeCollector(address _who, address _targetVault, address _feeCollector) external returns(bool success);
    function changeVaultDao(address _who, address _targetVault, address _vaultDao) external returns(bool success);
    function createVault(address _who, address _newVault, string _name, string _symbol, uint256 _vaultId) external returns(bool success);
}

interface Token {

    event Transfer(address indexed _from, address indexed _to, uint256 _value);
    event Approval(address indexed _owner, address indexed _spender, uint256 _value);

    function transfer(address _to, uint256 _value) external returns (bool success);
    function transferFrom(address _from, address _to, uint256 _value) external returns (bool success);
    function approve(address _spender, uint256 _value) external returns (bool success);

    function balanceOf(address _who) external view returns (uint256);
    function allowance(address _owner, address _spender) external view returns (uint256);
}

contract ReentrancyGuard {

    // Locked state of mutex
    bool private locked = false;

    /// @dev Functions with this modifer cannot be reentered. The mutex will be locked
    ///      before function execution and unlocked after.
    modifier nonReentrant() {
        // Ensure mutex is unlocked
        require(
            !locked,
            "REENTRANCY_ILLEGAL"
        );

        // Lock mutex before function call
        locked = true;

        // Perform function call
        _;

        // Unlock mutex after function call
        locked = false;
    }
}

contract Owned {

    address public owner;

    event NewOwner(address indexed old, address indexed current);

    modifier onlyOwner {
        require(msg.sender == owner);
        _;
    }

    function setOwner(address _new) public onlyOwner {
        require(_new != address(0));
        owner = _new;
        emit  NewOwner(owner, _new);
    }
}

contract SafeMath {

    function safeMul(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a * b;
        assert(a == 0 || c / a == b);
        return c;
    }

    function safeDiv(uint256 a, uint256 b) internal pure returns (uint256) {
        assert(b > 0);
        uint256 c = a / b;
        assert(a == b * c + a % b);
        return c;
    }

    function safeSub(uint256 a, uint256 b) internal pure returns (uint256) {
        assert(b <= a);
        return a - b;
    }

    function safeAdd(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        assert(c>=a && c>=b);
        return c;
    }
}

interface VaultFace {

    /*
     * CORE FUNCTIONS
     */
    function buyVault() external payable returns (bool success);
    function buyVaultOnBehalf(address _hodler) external payable returns (bool success);
    function sellVault(uint256 amount) external returns (bool success);
    function changeRatio(uint256 _ratio) external;
    function setTransactionFee(uint256 _transactionFee) external;
    function changeFeeCollector(address _feeCollector) external;
    function changeVaultDao(address _vaultDao) external;
    function updatePrice() external;
    function changeMinPeriod(uint32 _minPeriod) external;
    function depositToken(address _token, uint256 _value, uint8 _forTime) external returns (bool success);
    function depositTokenOnBehalf(address _token, address _hodler, uint256 _value, uint8 _forTime) external returns (bool success);
    function withdrawToken(address _token, uint256 _value) external returns (bool success);

    /*
     * CONSTANT PUBLIC FUNCTIONS
     */
    function balanceOf(address _who) external view returns (uint256);
    function tokenBalanceOf(address _token, address _owner) external view returns (uint256);
    function timeToUnlock(address _token, address _user) external view returns (uint256);
    function tokensInVault(address _token) external view returns (uint256);
    function getEventful() external view returns (address);
    function getData() external view returns (string name, string symbol, uint256 sellPrice, uint256 buyPrice);
    function calcSharePrice() external view returns (uint256);
    function getAdminData() external view returns (address, address feeCollector, address vaultDao, uint256 ratio, uint256 transactionFee, uint32 minPeriod);
    function totalSupply() external view returns (uint256);
}

/// @title Vault - contract for creating a vault type of pool.
/// @author Gabriele Rigo - <gab@rigoblock.com>
// solhint-disable-next-line
contract Vault is Owned, SafeMath, ReentrancyGuard, VaultFace {

    string constant VERSION = 'VC 0.5.2';
    uint256 constant BASE = 1000000; //tokens are divisible by 1 million

    VaultData data;
    Admin admin;

    mapping (address => Account) accounts;

    mapping (address => uint256) totalTokens;
    mapping (address => mapping (address => uint256)) public depositLock;
    mapping (address => mapping (address => uint256)) public tokenBalances;

    struct Receipt {
        uint32 activation;
    }

    struct Account {
        uint256 balance;
        Receipt receipt;
    }

    struct VaultData {
        string name;
        string symbol;
        uint256 vaultId;
        uint256 totalSupply;
        uint256 price;
        uint256 transactionFee; // fee is in basis points (1 bps = 0.01%)
        uint32 minPeriod;
        uint128 validatorIndex;
    }

    struct Admin {
        address authority;
        address vaultDao;
        address feeCollector;
        uint256 minOrder; // minimum stake to avoid dust clogging things up
        uint256 ratio; // ratio is 80%
    }

    modifier onlyVaultDao {
        require(msg.sender == admin.vaultDao);
        _;
    }

    modifier onlyOwner {
        require(msg.sender == owner);
        _;
    }

    modifier minimumStake(uint256 _amount) {
        require(_amount >= admin.minOrder);
        _;
    }

    modifier hasEnough(uint256 _amount) {
        require(accounts[msg.sender].balance >= _amount);
        _;
    }

    modifier positiveAmount(uint256 _amount) {
        require(accounts[msg.sender].balance + _amount > accounts[msg.sender].balance);
        _;
    }

    modifier minimumPeriodPast {
        require(now >= accounts[msg.sender].receipt.activation);
        _;
    }

    constructor(
        string _vaultName,
        string _vaultSymbol,
        uint256 _vaultId,
        address _owner,
        address _authority)
        public
    {
        data.name = _vaultName;
        data.symbol = _vaultSymbol;
        data.vaultId = _vaultId;
        data.price = 1 ether; //initial price is 1 Ether
        owner = _owner;
        admin.authority = _authority;
        admin.vaultDao = msg.sender;
        admin.minOrder = 1 finney;
        admin.feeCollector = _owner;
        admin.ratio = 80;
    }

    /*
     * CORE FUNCTIONS
     */
    /// @dev Allows a user to buy into a vault
    /// @return Bool the function executed correctly
    function buyVault()
        external
        payable
        minimumStake(msg.value)
        returns (bool success)
    {
        require(buyVaultInternal(msg.sender, msg.value));
        return true;
    }

    /// @dev Allows a user to buy into a vault on behalf of an address
    /// @param _hodler Address of the target user
    /// @return Bool the function executed correctly
    function buyVaultOnBehalf(address _hodler)
        external
        payable
        minimumStake(msg.value)
        returns (bool success)
    {
        require(buyVaultInternal(_hodler, msg.value));
        return true;
    }

    /// @dev Allows a user to sell from a vault
    /// @param _amount Number of shares to sell
    /// @return Bool the function executed correctly
    function sellVault(uint256 _amount)
        external
        nonReentrant
        hasEnough(_amount)
        positiveAmount(_amount)
        minimumPeriodPast
        returns (bool success)
    {
        updatePriceInternal();
        uint256 feeVault;
        uint256 feeVaultDao;
        uint256 netAmount;
        uint256 netRevenue;
        (feeVault, feeVaultDao, netAmount, netRevenue) = getSaleAmounts(_amount);
        addSaleLog(_amount, netRevenue);
        allocateSaleTokens(msg.sender, _amount, feeVault, feeVaultDao);
        data.totalSupply = safeSub(data.totalSupply, netAmount);
        msg.sender.transfer(netRevenue);
        return true;
    }

    /// @dev Allows vault dao/factory to change fee split ratio
    /// @param _ratio Number of ratio for wizard, from 0 to 100
    function changeRatio(uint256 _ratio)
        external
        onlyVaultDao
    {
        Authority auth = Authority(admin.authority);
        VaultEventful events = VaultEventful(auth.getVaultEventful());
        require(events.changeRatio(msg.sender, this, _ratio));
        admin.ratio = _ratio;
    }

    /// @dev Allows vault owner to set the transaction fee
    /// @param _transactionFee Value of the transaction fee in basis points
    function setTransactionFee(uint256 _transactionFee)
        external
        onlyOwner
    {
        require(_transactionFee <= 100); //fee cannot be higher than 1%
        Authority auth = Authority(admin.authority);
        VaultEventful events = VaultEventful(auth.getVaultEventful());
        require(events.setTransactionFee(msg.sender, this, _transactionFee));
        data.transactionFee = _transactionFee;
    }

    /// @dev Allows owner to decide where to receive the fee
    /// @param _feeCollector Address of the fee receiver
    function changeFeeCollector(address _feeCollector)
        external
        onlyOwner
    {
        Authority auth = Authority(admin.authority);
        VaultEventful events = VaultEventful(auth.getVaultEventful());
        require(events.changeFeeCollector(msg.sender, this, _feeCollector));
        admin.feeCollector = _feeCollector;
    }

    /// @dev Allows vault dao/factory to upgrade its address
    /// @param _vaultDao Address of the new vault dao
    function changeVaultDao(address _vaultDao)
        external
        onlyVaultDao
    {
        Authority auth = Authority(admin.authority);
        VaultEventful events = VaultEventful(auth.getVaultEventful());
        require(events.changeVaultDao(msg.sender, this, _vaultDao));
        admin.vaultDao = _vaultDao;
    }

    /// @dev Allows anyone to pay and update the price
    /// @dev This function allows to write the new nav
    /// @dev NAV is provided by view functions
    function updatePrice()
        external
        nonReentrant
    {
        updatePriceInternal();
    }

    /// @dev Allows vault dao/factory to change the minimum holding period
    /// @param _minPeriod Lockup time in seconds
    function changeMinPeriod(uint32 _minPeriod)
        external
        onlyVaultDao
    {
        data.minPeriod = _minPeriod;
    }

    /// @dev Allows anyone to deposit tokens to a vault
    /// @param _token Address of the token
    /// @param _value Amount to deposit
    /// @param _forTime Lockup time in seconds
    /// @notice lockup time can be zero
    function depositToken(
        address _token,
        uint256 _value,
        uint8 _forTime)
        external
        nonReentrant
        returns (bool success)
    {
        require(depositTokenInternal(_token, msg.sender, _value, _forTime));
        return true;
    }

    /// @dev Allows anyone to deposit tokens to a vault on behalf of someone
    /// @param _token Address of the token
    /// @param _value Amount to deposit
    /// @param _forTime Lockup time in seconds
    /// @notice lockup time can be zero
    function depositTokenOnBehalf(
        address _token,
        address _hodler,
        uint256 _value,
        uint8 _forTime)
        external
        returns (bool success)
    {
        require(depositTokenInternal(_token, _hodler, _value, _forTime));
        return true;
    }

    /// @dev Allows anyone to withdraw tokens from a vault
    /// @param _token Address of the token
    /// @param _value Amount to withdraw
    /// @return Bool the transaction was successful
    function withdrawToken(
        address _token,
        uint256 _value)
        external
        nonReentrant
        returns
        (bool success)
    {
        require(tokenBalances[_token][msg.sender] >= _value);
        require(uint32(now) > depositLock[_token][msg.sender]);
        tokenBalances[_token][msg.sender] = safeSub(tokenBalances[_token][msg.sender], _value);
        totalTokens[_token] = safeSub(totalTokens[_token], _value);
        require(Token(_token).transfer(msg.sender, _value));
        return true;
    }

    /*
     * CONSTANT PUBLIC FUNCTIONS
     */
    /// @dev Calculates how many shares a user holds
    /// @param _from Address of the target account
    /// @return Number of shares
    function balanceOf(address _from)
        external
        view
        returns (uint256)
    {
        return accounts[_from].balance;
    }

    /// @dev Returns a user balance of a certain deposited token
    /// @param _token Address of the token
    /// @param _owner Address of the user
    /// @return Number of tokens
    function tokenBalanceOf(
        address _token,
        address _owner)
        external
        view
        returns (uint256)
    {
        return tokenBalances[_token][_owner];
    }

    /// @dev Returns the time needed to withdraw
    /// @param _token Address of the token
    /// @param _user Address of the user
    /// @return Time in seconds
    function timeToUnlock(
        address _token,
        address _user)
        external
        view
        returns (uint256)
    {
        return depositLock[_token][_user];
    }

    /// @dev Returns the amount of tokens of a certain token in vault
    /// @param _token Address of the token
    /// @return _value in custody
    function tokensInVault(address _token)
        external
        view
        returns (uint256)
    {
        return totalTokens[_token];
    }

    /// @dev Gets the address of the logger contract
    /// @return Address of the logger contrac
    function getEventful()
        external
        view
        returns (address)
    {
        Authority auth = Authority(admin.authority);
        return auth.getVaultEventful();
    }

    /// @dev Finds details of a vault pool
    /// @return String name of a vault
    /// @return String symbol of a vault
    /// @return Value of the share price in wei
    /// @return Value of the share price in wei
    function getData()
        external
        view
        returns (
            string name,
            string symbol,
            uint256 sellPrice,
            uint256 buyPrice
        )
    {
        return(
            name = data.name,
            symbol = data.symbol,
            sellPrice = getNav(),
            buyPrice = getNav()
        );
    }

    /// @dev Returns the price of a pool
    /// @return Value of the share price in wei
    function calcSharePrice()
        external
        view
        returns (uint256)
    {
        return getNav();
    }

    /// @dev Finds the administrative data of the pool
    /// @return Address of the account where a user collects fees
    /// @return Address of the vault dao/factory
    /// @return Number of the fee split ratio
    /// @return Value of the transaction fee in basis points
    /// @return Number of the minimum holding period for shares
    function getAdminData()
        external
        view
        returns (
            address,
            address feeCollector,
            address vaultDao,
            uint256 ratio,
            uint256 transactionFee,
            uint32 minPeriod
        )
    {
        return (
            owner,
            admin.feeCollector,
            admin.vaultDao,
            admin.ratio,
            data.transactionFee,
            data.minPeriod
        );
    }

    /// @dev Returns the total amount of issued tokens for this vault
    /// @return Number of shares
    function totalSupply()
        external
        view
        returns (uint256)
    {
        return data.totalSupply;
    }

    /*
     * INTERNAL FUNCTIONS
     */
    /// @dev Executes purchase function
    /// @param _hodler Address of the target user
    /// @return Bool the function executed correctly
    function buyVaultInternal(
        address _hodler,
        uint256 _totalEth)
        internal
        returns (bool success)
    {
        updatePriceInternal();
        uint256 grossAmount;
        uint256 feeVault;
        uint256 feeVaultDao;
        uint256 amount;
        (grossAmount, feeVault, feeVaultDao, amount) = getPurchaseAmounts(_totalEth);
        addPurchaseLog(amount);
        allocatePurchaseTokens(_hodler, amount, feeVault, feeVaultDao);
        data.totalSupply = safeAdd(data.totalSupply, grossAmount);
        return true;
    }

    /// @dev Updates the price
    function updatePriceInternal()
        internal
    {
        if (address(this).balance > 0) {
            data.price = getNav();
        }
    }

    /// @dev Allocates tokens to buyer, splits fee in tokens to wizard and dao
    /// @param _hodler Address of the buyer
    /// @param _amount Value of issued tokens
    /// @param _feeVault Number of shares as fee
    /// @param _feeVaultDao Number of shares as fee to dao
    function allocatePurchaseTokens(
        address _hodler,
        uint256 _amount,
        uint256 _feeVault,
        uint256 _feeVaultDao)
        internal
    {
        accounts[_hodler].balance = safeAdd(accounts[_hodler].balance, _amount);
        accounts[admin.feeCollector].balance = safeAdd(accounts[admin.feeCollector].balance, _feeVault);
        accounts[admin.vaultDao].balance = safeAdd(accounts[admin.vaultDao].balance, _feeVaultDao);
        accounts[_hodler].receipt.activation = uint32(now) + data.minPeriod;
    }

    /// @dev Destroys tokens from buyer, splits fee in tokens to wizard and dao
    /// @param _hodler Address of the seller
    /// @param _amount Value of burnt tokens
    /// @param _feeVault Number of shares as fee
    /// @param _feeVaultDao Number of shares as fee to dao
    function allocateSaleTokens(
        address _hodler,
        uint256 _amount,
        uint256 _feeVault,
        uint256 _feeVaultDao)
        internal
    {
        accounts[_hodler].balance = safeSub(accounts[_hodler].balance, _amount);
        accounts[admin.feeCollector].balance = safeAdd(accounts[admin.feeCollector].balance, _feeVault);
        accounts[admin.vaultDao].balance = safeAdd(accounts[admin.vaultDao].balance, _feeVaultDao);
    }

    /// @dev Sends a buy log to the eventful contract
    /// @param _amount Number of purchased shares
    function addPurchaseLog(uint256 _amount)
        internal
    {
        bytes memory name = bytes(data.name);
        bytes memory symbol = bytes(data.symbol);
        Authority auth = Authority(admin.authority);
        VaultEventful events = VaultEventful(auth.getVaultEventful());
        require(events.buyVault(msg.sender, this, msg.value, _amount, name, symbol));
    }

    /// @dev Sends a sell log to the eventful contract
    /// @param _amount Number of sold shares
    /// @param _netRevenue Value of sale for hodler
    function addSaleLog(
        uint256 _amount,
        uint256 _netRevenue)
        internal
    {
        bytes memory name = bytes(data.name);
        bytes memory symbol = bytes(data.symbol);
        Authority auth = Authority(admin.authority);
        VaultEventful events = VaultEventful(auth.getVaultEventful());
        require(events.sellVault(msg.sender, this, _amount, _netRevenue, name, symbol));
    }
    
    /// @dev Executes a deposit
    /// @param _token Address of the token to be deposited
    /// @param _hodler Address of the hodler
    /// @param _value Amount of tokens
    /// @param _forTime Time in seconds of lockup
    /// @return Bool the transaction was successful
    function depositTokenInternal(
        address _token,
        address _hodler,
        uint256 _value,
        uint8 _forTime)
        internal
        returns (bool success)
    {
        require(now + _forTime >= depositLock[_token][_hodler]);
        require(Token(_token).approve(address(this), _value));
        require(Token(_token).transferFrom(msg.sender, address(this), _value));
        tokenBalances[_token][_hodler] = safeAdd(tokenBalances[_token][_hodler], _value);
        totalTokens[_token] = safeAdd(totalTokens[_token], _value);
        depositLock[_token][_hodler] = safeAdd(uint(now), _forTime);
        return true;
    }

    /// @dev Calculates the correct purchase amounts
    /// @return Number of new shares
    /// @return Value of fee in shares
    /// @return Value of fee in shares to dao
    /// @return Value of net purchased shares
    function getPurchaseAmounts(uint256 _totalEth)
        internal
        view
        returns (
            uint256 grossAmount,
            uint256 feeVault,
            uint256 feeVaultDao,
            uint256 amount
        )
    {
        grossAmount = safeDiv(_totalEth * BASE, data.price);
        uint256 fee = safeMul(grossAmount, data.transactionFee) / 10000; //fee is in basis points
        return (
            grossAmount,
            feeVault = safeMul(fee , admin.ratio) / 100,
            feeVaultDao = safeSub(fee, feeVault),
            amount = safeSub(grossAmount, fee)
        );
    }

    /// @dev Calculates the correct sale amounts
    /// @return Value of fee in shares
    /// @return Value of fee in shares to dao
    /// @return Value of net sold shares
    /// @return Value of sale amount for hodler
    function getSaleAmounts(uint256 _amount)
        internal
        view
        returns (
            uint256 feeVault,
            uint256 feeVaultDao,
            uint256 netAmount,
            uint256 netRevenue
        )
    {
        uint256 fee = safeMul(_amount, data.transactionFee) / 10000; //fee is in basis points
        return (
            feeVault = safeMul(fee, admin.ratio) / 100,
            feeVaultDao = safeSub(fee, feeVaultDao),
            netAmount = safeSub(_amount, fee),
            netRevenue = (safeMul(netAmount, data.price) / BASE)
        );
    }

    /// @dev Calculates the value of the shares
    /// @return Value of the shares in wei
    function getNav()
        internal
        view
        returns (uint256)
    {
        uint256 aum = address(this).balance - msg.value;
        return (data.totalSupply == 0 ? data.price : safeDiv(aum * BASE, data.totalSupply));
    }
}