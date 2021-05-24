pragma solidity ^0.4.24;

contract Ownable {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    /**
     * @dev The Ownable constructor sets the original `owner` of the contract to the sender
     * account.
     */
    constructor () internal {
        _owner = msg.sender;
        emit OwnershipTransferred(address(0), _owner);
    }

    /**
     * @return the address of the owner.
     */
    function owner() public view returns (address) {
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
    function isOwner() public view returns (bool) {
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
        require(c / a == b, "Mul failed");

        return c;
    }

    /**
    * @dev Integer division of two numbers truncating the quotient, reverts on division by zero.
    */
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        // Solidity only automatically asserts when dividing by 0
        require(b > 0, "Div failed");
        uint256 c = a / b;
        // assert(a == b * c + a % b); // There is no case in which this doesn't hold

        return c;
    }

    /**
    * @dev Subtracts two numbers, reverts on overflow (i.e. if subtrahend is greater than minuend).
    */
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b <= a, "Sub failed");
        uint256 c = a - b;

        return c;
    }

    /**
    * @dev Adds two numbers, reverts on overflow.
    */
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a, "Add failed");

        return c;
    }

    /**
    * @dev Divides two numbers and returns the remainder (unsigned integer modulo),
    * reverts when dividing by zero.
    */
    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b != 0, "Math failed");
        return a % b;
    }
}
library SafeMath64 {
    /**
    * @dev Multiplies two numbers, reverts on overflow.
    */
    function mul(uint64 a, uint64 b) internal pure returns (uint64) {
        // Gas optimization: this is cheaper than requiring 'a' not being zero, but the
        // benefit is lost if 'b' is also tested.
        // See: https://github.com/OpenZeppelin/openzeppelin-solidity/pull/522
        if (a == 0) {
            return 0;
        }

        uint64 c = a * b;
        require(c / a == b, "Mul failed");

        return c;
    }

    /**
    * @dev Integer division of two numbers truncating the quotient, reverts on division by zero.
    */
    function div(uint64 a, uint64 b) internal pure returns (uint64) {
        // Solidity only automatically asserts when dividing by 0
        require(b > 0, "Div failed");
        uint64 c = a / b;
        // assert(a == b * c + a % b); // There is no case in which this doesn't hold

        return c;
    }

    /**
    * @dev Subtracts two numbers, reverts on overflow (i.e. if subtrahend is greater than minuend).
    */
    function sub(uint64 a, uint64 b) internal pure returns (uint64) {
        require(b <= a, "Sub failed");
        uint64 c = a - b;

        return c;
    }

    /**
    * @dev Adds two numbers, reverts on overflow.
    */
    function add(uint64 a, uint64 b) internal pure returns (uint64) {
        uint64 c = a + b;
        require(c >= a, "Add failed");

        return c;
    }

    /**
    * @dev Divides two numbers and returns the remainder (unsigned integer modulo),
    * reverts when dividing by zero.
    */
    function mod(uint64 a, uint64 b) internal pure returns (uint64) {
        require(b != 0, "mod failed");
        return a % b;
    }
}
interface IERC20 {
    function totalSupply() external view returns (uint256);

    function balanceOf(address who) external view returns (uint256);

    function allowance(address owner, address spender) external view returns (uint256);

    function transfer(address to, uint256 value) external returns (bool);

    function approve(address spender, uint256 value) external returns (bool);

    function transferFrom(address from, address to, uint256 value) external returns (bool);

    event Transfer(address indexed from, address indexed to, uint256 value);

