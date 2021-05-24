pragma solidity ^0.5.8;

library SafeMath {
    /**
     * @dev Returns the addition of two unsigned integers, reverting on
     * overflow.
     *
     * Counterpart to Solidity's `+` operator.
     *
     * Requirements:
     * - Addition cannot overflow.
     */
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");

        return c;
    }

    /**
     * @dev Returns the subtraction of two unsigned integers, reverting on
     * overflow (when the result is negative).
     *
     * Counterpart to Solidity's `-` operator.
     *
     * Requirements:
     * - Subtraction cannot overflow.
     */
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b <= a, "SafeMath: subtraction overflow");
        uint256 c = a - b;

        return c;
    }

    /**
     * @dev Returns the multiplication of two unsigned integers, reverting on
     * overflow.
     *
     * Counterpart to Solidity's `*` operator.
     *
     * Requirements:
     * - Multiplication cannot overflow.
     */
    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        // Gas optimization: this is cheaper than requiring 'a' not being zero, but the
        // benefit is lost if 'b' is also tested.
        // See: https://github.com/OpenZeppelin/openzeppelin-contracts/pull/522
        if (a == 0) {
            return 0;
        }

        uint256 c = a * b;
        require(c / a == b, "SafeMath: multiplication overflow");

        return c;
    }

    /**
     * @dev Returns the integer division of two unsigned integers. Reverts on
     * division by zero. The result is rounded towards zero.
     *
     * Counterpart to Solidity's `/` operator. Note: this function uses a
     * `revert` opcode (which leaves remaining gas untouched) while Solidity
     * uses an invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     * - The divisor cannot be zero.
     */
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        // Solidity only automatically asserts when dividing by 0
        require(b > 0, "SafeMath: division by zero");
        uint256 c = a / b;
        // assert(a == b * c + a % b); // There is no case in which this doesn't hold

        return c;
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers. (unsigned integer modulo),
     * Reverts when dividing by zero.
     *
     * Counterpart to Solidity's `%` operator. This function uses a `revert`
     * opcode (which leaves remaining gas untouched) while Solidity uses an
     * invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     * - The divisor cannot be zero.
     */
    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b != 0, "SafeMath: modulo by zero");
        return a % b;
    }
}

