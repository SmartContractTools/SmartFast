pragma solidity ^0.5.4;

/**
 * @title SafeMath
 * @dev Unsigned math operations with safety checks that revert on error
 */
library SafeMath {
    /**
     * @dev Multiplies two unsigned integers, reverts on overflow.
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
     * @dev Integer division of two unsigned integers truncating the quotient, reverts on division by zero.
     */
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        // Solidity only automatically asserts when dividing by 0
        require(b > 0);
        uint256 c = a / b;
        // assert(a == b * c + a % b); // There is no case in which this doesn't hold

        return c;
    }

    /**
     * @dev Subtracts two unsigned integers, reverts on overflow (i.e. if subtrahend is greater than minuend).
     */
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b <= a);
        uint256 c = a - b;

        return c;
    }

    /**
     * @dev Adds two unsigned integers, reverts on overflow.
     */
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a);

        return c;
    }

    /**
     * @dev Divides two unsigned integers and returns the remainder (unsigned integer modulo),
     * reverts when dividing by zero.
     */
    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b != 0);
        return a % b;
    }
}

/**
 * @title Eternal Storage for the Reserve Token
 *
 * @dev Eternal Storage facilitates future upgrades.
 *
 * If Reserve chooses to release an upgraded contract for the Reserve  in the future, Reserve
 * will have the option of reusing the deployed version of this data contract to simplify migration.
 *
 * The use of this contract does not imply that Reserve will choose to do a future upgrade, nor that
 * any future upgrades will necessarily re-use this storage. It merely provides option value.
 */
contract ReserveEternalStorage {

    using SafeMath for uint256;



    // ===== auth =====

    address public owner;
    address public escapeHatch;

    event OwnershipTransferred(address indexed oldOwner, address indexed newOwner);
    event EscapeHatchTransferred(address indexed oldEscapeHatch, address indexed newEscapeHatch);

    /// On construction, set auth fields.
    constructor(address escapeHatchAddress) public {
        owner = msg.sender;
        escapeHatch = escapeHatchAddress;
    }

    /// Only run modified function if sent by `owner`.
    modifier onlyOwner() {
        require(msg.sender == owner, "onlyOwner");
        _;
    }

    /// Set `owner`.
    function transferOwnership(address newOwner) external {
        require(msg.sender == owner || msg.sender == escapeHatch, "not authorized");
        emit OwnershipTransferred(owner, newOwner);
        owner = newOwner;
    }

    /// Set `escape hatch`.
    function transferEscapeHatch(address newEscapeHatch) external {
        require(msg.sender == escapeHatch, "not authorized");
        emit EscapeHatchTransferred(escapeHatch, newEscapeHatch);
        escapeHatch = newEscapeHatch;
    }



    // ===== balance =====

    mapping(address => uint256) public balance;

    /// Add `value` to `balance[key]`, unless this causes integer overflow.
    ///
    /// @dev This is a slight divergence from the strict Eternal Storage pattern, but it reduces the gas
    /// for the by-far most common token usage, it's a *very simple* divergence, and `setBalance` is
    /// available anyway.
    function addBalance(address key, uint256 value) external onlyOwner {
        balance[key] = balance[key].add(value);
    }

    /// Subtract `value` from `balance[key]`, unless this causes integer underflow.
    function subBalance(address key, uint256 value) external onlyOwner {
        balance[key] = balance[key].sub(value);
    }

    /// Set `balance[key]` to `value`.
    function setBalance(address key, uint256 value) external onlyOwner {
        balance[key] = value;
    }



    // ===== allowed =====

    mapping(address => mapping(address => uint256)) public allowed;

    /// Set `to`'s allowance of `from`'s tokens to `value`.
    function setAllowed(address from, address to, uint256 value) external onlyOwner {
        allowed[from][to] = value;
    }



    // ===== frozenTime =====

    /// @dev When `frozenTime[addr] == 0`, `addr` is not frozen. This is the normal state.
    /// When `frozenTime[addr] == t` and `t > 0`, `addr` was last frozen at timestamp `t`.
    /// So, to unfreeze an address `addr`, set `frozenTime[addr] = 0`.
    mapping(address => uint256) public frozenTime;

    /// Set `frozenTime[who]` to `time`.
    function setFrozenTime(address who, uint256 time) external onlyOwner {
        frozenTime[who] = time;
    }
}