    event Approval(address indexed owner, address indexed spender, uint256 value);
}
library SafeERC20 {
    using SafeMath for uint256;

    function safeTransfer(IERC20 token, address to, uint256 value) internal {
        require(token.transfer(to, value), "Transfer failed");
    }

    function safeTransferFrom(IERC20 token, address from, address to, uint256 value) internal {
        require(token.transferFrom(from, to, value));
    }

    function safeApprove(IERC20 token, address spender, uint256 value) internal {
        // safeApprove should only be called when setting an initial allowance,
        // or when resetting it to zero. To increase and decrease it, use
        // 'safeIncreaseAllowance' and 'safeDecreaseAllowance'
        require((value == 0) || (token.allowance(msg.sender, spender) == 0));
        require(token.approve(spender, value));
    }

    function safeIncreaseAllowance(IERC20 token, address spender, uint256 value) internal {
        uint256 newAllowance = token.allowance(address(this), spender).add(value);
        require(token.approve(spender, newAllowance));
    }

    function safeDecreaseAllowance(IERC20 token, address spender, uint256 value) internal {
        uint256 newAllowance = token.allowance(address(this), spender).sub(value);
        require(token.approve(spender, newAllowance));
    }
}
contract TokenVesting is Ownable {
    using SafeMath for uint256;
    using SafeMath64 for uint64;
    using SafeERC20 for IERC20;

    uint64 constant internal SECONDS_PER_MONTH = 2628000;

    event TokensReleased(uint256 amount);
    event TokenVestingRevoked(uint256 amount);

    // beneficiary of tokens after they are released
    address private _beneficiary;
    // token being vested
    IERC20 private _token;

    uint64 private _cliff;
    uint64 private _start;
    uint64 private _vestingDuration;

    bool private _revocable;
    bool private _revoked;

    uint256 private _released;

    uint64[] private _monthTimestamps;
    uint256 private _tokensPerMonth;
    // struct MonthlyVestAmounts {
    //     uint timestamp;
    //     uint amount;
    // }

    // MonthlyVestAmounts[] private _vestings;

    /**
     * @dev Creates a vesting contract that vests its balance of the ERC20 token declared to the
     * beneficiary, gradually in a linear fashion until start + duration. By then all
     * of the balance will have vested.
     * @param beneficiary address of the beneficiary to whom vested tokens are transferred
     * @param token address of the token of the tokens being vested
     * @param cliffDuration duration in seconds of the cliff in which tokens will begin to vest
     * @param start the time (as Unix time) at which point vesting starts
     * @param vestingDuration duration in seconds of the total period in which the tokens will vest
     * @param revocable whether the vesting is revocable or not
     */
    constructor (address beneficiary, IERC20 token, uint64 start, uint64 cliffDuration, uint64 vestingDuration, bool revocable, uint256 totalTokens) public {
        require(beneficiary != address(0));
        require(token != address(0));
        require(cliffDuration < vestingDuration);
        require(start > 0);
        require(vestingDuration > 0);
        require(start.add(vestingDuration) > block.timestamp);
        _beneficiary = beneficiary;
        _token = token;
        _revocable = revocable;
        _vestingDuration = vestingDuration;
        _cliff = start.add(cliffDuration);
        _start = start;

        uint64 totalReleasingTime = vestingDuration.sub(cliffDuration);
        require(totalReleasingTime.mod(SECONDS_PER_MONTH) == 0);
        uint64 releasingMonths = totalReleasingTime.div(SECONDS_PER_MONTH);
        require(totalTokens.mod(releasingMonths) == 0);
        _tokensPerMonth = totalTokens.div(releasingMonths);
    
        for (uint64 month = 0; month < releasingMonths; month++) {
            uint64 monthTimestamp = uint64(start.add(cliffDuration).add(month.mul(SECONDS_PER_MONTH)).add(SECONDS_PER_MONTH));
            _monthTimestamps.push(monthTimestamp);
        }
    }

    /**
     * @return the beneficiary of the tokens.
     */
    function beneficiary() public view returns (address) {
        return _beneficiary;
    }
    /**
     * @return the address of the token vested.
     */
    function token() public view returns (address) {
        return _token;
    }
    /**
     * @return the cliff time of the token vesting.
     */
    function cliff() public view returns (uint256) {
        return _cliff;
    }
    /**
     * @return the start time of the token vesting.
     */
    function start() public view returns (uint256) {
        return _start;
    }
    /**
     * @return the duration of the token vesting.
     */
    function vestingDuration() public view returns (uint256) {
        return _vestingDuration;
    }
    /**
     * @return the amount of months to vest.
     */
    function monthsToVest() public view returns (uint256) {
        return _monthTimestamps.length;
    }
    /**
     * @return the amount of tokens vested.
     */
    function amountVested() public view returns (uint256) {
        uint256 vested = 0;

        for (uint256 month = 0; month < _monthTimestamps.length; month++) {
            uint256 monthlyVestTimestamp = _monthTimestamps[month];
            if (monthlyVestTimestamp > 0 && block.timestamp >= monthlyVestTimestamp) {
                vested = vested.add(_tokensPerMonth);
            }
        }

        return vested;
    }
    /**
     * @return true if the vesting is revocable.
     */
    function revocable() public view returns (bool) {
        return _revocable;
    }
    /**
     * @return the amount of the token released.
     */
    function released() public view returns (uint256) {
        return _released;
    }
    /**
     * @return true if the token is revoked.
     */
    function revoked() public view returns (bool) {
        return _revoked;
    }

    /**
     * @notice Transfers vested tokens to beneficiary.
     */
    function release() public {
        require(block.timestamp > _cliff, "Cliff hasnt started yet.");
        uint256 amountToSend = 0;

        for (uint256 month = 0; month < _monthTimestamps.length; month++) {
            uint256 monthlyVestTimestamp = _monthTimestamps[month];
            if (monthlyVestTimestamp > 0) {
                if (block.timestamp >= monthlyVestTimestamp) {
                    _monthTimestamps[month] = 0;
                    amountToSend = amountToSend.add(_tokensPerMonth);
                } else {
                    break;
                }
            }
        }

        require(amountToSend > 0, "No tokens to release");

        _released += amountToSend;
        _token.safeTransfer(_beneficiary, amountToSend);
        emit TokensReleased(amountToSend);
    }

    /**
     * @notice Allows the owner to revoke the vesting. Tokens already vested
     * remain in the contract, the rest are returned to the owner.
     */
    function revoke() public onlyOwner {
        require(_revocable, "This vest cannot be revoked");
        require(!_revoked, "This vest has already been revoked");

        _revoked = true;
        uint256 amountToSend = 0;
        for (uint256 month = 0; month < _monthTimestamps.length; month++) {
            uint256 monthlyVestTimestamp = _monthTimestamps[month];
            if (block.timestamp <= monthlyVestTimestamp) {
                _monthTimestamps[month] = 0;
                amountToSend = amountToSend.add(_tokensPerMonth);
            }
        }

        require(amountToSend > 0, "No tokens to revoke");

        _token.safeTransfer(owner(), amountToSend);
        emit TokenVestingRevoked(amountToSend);
    }
}