contract Ownable {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    /**
     * @dev Initializes the contract setting the deployer as the initial owner.
     */
    constructor () internal {
        _owner = msg.sender;
        emit OwnershipTransferred(address(0), _owner);
    }

    /**
     * @dev Returns the address of the current owner.
     */
    function owner() public view returns (address) {
        return _owner;
    }

    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        require(isOwner(), "Ownable: caller is not the owner");
        _;
    }

    /**
     * @dev Returns true if the caller is the current owner.
     */
    function isOwner() public view returns (bool) {
        return msg.sender == _owner;
    }

    /**
     * @dev Leaves the contract without owner. It will not be possible to call
     * `onlyOwner` functions anymore. Can only be called by the current owner.
     *
     * > Note: Renouncing ownership will leave the contract without an owner,
     * thereby removing any functionality that is only available to the owner.
     */
    function renounceOwnership() public onlyOwner {
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Can only be called by the current owner.
     */
    function transferOwnership(address newOwner) public onlyOwner {
        _transferOwnership(newOwner);
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     */
    function _transferOwnership(address newOwner) internal {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}

interface IERC20 {
    /**
     * @dev Returns the amount of tokens in existence.
     */
    function totalSupply() external view returns (uint256);

    /**
     * @dev Returns the amount of tokens owned by `account`.
     */
    function balanceOf(address account) external view returns (uint256);

    /**
     * @dev Moves `amount` tokens from the caller's account to `recipient`.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a `Transfer` event.
     */
    function transfer(address recipient, uint256 amount) external returns (bool);

    /**
     * @dev Returns the remaining number of tokens that `spender` will be
     * allowed to spend on behalf of `owner` through `transferFrom`. This is
     * zero by default.
     *
     * This value changes when `approve` or `transferFrom` are called.
     */
    function allowance(address owner, address spender) external view returns (uint256);

    /**
     * @dev Sets `amount` as the allowance of `spender` over the caller's tokens.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * > Beware that changing an allowance with this method brings the risk
     * that someone may use both the old and the new allowance by unfortunate
     * transaction ordering. One possible solution to mitigate this race
     * condition is to first reduce the spender's allowance to 0 and set the
     * desired value afterwards:
     * https://github.com/ethereum/EIPs/issues/20#issuecomment-263524729
     *
     * Emits an `Approval` event.
     */
    function approve(address spender, uint256 amount) external returns (bool);

    /**
     * @dev Moves `amount` tokens from `sender` to `recipient` using the
     * allowance mechanism. `amount` is then deducted from the caller's
     * allowance.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a `Transfer` event.
     */
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);

    /**
     * @dev Emitted when `value` tokens are moved from one account (`from`) to
     * another (`to`).
     *
     * Note that `value` may be zero.
     */
    event Transfer(address indexed from, address indexed to, uint256 value);

    /**
     * @dev Emitted when the allowance of a `spender` for an `owner` is set by
     * a call to `approve`. `value` is the new allowance.
     */
    event Approval(address indexed owner, address indexed spender, uint256 value);
}

contract CampaignFund is Ownable {
    using SafeMath for uint256;

    struct CampaignInfo {
        // UUID identifying this campaign
        string uuid;
        // Descriptive name for this campaign
        string name;
        // Budget is the agreed funding for a merchant
        uint256 budget;
        // Address of who will finance this campaign
        address funder;
        // Current funding of this campaign (should not exceed budget)
        uint256 funding;
        // Indicates if this campaign was initialized by Olyseum owner
        bool initialized;
    }

    mapping(string => CampaignInfo) private _campaignInfoMap;

    struct SubcampaignInfo {
        // UUID identifying this subcampaign
        string uuid;
        // Descriptive name for this subcampaign
        string name;
        // Hash of the properties of the subcampaign
        bytes32 hash;
        // Unix timestamp indicating when the subcampaign starts
        uint256 startTimestamp;
        // Unix timestamp indicating when the subcampaign ends
        uint256 endTimestamp;
        // Indicates if this subcampaign was initialized by Olyseum owner
        bool initialized;
    }

    mapping(string => SubcampaignInfo) private _subcampaignInfoMap;

    // Reference to the OLY Token
    OlyToken public olyToken;

    // Reference to the Jury
    address public jury;

    // Timestamp marking the withdrawing period day start
    uint256 private _redeemDayBegin;

    // Maximum allowed redeem amount per day
    uint256 public perDayRedeemLimit;

    // Once withdrawAll is called by the jury the contract becames locked
    bool private _locked = false;

    // Total balance in this contract for all campaigns
    uint256 private _totalBalance;

    // Fees accumulated from issued token redeems
    uint256 private _feeBalance;

    // Accumulated redeemed tokens on the day period
    uint256 private _accumulatedRedeemDay = 0;

    /**
     * @dev Constructs a new instance of this contract.
     *
     * @param olyTokenAddress The address of the deployed OLY token.
     * @param juryAddr The address of the jury who can make onlyJury calls
     * @param redeemLimitPerDay The amount of tokens that can be redeemed in one day.
     * This corresponds to the indivisible unit of the token.
     */
    constructor(address olyTokenAddress, address juryAddr, uint256 redeemLimitPerDay) public {
        require(olyTokenAddress != address(0), "OLY Token Address cannot be null");

        olyToken = OlyToken(olyTokenAddress);
        jury = juryAddr;
        perDayRedeemLimit = redeemLimitPerDay;
        _redeemDayBegin = now;
    }

    /**
     * @dev Returns the total balance for all the campaigns (excluding already done redeems).
     */
    function totalBalance() public view returns (uint256) {
        return _totalBalance;
    }

    /**
     * @dev Returns the total fee balance accumulated from issued token redeems.
     */
    function feeBalance() public view returns (uint256) {
        return _feeBalance;
    }

    /**
     * @dev Requires the message sender to be the Jury.
     */
    modifier onlyJury() {
        require(msg.sender == jury, "Expected sender to be the jury.");
        _;
    }

    /**
     * @dev Requires that the contract is not locked.
     */
    modifier isNotLocked() {
        require(!_locked, "Contract has been locked after withdraw-all operation");
        _;
    }

    /**
     * @dev Registers a new campaign.
     *
     * @param uuid The  UUID identifying this campaign.
     * @param name The name of  this campaign.
     * @param budget The budget amount for this campaign, in OLY tokens.
     * @param funder The address of the financer of this campaign.
     */
    function registerCampaign(
        string memory uuid,
        string memory name,
        uint256 budget,
        address funder
    ) public onlyOwner isNotLocked {
        require(funder != address(0), "Funder address cannot be null");
        require(budget != 0, "Budget amount cannot be zero");
        require(
            !_campaignInfoMap[uuid].initialized,
            "A campaign with the specified identifier already exists"
        );

        CampaignInfo storage ci = _campaignInfoMap[uuid];
        ci.uuid = uuid;
        ci.name = name;
        ci.budget = budget;
        ci.funder = funder;
        ci.funding = 0;
        ci.initialized = true;
    }

    /**
     * @dev Registers a subcampaign funding its parent campaign.
     *
     * @param uuid The unique UUID identifying this campaign.
     * @param amount The amount in tokens for funding the subcampaign.
     * Must be less than or equal the campaign's agreed budget.
     * @param hash The hash of the subcampaign
     * @param uuid The uuid of the subcampaign
     * @param name The name of the subcampaign
     * @param startTimestamp The unix timestamp indicating when the subcampaign starts
     * @param endTimestamp The unix timestamp indicating when the subcampaign ends
     */
    function fundCampaign(
        string memory uuid,
        uint256 amount,
        bytes32 hash,
        string memory subcampaignUuid,
        string memory name,
        uint256 startTimestamp,
        uint256 endTimestamp
    ) public isNotLocked {
        require(msg.sender != address(0), "Funder address cannot be null");
        require(
            _campaignInfoMap[uuid].initialized,
            "A campaign with the specified identifier does not exist"
        );
        require(
            _campaignInfoMap[uuid].funder == msg.sender,
            "Only registered funder can call this function"
        );

        uint256 newBalance = amount.add(_campaignInfoMap[uuid].funding);
        require(
            newBalance <= _campaignInfoMap[uuid].budget,
            "Campaign funding cannot exceed the agreed budget amount"
        );

        _registerSubcampaign(hash, subcampaignUuid, name, startTimestamp, endTimestamp);

        _campaignInfoMap[uuid].funding = newBalance;
        _totalBalance = amount.add(_totalBalance);
        require(
            olyToken.transferFrom(msg.sender, address(this), amount),
            "token.transferFrom call must succeed"
        );
    }

    /**
     * @dev Registers a subcampaign.
     *
     * @param hash The hash of the subcampaign
     * @param uuid The uuid of the subcampaign
     * @param name The name of the subcampaign
     * @param startTimestamp The unix timestamp indicating when the subcampaign starts
     * @param endTimestamp The unix timestamp indicating when the subcampaign ends
     */
    function _registerSubcampaign(
        bytes32 hash,
        string memory uuid,
        string memory name,
        uint256 startTimestamp,
        uint256 endTimestamp
    ) private {
        require(bytes(name).length > 0, "Name cannot be an empty string");
        require(bytes(uuid).length > 0, "UUID cannot be an empty string");
        require(startTimestamp != 0 && endTimestamp != 0, "Start/End timestamps cannot be null");
        require(startTimestamp < endTimestamp, "Start timestamp must be less than endTimestamp");
        require(
            !_subcampaignInfoMap[uuid].initialized,
            "A subcampaign with the specified identifier already exists"
        );

        SubcampaignInfo storage sci = _subcampaignInfoMap[uuid];
        sci.uuid = uuid;
        sci.name = name;
        sci.hash = hash;
        sci.startTimestamp = startTimestamp;
        sci.endTimestamp = endTimestamp;
        sci.initialized = true;
    }

    /**
     * @dev Returns the information of the campaign.
     *
     * @param uuid The unique UUID identifying this campaign.
     * @return initialized state of the campaign
     * @return actual funding of the campaign
     * @return name of the campaign
     * @return total budget of the campaign
     * @return funder of the campaign
     */
    function getCampaignInfo(string memory uuid)
        public
        view
        returns (
            bool initialized,
            uint256 funding,
            string memory name,
            uint256 budget,
            address funder
        )
    {
        initialized = _campaignInfoMap[uuid].initialized;
        funding = _campaignInfoMap[uuid].funding;
        name = _campaignInfoMap[uuid].name;
        budget = _campaignInfoMap[uuid].budget;
        funder = _campaignInfoMap[uuid].funder;
    }

    /**
     * @dev Returns the information of the subcampaign.
     *
     * @param uuid The unique UUID identifying this subcampaign.
     * @return initialized state of the subcampaign
     * @return hash of the subcampaign
     * @return name of the subcampaign
     * @return the unix timestamp indicating when the subcampaign starts
     * @return the unix timestamp indicating when the subcampaign ends
     */
    function getSubcampaignInfo(string memory uuid)
        public
        view
        returns (
            bool initialized,
            bytes32 hash,
            string memory name,
            uint256 startTimestamp,
            uint256 endTimestamp
        )
    {
        initialized = _subcampaignInfoMap[uuid].initialized;
        hash = _subcampaignInfoMap[uuid].hash;
        name = _subcampaignInfoMap[uuid].name;
        startTimestamp = _subcampaignInfoMap[uuid].startTimestamp;
        endTimestamp = _subcampaignInfoMap[uuid].endTimestamp;
    }

    /**
     * @dev Redeem user tokens form contract's balance
     *
     * @param amount  The amount in tokens to redeem.
     * @param receiverAddress The address of the receiver.
     * @param fee The fee calculated by the caller to be assigned to the fee pool in this contract.
     */
    function redeem(uint256 amount, address receiverAddress, uint256 fee)
        public
        onlyOwner
        isNotLocked
    {
        require(receiverAddress != owner(), "Receiver address cannot be owner");
        require(receiverAddress != address(0), "Receiver address cannot be zero");
        require(amount != 0, "Amount cannot be zero");

        uint256 assignedTotal = amount.add(fee);
        require(assignedTotal <= _totalBalance, "Amount to redeem cannot exceed total balance");

        uint256 timedelta = now.sub(_redeemDayBegin);
        if (timedelta >= 1 days) {
            uint256 daysdelta = timedelta.div(1 days);
            _redeemDayBegin = _redeemDayBegin.add(daysdelta.mul(1 days));
            _accumulatedRedeemDay = 0;
        }
        require(
            _accumulatedRedeemDay.add(assignedTotal) <= perDayRedeemLimit,
            "Required amount exceeds per-day withdraw limit"
        );

        _totalBalance = _totalBalance.sub(assignedTotal);
        _feeBalance = _feeBalance.add(fee);
        _accumulatedRedeemDay = _accumulatedRedeemDay.add(assignedTotal);
        require(olyToken.transfer(receiverAddress, amount), "Transfer to redeemer failed");
    }

    /**
     * @dev Gets the balance of this contract in OLY.
     *
     * @return The OLY token balance of this contract
     */
    function contractBalance() public view returns (uint256) {
        return olyToken.balanceOf(address(this));
    }

    /**
    * @dev Withdraws all the funds of the contract, sending them to the Jury.
    * Locks the contract
    */
    function withdrawAll() public onlyJury {
        _locked = true;
        require(olyToken.transfer(jury, contractBalance()), "Token transfer failed.");
    }

    /**
     * @dev Transfers an amount of collected fees to Olyseum (owner) wallet.
     *
     * @param amount The amount of collected fees to claim.
     */
    function claimFees(uint256 amount) public onlyOwner isNotLocked {
        require(_feeBalance >= amount, "Amount to claim cannot exceed collected fee balance");

        _feeBalance = _feeBalance.sub(amount);
        require(olyToken.transfer(msg.sender, amount), "Transfer to redeemer failed");
    }

    /**
     * @dev Changes the redeem limit per day.
     *
     * @param newRedeemLimitPerDay The amount of tokens that can be redeemed in one day.
     * This corresponds to the indivisible unit of the token.
     *
     * @return true if succeed
     */
    function changeRedeemLimitPerDay(uint256 newRedeemLimitPerDay) public onlyJury returns (bool) {
        perDayRedeemLimit = newRedeemLimitPerDay;
        return true;
    }

}

contract OlyToken is IERC20 {
    using SafeMath for uint256;

    string private _name;

    string private _symbol;

    uint8 private _decimals;

    bool private _initialized = false;

    mapping(address => uint256) private _balances;

    mapping(address => mapping(address => uint256)) private _allowances;

    uint256 private _totalSupply;

    mapping(address => mapping(uint256 => bool)) private usedNonces;

    event DeferredTransfer(
        address paymentSigner,
        uint256 nonce,
        uint256 paymentAmount,
        address paymentCollector,
        uint256 paymentFee,
        address feeCollector,
        bool statusSuccessful
    );

    /**
    * @dev Initializes the token contract
    *
    * Called by the proxy contract instead of the standard constructor
    *
    * @param name Name of the token
    * @param symbol Symbol of the token
    * @param decimals Decimals of the token
    * @param totalSupply Total supply of tokens
    * @param tokenHolder Who will receive the total supply
    */
    function initialize(
        string memory name,
        string memory symbol,
        uint8 decimals,
        uint256 totalSupply,
        address tokenHolder
    ) public {
        require(!_initialized, "This contract is already initialized");
        require(totalSupply > 0, "Total supply must be greater than 0");

        _name = name;
        _symbol = symbol;
        _decimals = decimals;
        _mint(tokenHolder, totalSupply);
        _initialized = true;
    }

    /**
     * @dev Returns the name of the token.
     */
    function name() public view returns (string memory) {
        return _name;
    }

    /**
     * @dev Returns the symbol of the token, usually a shorter version of the
     * name.
     */
    function symbol() public view returns (string memory) {
        return _symbol;
    }

    /**
     * @dev Returns the number of decimals used to get its user representation.
     * For example, if `decimals` equals `2`, a balance of `505` tokens should
     * be displayed to a user as `5,05` (`505 / 10 ** 2`).
     *
     * Tokens usually opt for a value of 18, imitating the relationship between
     * Ether and Wei.
     *
     * > Note that this information is only used for _display_ purposes: it in
     * no way affects any of the arithmetic of the contract, including
     * `IERC20.balanceOf` and `IERC20.transfer`.
     */
    function decimals() public view returns (uint8) {
        return _decimals;
    }

    /**
     * @dev See `IERC20.totalSupply`.
     */
    function totalSupply() public view returns (uint256) {
        return _totalSupply;
    }

    /**
     * @dev See `IERC20.balanceOf`.
     */
    function balanceOf(address account) public view returns (uint256) {
        return _balances[account];
    }

    /**
     * @dev See `IERC20.transfer`.
     *
     * Requirements:
     *
     * - `recipient` cannot be the zero address.
     * - the caller must have a balance of at least `amount`.
     */
    function transfer(address recipient, uint256 amount) public returns (bool) {
        _transfer(msg.sender, recipient, amount);
        return true;
    }

    /**
     * @dev See `IERC20.allowance`.
     */
    function allowance(address owner, address spender) public view returns (uint256) {
        return _allowances[owner][spender];
    }

    /**
     * @dev See `IERC20.approve`.
     *
     * Requirements:
     *
     * - `spender` cannot be the zero address.
     */
    function approve(address spender, uint256 value) public returns (bool) {
        _approve(msg.sender, spender, value);
        return true;
    }

    /**
     * @dev See `IERC20.transferFrom`.
     *
     * Emits an `Approval` event indicating the updated allowance. This is not
     * required by the EIP. See the note at the beginning of `ERC20`;
     *
     * Requirements:
     * - `sender` and `recipient` cannot be the zero address.
     * - `sender` must have a balance of at least `value`.
     * - the caller must have allowance for `sender`'s tokens of at least
     * `amount`.
     */
    function transferFrom(address sender, address recipient, uint256 amount) public returns (bool) {
        _transfer(sender, recipient, amount);
        _approve(sender, msg.sender, _allowances[sender][msg.sender].sub(amount));
        return true;
    }

    /**
     * @dev Atomically increases the allowance granted to `spender` by the caller.
     *
     * This is an alternative to `approve` that can be used as a mitigation for
     * problems described in `IERC20.approve`.
     *
     * Emits an `Approval` event indicating the updated allowance.
     *
     * Requirements:
     *
     * - `spender` cannot be the zero address.
     */
    function increaseAllowance(address spender, uint256 addedValue) public returns (bool) {
        _approve(msg.sender, spender, _allowances[msg.sender][spender].add(addedValue));
        return true;
    }

    /**
     * @dev Atomically decreases the allowance granted to `spender` by the caller.
     *
     * This is an alternative to `approve` that can be used as a mitigation for
     * problems described in `IERC20.approve`.
     *
     * Emits an `Approval` event indicating the updated allowance.
     *
     * Requirements:
     *
     * - `spender` cannot be the zero address.
     * - `spender` must have allowance for the caller of at least
     * `subtractedValue`.
     */
    function decreaseAllowance(address spender, uint256 subtractedValue) public returns (bool) {
        _approve(msg.sender, spender, _allowances[msg.sender][spender].sub(subtractedValue));
        return true;
    }

    /**
     * @dev Moves tokens `amount` from `sender` to `recipient`.
     *
     * This is internal function is equivalent to `transfer`, and can be used to
     * e.g. implement automatic token fees, slashing mechanisms, etc.
     *
     * Emits a `Transfer` event.
     *
     * Requirements:
     *
     * - `sender` cannot be the zero address.
     * - `recipient` cannot be the zero address.
     * - `sender` must have a balance of at least `amount`.
     */
    function _transfer(address sender, address recipient, uint256 amount) internal {
        require(sender != address(0), "ERC20: transfer from the zero address");
        require(recipient != address(0), "ERC20: transfer to the zero address");

        _balances[sender] = _balances[sender].sub(amount);
        _balances[recipient] = _balances[recipient].add(amount);
        emit Transfer(sender, recipient, amount);
    }

    /** @dev Creates `amount` tokens and assigns them to `account`, increasing
     * the total supply.
     *
     * Emits a `Transfer` event with `from` set to the zero address.
     *
     * Requirements
     *
     * - `to` cannot be the zero address.
     */
    function _mint(address account, uint256 amount) internal {
        require(account != address(0), "ERC20: mint to the zero address");

        _totalSupply = _totalSupply.add(amount);
        _balances[account] = _balances[account].add(amount);
        emit Transfer(address(0), account, amount);
    }

    /**
     * @dev Destoys `amount` tokens from `account`, reducing the
     * total supply.
     *
     * Emits a `Transfer` event with `to` set to the zero address.
     *
     * Requirements
     *
     * - `account` cannot be the zero address.
     * - `account` must have at least `amount` tokens.
     */
    function _burn(address account, uint256 value) internal {
        require(account != address(0), "ERC20: burn from the zero address");

        _totalSupply = _totalSupply.sub(value);
        _balances[account] = _balances[account].sub(value);
        emit Transfer(account, address(0), value);
    }

    /**
     * @dev Sets `amount` as the allowance of `spender` over the `owner`s tokens.
     *
     * This is internal function is equivalent to `approve`, and can be used to
     * e.g. set automatic allowances for certain subsystems, etc.
     *
     * Emits an `Approval` event.
     *
     * Requirements:
     *
     * - `owner` cannot be the zero address.
     * - `spender` cannot be the zero address.
     */
    function _approve(address owner, address spender, uint256 value) internal {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");

        _allowances[owner][spender] = value;
        emit Approval(owner, spender, value);
    }

    /**
     * @dev Destoys `amount` tokens from `account`.`amount` is then deducted
     * from the caller's allowance.
     *
     * See `_burn` and `_approve`.
     */
    function _burnFrom(address account, uint256 amount) internal {
        _burn(account, amount);
        _approve(account, msg.sender, _allowances[account][msg.sender].sub(amount));
    }

    /**
    * @dev Publishes messages signed off the chain by the user wallet.
    *
    * The transfer-message mechanism was designed to provide the wallet user a seamless
    * experience when using tokens to pay or transfer, by letting the Olyseum platform
    * to provide gas fees and executing token transactions on behalf of the user.
    *
    * Nonces are consumed always, even if the execution of a message is unsuccessful.
    * This avoids unintended replays of the message.
    *
    * @param nonces The list of nonces uniquely identifying each message in sequence.
    * @param paymentAmounts The list of payment amounts for each message.
    * @param paymentCollectors The list of payment collectors (destinations) of each message.
    * @param paymentFees The list of fees of each message.
    * @param feeCollectors The list of fee collectors of each message.
    * @param sigsR The list of r-components of the signature for each signed user message.
    * @param sigsS The list of s-components of the signature for each signed user message.
    * @param sigsV The list of v-components of the signature for each signed user message.
    */
    function publishMessages(
        uint256[] memory nonces,
        uint256[] memory paymentAmounts,
        address[] memory paymentCollectors,
        uint256[] memory paymentFees,
        address[] memory feeCollectors,
        bytes32[] memory sigsR,
        bytes32[] memory sigsS,
        uint8[] memory sigsV
    ) public {
        require(
            nonces.length == paymentAmounts.length &&
                paymentAmounts.length == paymentCollectors.length &&
                paymentCollectors.length == paymentFees.length &&
                paymentFees.length == feeCollectors.length &&
                feeCollectors.length == sigsR.length &&
                sigsR.length == sigsS.length &&
                sigsS.length == sigsV.length,
            "Inconsistent message data received"
        );

        for (uint256 i = 0; i < nonces.length; i++) {
            executeMessage(
                nonces[i],
                paymentAmounts[i],
                paymentCollectors[i],
                paymentFees[i],
                feeCollectors[i],
                sigsR[i],
                sigsS[i],
                sigsV[i]
            );
        }
    }

    /**
    * @dev Publishes a message signed off the chain by the user wallet.
    *
    * @param nonce The nonce
    * @param paymentAmount The payment amount
    * @param paymentCollector The payment collector
    * @param paymentFee The payment fee
    * @param feeCollector The fee collector
    * @param sigR The the r-value of the signature
    * @param sigS The the s-value of the signature
    * @param sigV The the v-value of the signature
    */
    function executeMessage(
        uint256 nonce,
        uint256 paymentAmount,
        address paymentCollector,
        uint256 paymentFee,
        address feeCollector,
        bytes32 sigR,
        bytes32 sigS,
        uint8 sigV
    ) private {
        bytes32 hash = keccak256(
            abi.encodePacked(
                string("\x19Ethereum Signed Message:\n164Olyseum v1 Transfer Message:"),
                nonce,
                paymentAmount,
                paymentCollector,
                paymentFee,
                msg.sender
            )
        );

        address user = ecrecover(hash, sigV, sigR, sigS);
        uint256 balance = _balances[user];
        bool success = false;
        uint256 totalExpenditure = paymentAmount.add(paymentFee);

        if (
            balance >= totalExpenditure &&
            !usedNonces[user][nonce] &&
            paymentCollector != address(0) &&
            feeCollector != address(0)
        ) {
            success = true;
            usedNonces[user][nonce] = true;

            // Execute transfer
            _balances[user] = balance.sub(totalExpenditure);
            _balances[paymentCollector] = _balances[paymentCollector].add(paymentAmount);
            _balances[feeCollector] = _balances[feeCollector].add(paymentFee);

            emit Transfer(user, paymentCollector, paymentAmount);
            emit Transfer(user, feeCollector, paymentFee);
        }

        emit DeferredTransfer(
            user,
            nonce,
            paymentAmount,
            paymentCollector,
            paymentFee,
            feeCollector,
            success
        );
    }
}