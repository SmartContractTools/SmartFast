// File: @openzeppelin/contracts/GSN/Context.sol

pragma solidity ^0.5.0;

/*
 * @dev Provides information about the current execution context, including the
 * sender of the transaction and its data. While these are generally available
 * via msg.sender and msg.data, they should not be accessed in such a direct
 * manner, since when dealing with GSN meta-transactions the account sending and
 * paying for execution may not be the actual sender (as far as an application
 * is concerned).
 *
 * This contract is only required for intermediate, library-like contracts.
 */
contract Context {
    // Empty internal constructor, to prevent people from mistakenly deploying
    // an instance of this contract, which should be used via inheritance.
    constructor () internal { }
    // solhint-disable-previous-line no-empty-blocks

    function _msgSender() internal view returns (address payable) {
        return msg.sender;
    }

    function _msgData() internal view returns (bytes memory) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}

// File: @openzeppelin/contracts/token/ERC20/IERC20.sol

pragma solidity ^0.5.0;

/**
 * @dev Interface of the ERC20 standard as defined in the EIP. Does not include
 * the optional functions; to access them see {ERC20Detailed}.
 */
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
     * Emits a {Transfer} event.
     */
    function transfer(address recipient, uint256 amount) external returns (bool);

    /**
     * @dev Returns the remaining number of tokens that `spender` will be
     * allowed to spend on behalf of `owner` through {transferFrom}. This is
     * zero by default.
     *
     * This value changes when {approve} or {transferFrom} are called.
     */
    function allowance(address owner, address spender) external view returns (uint256);

    /**
     * @dev Sets `amount` as the allowance of `spender` over the caller's tokens.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * IMPORTANT: Beware that changing an allowance with this method brings the risk
     * that someone may use both the old and the new allowance by unfortunate
     * transaction ordering. One possible solution to mitigate this race
     * condition is to first reduce the spender's allowance to 0 and set the
     * desired value afterwards:
     * https://github.com/ethereum/EIPs/issues/20#issuecomment-263524729
     *
     * Emits an {Approval} event.
     */
    function approve(address spender, uint256 amount) external returns (bool);

    /**
     * @dev Moves `amount` tokens from `sender` to `recipient` using the
     * allowance mechanism. `amount` is then deducted from the caller's
     * allowance.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
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
     * a call to {approve}. `value` is the new allowance.
     */
    event Approval(address indexed owner, address indexed spender, uint256 value);
}

// File: @openzeppelin/contracts/math/SafeMath.sol

pragma solidity ^0.5.0;

/**
 * @dev Wrappers over Solidity's arithmetic operations with added overflow
 * checks.
 *
 * Arithmetic operations in Solidity wrap on overflow. This can easily result
 * in bugs, because programmers usually assume that an overflow raises an
 * error, which is the standard behavior in high level programming languages.
 * `SafeMath` restores this intuition by reverting the transaction when an
 * operation overflows.
 *
 * Using this library instead of the unchecked operations eliminates an entire
 * class of bugs, so it's recommended to use it always.
 */
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
        return sub(a, b, "SafeMath: subtraction overflow");
    }

    /**
     * @dev Returns the subtraction of two unsigned integers, reverting with custom message on
     * overflow (when the result is negative).
     *
     * Counterpart to Solidity's `-` operator.
     *
     * Requirements:
     * - Subtraction cannot overflow.
     *
     * _Available since v2.4.0._
     */
    function sub(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b <= a, errorMessage);
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
        return div(a, b, "SafeMath: division by zero");
    }

    /**
     * @dev Returns the integer division of two unsigned integers. Reverts with custom message on
     * division by zero. The result is rounded towards zero.
     *
     * Counterpart to Solidity's `/` operator. Note: this function uses a
     * `revert` opcode (which leaves remaining gas untouched) while Solidity
     * uses an invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     * - The divisor cannot be zero.
     *
     * _Available since v2.4.0._
     */
    function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        // Solidity only automatically asserts when dividing by 0
        require(b > 0, errorMessage);
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
        return mod(a, b, "SafeMath: modulo by zero");
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers. (unsigned integer modulo),
     * Reverts with custom message when dividing by zero.
     *
     * Counterpart to Solidity's `%` operator. This function uses a `revert`
     * opcode (which leaves remaining gas untouched) while Solidity uses an
     * invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     * - The divisor cannot be zero.
     *
     * _Available since v2.4.0._
     */
    function mod(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b != 0, errorMessage);
        return a % b;
    }
}

// File: @openzeppelin/contracts/token/ERC20/ERC20.sol

pragma solidity ^0.5.0;




/**
 * @dev Implementation of the {IERC20} interface.
 *
 * This implementation is agnostic to the way tokens are created. This means
 * that a supply mechanism has to be added in a derived contract using {_mint}.
 * For a generic mechanism see {ERC20Mintable}.
 *
 * TIP: For a detailed writeup see our guide
 * https://forum.zeppelin.solutions/t/how-to-implement-erc20-supply-mechanisms/226[How
 * to implement supply mechanisms].
 *
 * We have followed general OpenZeppelin guidelines: functions revert instead
 * of returning `false` on failure. This behavior is nonetheless conventional
 * and does not conflict with the expectations of ERC20 applications.
 *
 * Additionally, an {Approval} event is emitted on calls to {transferFrom}.
 * This allows applications to reconstruct the allowance for all accounts just
 * by listening to said events. Other implementations of the EIP may not emit
 * these events, as it isn't required by the specification.
 *
 * Finally, the non-standard {decreaseAllowance} and {increaseAllowance}
 * functions have been added to mitigate the well-known issues around setting
 * allowances. See {IERC20-approve}.
 */
contract ERC20 is Context, IERC20 {
    using SafeMath for uint256;

    mapping (address => uint256) private _balances;

    mapping (address => mapping (address => uint256)) private _allowances;

    uint256 private _totalSupply;

    /**
     * @dev See {IERC20-totalSupply}.
     */
    function totalSupply() public view returns (uint256) {
        return _totalSupply;
    }

    /**
     * @dev See {IERC20-balanceOf}.
     */
    function balanceOf(address account) public view returns (uint256) {
        return _balances[account];
    }

    /**
     * @dev See {IERC20-transfer}.
     *
     * Requirements:
     *
     * - `recipient` cannot be the zero address.
     * - the caller must have a balance of at least `amount`.
     */
    function transfer(address recipient, uint256 amount) public returns (bool) {
        _transfer(_msgSender(), recipient, amount);
        return true;
    }

    /**
     * @dev See {IERC20-allowance}.
     */
    function allowance(address owner, address spender) public view returns (uint256) {
        return _allowances[owner][spender];
    }

    /**
     * @dev See {IERC20-approve}.
     *
     * Requirements:
     *
     * - `spender` cannot be the zero address.
     */
    function approve(address spender, uint256 amount) public returns (bool) {
        _approve(_msgSender(), spender, amount);
        return true;
    }

    /**
     * @dev See {IERC20-transferFrom}.
     *
     * Emits an {Approval} event indicating the updated allowance. This is not
     * required by the EIP. See the note at the beginning of {ERC20};
     *
     * Requirements:
     * - `sender` and `recipient` cannot be the zero address.
     * - `sender` must have a balance of at least `amount`.
     * - the caller must have allowance for `sender`'s tokens of at least
     * `amount`.
     */
    function transferFrom(address sender, address recipient, uint256 amount) public returns (bool) {
        _transfer(sender, recipient, amount);
        _approve(sender, _msgSender(), _allowances[sender][_msgSender()].sub(amount, "ERC20: transfer amount exceeds allowance"));
        return true;
    }

    /**
     * @dev Atomically increases the allowance granted to `spender` by the caller.
     *
     * This is an alternative to {approve} that can be used as a mitigation for
     * problems described in {IERC20-approve}.
     *
     * Emits an {Approval} event indicating the updated allowance.
     *
     * Requirements:
     *
     * - `spender` cannot be the zero address.
     */
    function increaseAllowance(address spender, uint256 addedValue) public returns (bool) {
        _approve(_msgSender(), spender, _allowances[_msgSender()][spender].add(addedValue));
        return true;
    }

    /**
     * @dev Atomically decreases the allowance granted to `spender` by the caller.
     *
     * This is an alternative to {approve} that can be used as a mitigation for
     * problems described in {IERC20-approve}.
     *
     * Emits an {Approval} event indicating the updated allowance.
     *
     * Requirements:
     *
     * - `spender` cannot be the zero address.
     * - `spender` must have allowance for the caller of at least
     * `subtractedValue`.
     */
    function decreaseAllowance(address spender, uint256 subtractedValue) public returns (bool) {
        _approve(_msgSender(), spender, _allowances[_msgSender()][spender].sub(subtractedValue, "ERC20: decreased allowance below zero"));
        return true;
    }

    /**
     * @dev Moves tokens `amount` from `sender` to `recipient`.
     *
     * This is internal function is equivalent to {transfer}, and can be used to
     * e.g. implement automatic token fees, slashing mechanisms, etc.
     *
     * Emits a {Transfer} event.
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

        _balances[sender] = _balances[sender].sub(amount, "ERC20: transfer amount exceeds balance");
        _balances[recipient] = _balances[recipient].add(amount);
        emit Transfer(sender, recipient, amount);
    }

    /** @dev Creates `amount` tokens and assigns them to `account`, increasing
     * the total supply.
     *
     * Emits a {Transfer} event with `from` set to the zero address.
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
     * @dev Destroys `amount` tokens from `account`, reducing the
     * total supply.
     *
     * Emits a {Transfer} event with `to` set to the zero address.
     *
     * Requirements
     *
     * - `account` cannot be the zero address.
     * - `account` must have at least `amount` tokens.
     */
    function _burn(address account, uint256 amount) internal {
        require(account != address(0), "ERC20: burn from the zero address");

        _balances[account] = _balances[account].sub(amount, "ERC20: burn amount exceeds balance");
        _totalSupply = _totalSupply.sub(amount);
        emit Transfer(account, address(0), amount);
    }

    /**
     * @dev Sets `amount` as the allowance of `spender` over the `owner`s tokens.
     *
     * This is internal function is equivalent to `approve`, and can be used to
     * e.g. set automatic allowances for certain subsystems, etc.
     *
     * Emits an {Approval} event.
     *
     * Requirements:
     *
     * - `owner` cannot be the zero address.
     * - `spender` cannot be the zero address.
     */
    function _approve(address owner, address spender, uint256 amount) internal {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    /**
     * @dev Destroys `amount` tokens from `account`.`amount` is then deducted
     * from the caller's allowance.
     *
     * See {_burn} and {_approve}.
     */
    function _burnFrom(address account, uint256 amount) internal {
        _burn(account, amount);
        _approve(account, _msgSender(), _allowances[account][_msgSender()].sub(amount, "ERC20: burn amount exceeds allowance"));
    }
}

// File: @openzeppelin/contracts/access/Roles.sol

pragma solidity ^0.5.0;

/**
 * @title Roles
 * @dev Library for managing addresses assigned to a Role.
 */
library Roles {
    struct Role {
        mapping (address => bool) bearer;
    }

    /**
     * @dev Give an account access to this role.
     */
    function add(Role storage role, address account) internal {
        require(!has(role, account), "Roles: account already has role");
        role.bearer[account] = true;
    }

    /**
     * @dev Remove an account's access to this role.
     */
    function remove(Role storage role, address account) internal {
        require(has(role, account), "Roles: account does not have role");
        role.bearer[account] = false;
    }

    /**
     * @dev Check if an account has this role.
     * @return bool
     */
    function has(Role storage role, address account) internal view returns (bool) {
        require(account != address(0), "Roles: account is the zero address");
        return role.bearer[account];
    }
}

// File: @openzeppelin/contracts/access/roles/MinterRole.sol

pragma solidity ^0.5.0;



contract MinterRole is Context {
    using Roles for Roles.Role;

    event MinterAdded(address indexed account);
    event MinterRemoved(address indexed account);

    Roles.Role private _minters;

    constructor () internal {
        _addMinter(_msgSender());
    }

    modifier onlyMinter() {
        require(isMinter(_msgSender()), "MinterRole: caller does not have the Minter role");
        _;
    }

    function isMinter(address account) public view returns (bool) {
        return _minters.has(account);
    }

    function addMinter(address account) public onlyMinter {
        _addMinter(account);
    }

    function renounceMinter() public {
        _removeMinter(_msgSender());
    }

    function _addMinter(address account) internal {
        _minters.add(account);
        emit MinterAdded(account);
    }

    function _removeMinter(address account) internal {
        _minters.remove(account);
        emit MinterRemoved(account);
    }
}

// File: @openzeppelin/contracts/token/ERC20/ERC20Mintable.sol

pragma solidity ^0.5.0;



/**
 * @dev Extension of {ERC20} that adds a set of accounts with the {MinterRole},
 * which have permission to mint (create) new tokens as they see fit.
 *
 * At construction, the deployer of the contract is the only minter.
 */
contract ERC20Mintable is ERC20, MinterRole {
    /**
     * @dev See {ERC20-_mint}.
     *
     * Requirements:
     *
     * - the caller must have the {MinterRole}.
     */
    function mint(address account, uint256 amount) public onlyMinter returns (bool) {
        _mint(account, amount);
        return true;
    }
}

// File: @openzeppelin/contracts/token/ERC20/ERC20Capped.sol

pragma solidity ^0.5.0;


/**
 * @dev Extension of {ERC20Mintable} that adds a cap to the supply of tokens.
 */
contract ERC20Capped is ERC20Mintable {
    uint256 private _cap;

    /**
     * @dev Sets the value of the `cap`. This value is immutable, it can only be
     * set once during construction.
     */
    constructor (uint256 cap) public {
        require(cap > 0, "ERC20Capped: cap is 0");
        _cap = cap;
    }

    /**
     * @dev Returns the cap on the token's total supply.
     */
    function cap() public view returns (uint256) {
        return _cap;
    }

    /**
     * @dev See {ERC20Mintable-mint}.
     *
     * Requirements:
     *
     * - `value` must not cause the total supply to go over the cap.
     */
    function _mint(address account, uint256 value) internal {
        require(totalSupply().add(value) <= _cap, "ERC20Capped: cap exceeded");
        super._mint(account, value);
    }
}

// File: @openzeppelin/contracts/introspection/IERC165.sol

pragma solidity ^0.5.0;

/**
 * @dev Interface of the ERC165 standard, as defined in the
 * https://eips.ethereum.org/EIPS/eip-165[EIP].
 *
 * Implementers can declare support of contract interfaces, which can then be
 * queried by others ({ERC165Checker}).
 *
 * For an implementation, see {ERC165}.
 */
interface IERC165 {
    /**
     * @dev Returns true if this contract implements the interface defined by
     * `interfaceId`. See the corresponding
     * https://eips.ethereum.org/EIPS/eip-165#how-interfaces-are-identified[EIP section]
     * to learn more about how these ids are created.
     *
     * This function call must use less than 30 000 gas.
     */
    function supportsInterface(bytes4 interfaceId) external view returns (bool);
}

// File: @openzeppelin/contracts/token/ERC721/IERC721.sol

pragma solidity ^0.5.0;


/**
 * @dev Required interface of an ERC721 compliant contract.
 */
contract IERC721 is IERC165 {
    event Transfer(address indexed from, address indexed to, uint256 indexed tokenId);
    event Approval(address indexed owner, address indexed approved, uint256 indexed tokenId);
    event ApprovalForAll(address indexed owner, address indexed operator, bool approved);

    /**
     * @dev Returns the number of NFTs in `owner`'s account.
     */
    function balanceOf(address owner) public view returns (uint256 balance);

    /**
     * @dev Returns the owner of the NFT specified by `tokenId`.
     */
    function ownerOf(uint256 tokenId) public view returns (address owner);

    /**
     * @dev Transfers a specific NFT (`tokenId`) from one account (`from`) to
     * another (`to`).
     *
     *
     *
     * Requirements:
     * - `from`, `to` cannot be zero.
     * - `tokenId` must be owned by `from`.
     * - If the caller is not `from`, it must be have been allowed to move this
     * NFT by either {approve} or {setApprovalForAll}.
     */
    function safeTransferFrom(address from, address to, uint256 tokenId) public;
    /**
     * @dev Transfers a specific NFT (`tokenId`) from one account (`from`) to
     * another (`to`).
     *
     * Requirements:
     * - If the caller is not `from`, it must be approved to move this NFT by
     * either {approve} or {setApprovalForAll}.
     */
    function transferFrom(address from, address to, uint256 tokenId) public;
    function approve(address to, uint256 tokenId) public;
    function getApproved(uint256 tokenId) public view returns (address operator);

    function setApprovalForAll(address operator, bool _approved) public;
    function isApprovedForAll(address owner, address operator) public view returns (bool);


    function safeTransferFrom(address from, address to, uint256 tokenId, bytes memory data) public;
}

// File: @openzeppelin/contracts/access/roles/PauserRole.sol

pragma solidity ^0.5.0;



contract PauserRole is Context {
    using Roles for Roles.Role;

    event PauserAdded(address indexed account);
    event PauserRemoved(address indexed account);

    Roles.Role private _pausers;

    constructor () internal {
        _addPauser(_msgSender());
    }

    modifier onlyPauser() {
        require(isPauser(_msgSender()), "PauserRole: caller does not have the Pauser role");
        _;
    }

    function isPauser(address account) public view returns (bool) {
        return _pausers.has(account);
    }

    function addPauser(address account) public onlyPauser {
        _addPauser(account);
    }

    function renouncePauser() public {
        _removePauser(_msgSender());
    }

    function _addPauser(address account) internal {
        _pausers.add(account);
        emit PauserAdded(account);
    }

    function _removePauser(address account) internal {
        _pausers.remove(account);
        emit PauserRemoved(account);
    }
}

// File: @openzeppelin/contracts/lifecycle/Pausable.sol

pragma solidity ^0.5.0;



/**
 * @dev Contract module which allows children to implement an emergency stop
 * mechanism that can be triggered by an authorized account.
 *
 * This module is used through inheritance. It will make available the
 * modifiers `whenNotPaused` and `whenPaused`, which can be applied to
 * the functions of your contract. Note that they will not be pausable by
 * simply including this module, only once the modifiers are put in place.
 */
contract Pausable is Context, PauserRole {
    /**
     * @dev Emitted when the pause is triggered by a pauser (`account`).
     */
    event Paused(address account);

    /**
     * @dev Emitted when the pause is lifted by a pauser (`account`).
     */
    event Unpaused(address account);

    bool private _paused;

    /**
     * @dev Initializes the contract in unpaused state. Assigns the Pauser role
     * to the deployer.
     */
    constructor () internal {
        _paused = false;
    }

    /**
     * @dev Returns true if the contract is paused, and false otherwise.
     */
    function paused() public view returns (bool) {
        return _paused;
    }

    /**
     * @dev Modifier to make a function callable only when the contract is not paused.
     */
    modifier whenNotPaused() {
        require(!_paused, "Pausable: paused");
        _;
    }

    /**
     * @dev Modifier to make a function callable only when the contract is paused.
     */
    modifier whenPaused() {
        require(_paused, "Pausable: not paused");
        _;
    }

    /**
     * @dev Called by a pauser to pause, triggers stopped state.
     */
    function pause() public onlyPauser whenNotPaused {
        _paused = true;
        emit Paused(_msgSender());
    }

    /**
     * @dev Called by a pauser to unpause, returns to normal state.
     */
    function unpause() public onlyPauser whenPaused {
        _paused = false;
        emit Unpaused(_msgSender());
    }
}

// File: @openzeppelin/contracts/math/Math.sol

pragma solidity ^0.5.0;

/**
 * @dev Standard math utilities missing in the Solidity language.
 */
library Math {
    /**
     * @dev Returns the largest of two numbers.
     */
    function max(uint256 a, uint256 b) internal pure returns (uint256) {
        return a >= b ? a : b;
    }

    /**
     * @dev Returns the smallest of two numbers.
     */
    function min(uint256 a, uint256 b) internal pure returns (uint256) {
        return a < b ? a : b;
    }

    /**
     * @dev Returns the average of two numbers. The result is rounded towards
     * zero.
     */
    function average(uint256 a, uint256 b) internal pure returns (uint256) {
        // (a + b) / 2 can overflow, so we distribute
        return (a / 2) + (b / 2) + ((a % 2 + b % 2) / 2);
    }
}

// File: @openzeppelin/contracts/ownership/Ownable.sol

pragma solidity ^0.5.0;

/**
 * @dev Contract module which provides a basic access control mechanism, where
 * there is an account (an owner) that can be granted exclusive access to
 * specific functions.
 *
 * This module is used through inheritance. It will make available the modifier
 * `onlyOwner`, which can be applied to your functions to restrict their use to
 * the owner.
 */
contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    /**
     * @dev Initializes the contract setting the deployer as the initial owner.
     */
    constructor () internal {
        address msgSender = _msgSender();
        _owner = msgSender;
        emit OwnershipTransferred(address(0), msgSender);
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
        return _msgSender() == _owner;
    }

    /**
     * @dev Leaves the contract without owner. It will not be possible to call
     * `onlyOwner` functions anymore. Can only be called by the current owner.
     *
     * NOTE: Renouncing ownership will leave the contract without an owner,
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

// File: contracts/purchase/ReferrableSale.sol

pragma solidity ^0.5.2;


/**
 * @title ReferrableSale
 * @dev Implements the base elements for a sales referral system.
 * It is supposed to be inherited by a sales contract.
 * The referrals are expressed in percentage * 100, for example 1000 represents 10% and 555 represents 5.55%.
 */
contract ReferrableSale is Ownable {

    event DefaultReferralSet(
        uint256 percentage
    );

    event CustomReferralSet(
        address indexed referrer,
        uint256 percentage
    );

    uint256 public _defaultReferralPercentage;
    mapping (address => uint256) public _customReferralPercentages;

    function setDefaultReferral(uint256 defaultReferralPercentage) public onlyOwner {
        require(defaultReferralPercentage < 10000, "Referral must be less than 100 percent");
        require(defaultReferralPercentage != _defaultReferralPercentage, "New referral must be different from the previous");
        _defaultReferralPercentage = defaultReferralPercentage;
        emit DefaultReferralSet(defaultReferralPercentage);
    }

    function setCustomReferral(address _referrer, uint256 customReferralPercentage) public onlyOwner {
        require(customReferralPercentage < 10000, "Referral must be less than 100 percent");
        require(customReferralPercentage != _customReferralPercentages[_referrer], "New referral must be different from the previous");
        _customReferralPercentages[_referrer] = customReferralPercentage;
        emit CustomReferralSet(_referrer, customReferralPercentage);
    }
}

// File: @openzeppelin/contracts/token/ERC20/ERC20Detailed.sol

pragma solidity ^0.5.0;


/**
 * @dev Optional functions from the ERC20 standard.
 */
contract ERC20Detailed is IERC20 {
    string private _name;
    string private _symbol;
    uint8 private _decimals;

    /**
     * @dev Sets the values for `name`, `symbol`, and `decimals`. All three of
     * these values are immutable: they can only be set once during
     * construction.
     */
    constructor (string memory name, string memory symbol, uint8 decimals) public {
        _name = name;
        _symbol = symbol;
        _decimals = decimals;
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
     * NOTE: This information is only used for _display_ purposes: it in
     * no way affects any of the arithmetic of the contract, including
     * {IERC20-balanceOf} and {IERC20-transfer}.
     */
    function decimals() public view returns (uint8) {
        return _decimals;
    }
}

// File: @openzeppelin/contracts/GSN/IRelayRecipient.sol

pragma solidity ^0.5.0;

/**
 * @dev Base interface for a contract that will be called via the GSN from {IRelayHub}.
 *
 * TIP: You don't need to write an implementation yourself! Inherit from {GSNRecipient} instead.
 */
interface IRelayRecipient {
    /**
     * @dev Returns the address of the {IRelayHub} instance this recipient interacts with.
     */
    function getHubAddr() external view returns (address);

    /**
     * @dev Called by {IRelayHub} to validate if this recipient accepts being charged for a relayed call. Note that the
     * recipient will be charged regardless of the execution result of the relayed call (i.e. if it reverts or not).
     *
     * The relay request was originated by `from` and will be served by `relay`. `encodedFunction` is the relayed call
     * calldata, so its first four bytes are the function selector. The relayed call will be forwarded `gasLimit` gas,
     * and the transaction executed with a gas price of at least `gasPrice`. `relay`'s fee is `transactionFee`, and the
     * recipient will be charged at most `maxPossibleCharge` (in wei). `nonce` is the sender's (`from`) nonce for
     * replay attack protection in {IRelayHub}, and `approvalData` is a optional parameter that can be used to hold a signature
     * over all or some of the previous values.
     *
     * Returns a tuple, where the first value is used to indicate approval (0) or rejection (custom non-zero error code,
     * values 1 to 10 are reserved) and the second one is data to be passed to the other {IRelayRecipient} functions.
     *
     * {acceptRelayedCall} is called with 50k gas: if it runs out during execution, the request will be considered
     * rejected. A regular revert will also trigger a rejection.
     */
    function acceptRelayedCall(
        address relay,
        address from,
        bytes calldata encodedFunction,
        uint256 transactionFee,
        uint256 gasPrice,
        uint256 gasLimit,
        uint256 nonce,
        bytes calldata approvalData,
        uint256 maxPossibleCharge
    )
        external
        view
        returns (uint256, bytes memory);

    /**
     * @dev Called by {IRelayHub} on approved relay call requests, before the relayed call is executed. This allows to e.g.
     * pre-charge the sender of the transaction.
     *
     * `context` is the second value returned in the tuple by {acceptRelayedCall}.
     *
     * Returns a value to be passed to {postRelayedCall}.
     *
     * {preRelayedCall} is called with 100k gas: if it runs out during exection or otherwise reverts, the relayed call
     * will not be executed, but the recipient will still be charged for the transaction's cost.
     */
    function preRelayedCall(bytes calldata context) external returns (bytes32);

    /**
     * @dev Called by {IRelayHub} on approved relay call requests, after the relayed call is executed. This allows to e.g.
     * charge the user for the relayed call costs, return any overcharges from {preRelayedCall}, or perform
     * contract-specific bookkeeping.
     *
     * `context` is the second value returned in the tuple by {acceptRelayedCall}. `success` is the execution status of
     * the relayed call. `actualCharge` is an estimate of how much the recipient will be charged for the transaction,
     * not including any gas used by {postRelayedCall} itself. `preRetVal` is {preRelayedCall}'s return value.
     *
     *
     * {postRelayedCall} is called with 100k gas: if it runs out during execution or otherwise reverts, the relayed call
     * and the call to {preRelayedCall} will be reverted retroactively, but the recipient will still be charged for the
     * transaction's cost.
     */
    function postRelayedCall(bytes calldata context, bool success, uint256 actualCharge, bytes32 preRetVal) external;
}

// File: @openzeppelin/contracts/GSN/IRelayHub.sol

pragma solidity ^0.5.0;

/**
 * @dev Interface for `RelayHub`, the core contract of the GSN. Users should not need to interact with this contract
 * directly.
 *
 * See the https://github.com/OpenZeppelin/openzeppelin-gsn-helpers[OpenZeppelin GSN helpers] for more information on
 * how to deploy an instance of `RelayHub` on your local test network.
 */
interface IRelayHub {
    // Relay management

    /**
     * @dev Adds stake to a relay and sets its `unstakeDelay`. If the relay does not exist, it is created, and the caller
     * of this function becomes its owner. If the relay already exists, only the owner can call this function. A relay
     * cannot be its own owner.
     *
     * All Ether in this function call will be added to the relay's stake.
     * Its unstake delay will be assigned to `unstakeDelay`, but the new value must be greater or equal to the current one.
     *
     * Emits a {Staked} event.
     */
    function stake(address relayaddr, uint256 unstakeDelay) external payable;

    /**
     * @dev Emitted when a relay's stake or unstakeDelay are increased
     */
    event Staked(address indexed relay, uint256 stake, uint256 unstakeDelay);

    /**
     * @dev Registers the caller as a relay.
     * The relay must be staked for, and not be a contract (i.e. this function must be called directly from an EOA).
     *
     * This function can be called multiple times, emitting new {RelayAdded} events. Note that the received
     * `transactionFee` is not enforced by {relayCall}.
     *
     * Emits a {RelayAdded} event.
     */
    function registerRelay(uint256 transactionFee, string calldata url) external;

    /**
     * @dev Emitted when a relay is registered or re-registerd. Looking at these events (and filtering out
     * {RelayRemoved} events) lets a client discover the list of available relays.
     */
    event RelayAdded(address indexed relay, address indexed owner, uint256 transactionFee, uint256 stake, uint256 unstakeDelay, string url);

    /**
     * @dev Removes (deregisters) a relay. Unregistered (but staked for) relays can also be removed.
     *
     * Can only be called by the owner of the relay. After the relay's `unstakeDelay` has elapsed, {unstake} will be
     * callable.
     *
     * Emits a {RelayRemoved} event.
     */
    function removeRelayByOwner(address relay) external;

    /**
     * @dev Emitted when a relay is removed (deregistered). `unstakeTime` is the time when unstake will be callable.
     */
    event RelayRemoved(address indexed relay, uint256 unstakeTime);

    /** Deletes the relay from the system, and gives back its stake to the owner.
     *
     * Can only be called by the relay owner, after `unstakeDelay` has elapsed since {removeRelayByOwner} was called.
     *
     * Emits an {Unstaked} event.
     */
    function unstake(address relay) external;

    /**
     * @dev Emitted when a relay is unstaked for, including the returned stake.
     */
    event Unstaked(address indexed relay, uint256 stake);

    // States a relay can be in
    enum RelayState {
        Unknown, // The relay is unknown to the system: it has never been staked for
        Staked, // The relay has been staked for, but it is not yet active
        Registered, // The relay has registered itself, and is active (can relay calls)
        Removed    // The relay has been removed by its owner and can no longer relay calls. It must wait for its unstakeDelay to elapse before it can unstake
    }

    /**
     * @dev Returns a relay's status. Note that relays can be deleted when unstaked or penalized, causing this function
     * to return an empty entry.
     */
    function getRelay(address relay) external view returns (uint256 totalStake, uint256 unstakeDelay, uint256 unstakeTime, address payable owner, RelayState state);

    // Balance management

    /**
     * @dev Deposits Ether for a contract, so that it can receive (and pay for) relayed transactions.
     *
     * Unused balance can only be withdrawn by the contract itself, by calling {withdraw}.
     *
     * Emits a {Deposited} event.
     */
    function depositFor(address target) external payable;

    /**
     * @dev Emitted when {depositFor} is called, including the amount and account that was funded.
     */
    event Deposited(address indexed recipient, address indexed from, uint256 amount);

    /**
     * @dev Returns an account's deposits. These can be either a contracts's funds, or a relay owner's revenue.
     */
    function balanceOf(address target) external view returns (uint256);

    /**
     * Withdraws from an account's balance, sending it back to it. Relay owners call this to retrieve their revenue, and
     * contracts can use it to reduce their funding.
     *
     * Emits a {Withdrawn} event.
     */
    function withdraw(uint256 amount, address payable dest) external;

    /**
     * @dev Emitted when an account withdraws funds from `RelayHub`.
     */
    event Withdrawn(address indexed account, address indexed dest, uint256 amount);

    // Relaying

    /**
     * @dev Checks if the `RelayHub` will accept a relayed operation.
     * Multiple things must be true for this to happen:
     *  - all arguments must be signed for by the sender (`from`)
     *  - the sender's nonce must be the current one
     *  - the recipient must accept this transaction (via {acceptRelayedCall})
     *
     * Returns a `PreconditionCheck` value (`OK` when the transaction can be relayed), or a recipient-specific error
     * code if it returns one in {acceptRelayedCall}.
     */
    function canRelay(
        address relay,
        address from,
        address to,
        bytes calldata encodedFunction,
        uint256 transactionFee,
        uint256 gasPrice,
        uint256 gasLimit,
        uint256 nonce,
        bytes calldata signature,
        bytes calldata approvalData
    ) external view returns (uint256 status, bytes memory recipientContext);

    // Preconditions for relaying, checked by canRelay and returned as the corresponding numeric values.
    enum PreconditionCheck {
        OK,                         // All checks passed, the call can be relayed
        WrongSignature,             // The transaction to relay is not signed by requested sender
        WrongNonce,                 // The provided nonce has already been used by the sender
        AcceptRelayedCallReverted,  // The recipient rejected this call via acceptRelayedCall
        InvalidRecipientStatusCode  // The recipient returned an invalid (reserved) status code
    }

    /**
     * @dev Relays a transaction.
     *
     * For this to succeed, multiple conditions must be met:
     *  - {canRelay} must `return PreconditionCheck.OK`
     *  - the sender must be a registered relay
     *  - the transaction's gas price must be larger or equal to the one that was requested by the sender
     *  - the transaction must have enough gas to not run out of gas if all internal transactions (calls to the
     * recipient) use all gas available to them
     *  - the recipient must have enough balance to pay the relay for the worst-case scenario (i.e. when all gas is
     * spent)
     *
     * If all conditions are met, the call will be relayed and the recipient charged. {preRelayedCall}, the encoded
     * function and {postRelayedCall} will be called in that order.
     *
     * Parameters:
     *  - `from`: the client originating the request
     *  - `to`: the target {IRelayRecipient} contract
     *  - `encodedFunction`: the function call to relay, including data
     *  - `transactionFee`: fee (%) the relay takes over actual gas cost
     *  - `gasPrice`: gas price the client is willing to pay
     *  - `gasLimit`: gas to forward when calling the encoded function
     *  - `nonce`: client's nonce
     *  - `signature`: client's signature over all previous params, plus the relay and RelayHub addresses
     *  - `approvalData`: dapp-specific data forwared to {acceptRelayedCall}. This value is *not* verified by the
     * `RelayHub`, but it still can be used for e.g. a signature.
     *
     * Emits a {TransactionRelayed} event.
     */
    function relayCall(
        address from,
        address to,
        bytes calldata encodedFunction,
        uint256 transactionFee,
        uint256 gasPrice,
        uint256 gasLimit,
        uint256 nonce,
        bytes calldata signature,
        bytes calldata approvalData
    ) external;

    /**
     * @dev Emitted when an attempt to relay a call failed.
     *
     * This can happen due to incorrect {relayCall} arguments, or the recipient not accepting the relayed call. The
     * actual relayed call was not executed, and the recipient not charged.
     *
     * The `reason` parameter contains an error code: values 1-10 correspond to `PreconditionCheck` entries, and values
     * over 10 are custom recipient error codes returned from {acceptRelayedCall}.
     */
    event CanRelayFailed(address indexed relay, address indexed from, address indexed to, bytes4 selector, uint256 reason);

    /**
     * @dev Emitted when a transaction is relayed. 
     * Useful when monitoring a relay's operation and relayed calls to a contract
     *
     * Note that the actual encoded function might be reverted: this is indicated in the `status` parameter.
     *
     * `charge` is the Ether value deducted from the recipient's balance, paid to the relay's owner.
     */
    event TransactionRelayed(address indexed relay, address indexed from, address indexed to, bytes4 selector, RelayCallStatus status, uint256 charge);

    // Reason error codes for the TransactionRelayed event
    enum RelayCallStatus {
        OK,                      // The transaction was successfully relayed and execution successful - never included in the event
        RelayedCallFailed,       // The transaction was relayed, but the relayed call failed
        PreRelayedFailed,        // The transaction was not relayed due to preRelatedCall reverting
        PostRelayedFailed,       // The transaction was relayed and reverted due to postRelatedCall reverting
        RecipientBalanceChanged  // The transaction was relayed and reverted due to the recipient's balance changing
    }

    /**
     * @dev Returns how much gas should be forwarded to a call to {relayCall}, in order to relay a transaction that will
     * spend up to `relayedCallStipend` gas.
     */
    function requiredGas(uint256 relayedCallStipend) external view returns (uint256);

    /**
     * @dev Returns the maximum recipient charge, given the amount of gas forwarded, gas price and relay fee.
     */
    function maxPossibleCharge(uint256 relayedCallStipend, uint256 gasPrice, uint256 transactionFee) external view returns (uint256);

     // Relay penalization. 
     // Any account can penalize relays, removing them from the system immediately, and rewarding the
    // reporter with half of the relay's stake. The other half is burned so that, even if the relay penalizes itself, it
    // still loses half of its stake.

    /**
     * @dev Penalize a relay that signed two transactions using the same nonce (making only the first one valid) and
     * different data (gas price, gas limit, etc. may be different).
     *
     * The (unsigned) transaction data and signature for both transactions must be provided.
     */
    function penalizeRepeatedNonce(bytes calldata unsignedTx1, bytes calldata signature1, bytes calldata unsignedTx2, bytes calldata signature2) external;

    /**
     * @dev Penalize a relay that sent a transaction that didn't target `RelayHub`'s {registerRelay} or {relayCall}.
     */
    function penalizeIllegalTransaction(bytes calldata unsignedTx, bytes calldata signature) external;

    /**
     * @dev Emitted when a relay is penalized.
     */
    event Penalized(address indexed relay, address sender, uint256 amount);

    /**
     * @dev Returns an account's nonce in `RelayHub`.
     */
    function getNonce(address from) external view returns (uint256);
}

// File: @openzeppelin/contracts/GSN/GSNRecipient.sol

pragma solidity ^0.5.0;




/**
 * @dev Base GSN recipient contract: includes the {IRelayRecipient} interface
 * and enables GSN support on all contracts in the inheritance tree.
 *
 * TIP: This contract is abstract. The functions {IRelayRecipient-acceptRelayedCall},
 *  {_preRelayedCall}, and {_postRelayedCall} are not implemented and must be
 * provided by derived contracts. See the
 * xref:ROOT:gsn-strategies.adoc#gsn-strategies[GSN strategies] for more
 * information on how to use the pre-built {GSNRecipientSignature} and
 * {GSNRecipientERC20Fee}, or how to write your own.
 */
contract GSNRecipient is IRelayRecipient, Context {
    // Default RelayHub address, deployed on mainnet and all testnets at the same address
    address private _relayHub = 0xD216153c06E857cD7f72665E0aF1d7D82172F494;

    uint256 constant private RELAYED_CALL_ACCEPTED = 0;
    uint256 constant private RELAYED_CALL_REJECTED = 11;

    // How much gas is forwarded to postRelayedCall
    uint256 constant internal POST_RELAYED_CALL_MAX_GAS = 100000;

    /**
     * @dev Emitted when a contract changes its {IRelayHub} contract to a new one.
     */
    event RelayHubChanged(address indexed oldRelayHub, address indexed newRelayHub);

    /**
     * @dev Returns the address of the {IRelayHub} contract for this recipient.
     */
    function getHubAddr() public view returns (address) {
        return _relayHub;
    }

    /**
     * @dev Switches to a new {IRelayHub} instance. This method is added for future-proofing: there's no reason to not
     * use the default instance.
     *
     * IMPORTANT: After upgrading, the {GSNRecipient} will no longer be able to receive relayed calls from the old
     * {IRelayHub} instance. Additionally, all funds should be previously withdrawn via {_withdrawDeposits}.
     */
    function _upgradeRelayHub(address newRelayHub) internal {
        address currentRelayHub = _relayHub;
        require(newRelayHub != address(0), "GSNRecipient: new RelayHub is the zero address");
        require(newRelayHub != currentRelayHub, "GSNRecipient: new RelayHub is the current one");

        emit RelayHubChanged(currentRelayHub, newRelayHub);

        _relayHub = newRelayHub;
    }

    /**
     * @dev Returns the version string of the {IRelayHub} for which this recipient implementation was built. If
     * {_upgradeRelayHub} is used, the new {IRelayHub} instance should be compatible with this version.
     */
    // This function is view for future-proofing, it may require reading from
    // storage in the future.
    function relayHubVersion() public view returns (string memory) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return "1.0.0";
    }

    /**
     * @dev Withdraws the recipient's deposits in `RelayHub`.
     *
     * Derived contracts should expose this in an external interface with proper access control.
     */
    function _withdrawDeposits(uint256 amount, address payable payee) internal {
        IRelayHub(_relayHub).withdraw(amount, payee);
    }

    // Overrides for Context's functions: when called from RelayHub, sender and
    // data require some pre-processing: the actual sender is stored at the end
    // of the call data, which in turns means it needs to be removed from it
    // when handling said data.

    /**
     * @dev Replacement for msg.sender. Returns the actual sender of a transaction: msg.sender for regular transactions,
     * and the end-user for GSN relayed calls (where msg.sender is actually `RelayHub`).
     *
     * IMPORTANT: Contracts derived from {GSNRecipient} should never use `msg.sender`, and use {_msgSender} instead.
     */
    function _msgSender() internal view returns (address payable) {
        if (msg.sender != _relayHub) {
            return msg.sender;
        } else {
            return _getRelayedCallSender();
        }
    }

    /**
     * @dev Replacement for msg.data. Returns the actual calldata of a transaction: msg.data for regular transactions,
     * and a reduced version for GSN relayed calls (where msg.data contains additional information).
     *
     * IMPORTANT: Contracts derived from {GSNRecipient} should never use `msg.data`, and use {_msgData} instead.
     */
    function _msgData() internal view returns (bytes memory) {
        if (msg.sender != _relayHub) {
            return msg.data;
        } else {
            return _getRelayedCallData();
        }
    }

    // Base implementations for pre and post relayedCall: only RelayHub can invoke them, and data is forwarded to the
    // internal hook.

    /**
     * @dev See `IRelayRecipient.preRelayedCall`.
     *
     * This function should not be overriden directly, use `_preRelayedCall` instead.
     *
     * * Requirements:
     *
     * - the caller must be the `RelayHub` contract.
     */
    function preRelayedCall(bytes calldata context) external returns (bytes32) {
        require(msg.sender == getHubAddr(), "GSNRecipient: caller is not RelayHub");
        return _preRelayedCall(context);
    }

    /**
     * @dev See `IRelayRecipient.preRelayedCall`.
     *
     * Called by `GSNRecipient.preRelayedCall`, which asserts the caller is the `RelayHub` contract. Derived contracts
     * must implement this function with any relayed-call preprocessing they may wish to do.
     *
     */
    function _preRelayedCall(bytes memory context) internal returns (bytes32);

    /**
     * @dev See `IRelayRecipient.postRelayedCall`.
     *
     * This function should not be overriden directly, use `_postRelayedCall` instead.
     *
     * * Requirements:
     *
     * - the caller must be the `RelayHub` contract.
     */
    function postRelayedCall(bytes calldata context, bool success, uint256 actualCharge, bytes32 preRetVal) external {
        require(msg.sender == getHubAddr(), "GSNRecipient: caller is not RelayHub");
        _postRelayedCall(context, success, actualCharge, preRetVal);
    }

    /**
     * @dev See `IRelayRecipient.postRelayedCall`.
     *
     * Called by `GSNRecipient.postRelayedCall`, which asserts the caller is the `RelayHub` contract. Derived contracts
     * must implement this function with any relayed-call postprocessing they may wish to do.
     *
     */
    function _postRelayedCall(bytes memory context, bool success, uint256 actualCharge, bytes32 preRetVal) internal;

    /**
     * @dev Return this in acceptRelayedCall to proceed with the execution of a relayed call. Note that this contract
     * will be charged a fee by RelayHub
     */
    function _approveRelayedCall() internal pure returns (uint256, bytes memory) {
        return _approveRelayedCall("");
    }

    /**
     * @dev See `GSNRecipient._approveRelayedCall`.
     *
     * This overload forwards `context` to _preRelayedCall and _postRelayedCall.
     */
    function _approveRelayedCall(bytes memory context) internal pure returns (uint256, bytes memory) {
        return (RELAYED_CALL_ACCEPTED, context);
    }

    /**
     * @dev Return this in acceptRelayedCall to impede execution of a relayed call. No fees will be charged.
     */
    function _rejectRelayedCall(uint256 errorCode) internal pure returns (uint256, bytes memory) {
        return (RELAYED_CALL_REJECTED + errorCode, "");
    }

    /*
     * @dev Calculates how much RelayHub will charge a recipient for using `gas` at a `gasPrice`, given a relayer's
     * `serviceFee`.
     */
    function _computeCharge(uint256 gas, uint256 gasPrice, uint256 serviceFee) internal pure returns (uint256) {
        // The fee is expressed as a percentage. E.g. a value of 40 stands for a 40% fee, so the recipient will be
        // charged for 1.4 times the spent amount.
        return (gas * gasPrice * (100 + serviceFee)) / 100;
    }

    function _getRelayedCallSender() private pure returns (address payable result) {
        // We need to read 20 bytes (an address) located at array index msg.data.length - 20. In memory, the array
        // is prefixed with a 32-byte length value, so we first add 32 to get the memory read index. However, doing
        // so would leave the address in the upper 20 bytes of the 32-byte word, which is inconvenient and would
        // require bit shifting. We therefore subtract 12 from the read index so the address lands on the lower 20
        // bytes. This can always be done due to the 32-byte prefix.

        // The final memory read index is msg.data.length - 20 + 32 - 12 = msg.data.length. Using inline assembly is the
        // easiest/most-efficient way to perform this operation.

        // These fields are not accessible from assembly
        bytes memory array = msg.data;
        uint256 index = msg.data.length;

        // solhint-disable-next-line no-inline-assembly
        assembly {
            // Load the 32 bytes word from memory with the address on the lower 20 bytes, and mask those.
            result := and(mload(add(array, index)), 0xffffffffffffffffffffffffffffffffffffffff)
        }
        return result;
    }

    function _getRelayedCallData() private pure returns (bytes memory) {
        // RelayHub appends the sender address at the end of the calldata, so in order to retrieve the actual msg.data,
        // we must strip the last 20 bytes (length of an address type) from it.

        uint256 actualDataLength = msg.data.length - 20;
        bytes memory actualData = new bytes(actualDataLength);

        for (uint256 i = 0; i < actualDataLength; ++i) {
            actualData[i] = msg.data[i];
        }

        return actualData;
    }
}

// File: contracts/purchase/ICrateOpenEmitter.sol

pragma solidity = 0.5.16;


interface ICrateOpenEmitter {
    function openCrate(address from, uint256 lotId, uint256 amount) external;
}

// File: contracts/purchase/F1DeltaCrate.sol

pragma solidity = 0.5.16;






// crate token. 0 decimals - crates can't be fractional
contract F1DeltaCrate is ERC20Capped, ERC20Detailed, GSNRecipient, Ownable {
    enum ErrorCodes {
        RESTRICTED_METHOD,
        INSUFFICIENT_BALANCE
    }

    struct AcceptRelayedCallVars {
        bytes4 methodId;
        bytes ef;
    }

    string _uri;
    address _crateOpener;
    uint256 _lotId;
    uint256 public _cratesIssued;

    constructor(
        uint256 lotId, 
        uint256 cap,
        string memory name, 
        string memory symbol,
        string memory uri,
        address crateOpener
    ) ERC20Capped(cap) ERC20Detailed(name, symbol, 0) public {
        require(crateOpener != address(0));

        _uri = uri;
        _crateOpener = crateOpener;
        _lotId = lotId;
    }

    function burn(uint256 amount) public {
        _burn(_msgSender(), amount);
        ICrateOpenEmitter(_crateOpener).openCrate(_msgSender(), _lotId, amount);
    }

    function burnFrom(address account, uint256 amount) public {
        _burnFrom(account, amount);
        ICrateOpenEmitter(_crateOpener).openCrate(account, _lotId, amount);
    }

    function _mint(address account, uint256 amount) internal {
        _cratesIssued = _cratesIssued + amount; // not enough money in the world to cover 2 ^ 256 - 1 increments
        require(_cratesIssued <= cap(), "cratesIssued exceeded cap");
        super._mint(account, amount);
    }

    function tokenURI() public view returns (string memory) {
        return _uri;
    }

    function setURI(string memory uri) public onlyOwner {
        _uri = uri;
    }

    /////////////////////////////////////////// GSNRecipient implementation ///////////////////////////////////
    /**
     * @dev Ensures that only users with enough gas payment token balance can have transactions relayed through the GSN.
     */
    function acceptRelayedCall(
        address /*relay*/,
        address from,
        bytes calldata encodedFunction,
        uint256 /*transactionFee*/,
        uint256 /*gasPrice*/,
        uint256 /*gasLimit*/,
        uint256 /*nonce*/,
        bytes calldata /*approvalData*/,
        uint256 /*maxPossibleCharge*/
    )
        external
        view
        returns (uint256, bytes memory mem)
    {
        // restrict to burn function only
        // load methodId stored in first 4 bytes https://solidity.readthedocs.io/en/v0.5.16/abi-spec.html#function-selector-and-argument-encoding
        // load amount stored in the next 32 bytes https://solidity.readthedocs.io/en/v0.5.16/abi-spec.html#function-selector-and-argument-encoding
        // 32 bytes offset is required to skip array length
        bytes4 methodId;
        uint256 amountParam;
        mem = encodedFunction;
        assembly {
            let dest := add(mem, 32)
            methodId := mload(dest)
            dest := add(dest, 4)
            amountParam := mload(dest)
        }

        // bytes4(keccak256("burn(uint256)")) == 0x42966c68
        if (methodId != 0x42966c68) {
            return _rejectRelayedCall(uint256(ErrorCodes.RESTRICTED_METHOD));
        }

        // Check that user has enough crates to burn
        if (balanceOf(from) < amountParam) {
            return _rejectRelayedCall(uint256(ErrorCodes.INSUFFICIENT_BALANCE));
        }

        return _approveRelayedCall();
    }

    function _preRelayedCall(bytes memory) internal returns (bytes32) {
        // solhint-disable-previous-line no-empty-blocks
    }

    function _postRelayedCall(bytes memory, bool, uint256, bytes32) internal {
        // solhint-disable-previous-line no-empty-blocks
    }

    /**
     * @dev Withdraws the recipient's deposits in `RelayHub`.
     */
    function withdrawDeposits(uint256 amount, address payable payee) external onlyOwner {
        _withdrawDeposits(amount, payee);
    }
}

// File: contracts/purchase/IKyber.sol

pragma solidity = 0.5.16;



// https://github.com/KyberNetwork/smart-contracts/blob/master/contracts/KyberNetworkProxy.sol
interface IKyber {
    function getExpectedRate(ERC20 src, ERC20 dest, uint srcQty) external view
        returns (uint expectedRate, uint slippageRate);

    function trade(
        ERC20 src,
        uint srcAmount,
        ERC20 dest,
        address destAddress,
        uint maxDestAmount,
        uint minConversionRate,
        address walletId
    )
    external
    payable
        returns(uint);
}

// File: contracts/purchase/KyberAdapter.sol

pragma solidity = 0.5.16;





contract KyberAdapter {
    using SafeMath for uint256;

    IKyber public kyber;
    
    ERC20 public ETH_ADDRESS = ERC20(0x00eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee);

    constructor(address _kyberProxy) public {
        kyber = IKyber(_kyberProxy);
    }

    function () external payable {}

    function _getTokenDecimals(ERC20 _token) internal view returns (uint8 _decimals) {
        return _token != ETH_ADDRESS ? ERC20Detailed(address(_token)).decimals() : 18;
    }

    function _getTokenBalance(ERC20 _token, address _account) internal view returns (uint256 _balance) {
        return _token != ETH_ADDRESS ? _token.balanceOf(_account) : _account.balance;
    }

    function ceilingDiv(uint256 a, uint256 b) internal pure returns (uint256 c) {
        return a.div(b).add(a.mod(b) > 0 ? 1 : 0);
    }

    function _fixTokenDecimals(
        ERC20 _src,
        ERC20 _dest,
        uint256 _unfixedDestAmount,
        bool _ceiling
    )
    internal
    view
    returns (uint256 _destTokenAmount)
    {
        uint256 _unfixedDecimals = _getTokenDecimals(_src) + 18; // Kyber by default returns rates with 18 decimals.
        uint256 _decimals = _getTokenDecimals(_dest);

        if (_unfixedDecimals > _decimals) {
            // Divide token amount by 10^(_unfixedDecimals - _decimals) to reduce decimals.
            if (_ceiling) {
                return ceilingDiv(_unfixedDestAmount, (10 ** (_unfixedDecimals - _decimals)));
            } else {
                return _unfixedDestAmount.div(10 ** (_unfixedDecimals - _decimals));
            }
        } else {
            // Multiply token amount with 10^(_decimals - _unfixedDecimals) to increase decimals.
            return _unfixedDestAmount.mul(10 ** (_decimals - _unfixedDecimals));
        }
    }

    function _convertToken(
        ERC20 _src,
        uint256 _srcAmount,
        ERC20 _dest
    )
    internal
    view
    returns (
        uint256 _expectedAmount,
        uint256 _slippageAmount
    )
    {
        (uint256 _expectedRate, uint256 _slippageRate) = kyber.getExpectedRate(_src, _dest, _srcAmount);

        return (
            _fixTokenDecimals(_src, _dest, _srcAmount.mul(_expectedRate), false),
            _fixTokenDecimals(_src, _dest, _srcAmount.mul(_slippageRate), false)
        );
    }

    function _swapTokenAndHandleChange(
        ERC20 _src,
        uint256 _maxSrcAmount,
        ERC20 _dest,
        uint256 _maxDestAmount,
        uint256 _minConversionRate,
        address payable _initiator,
        address payable _receiver
    )
    internal
    returns (
        uint256 _srcAmount,
        uint256 _destAmount
    )
    {
        if (_src == _dest) {
            // payment is made with DAI
            require(_maxSrcAmount >= _maxDestAmount);
            _destAmount = _srcAmount = _maxDestAmount;
            require(IERC20(_src).transferFrom(_initiator, address(this), _destAmount));
        } else {
            require(_src == ETH_ADDRESS ? msg.value >= _maxSrcAmount : msg.value == 0);

            // Prepare for handling back the change if there is any.
            uint256 _balanceBefore = _getTokenBalance(_src, address(this));

            if (_src != ETH_ADDRESS) {
                require(IERC20(_src).transferFrom(_initiator, address(this), _maxSrcAmount));
                require(IERC20(_src).approve(address(kyber), _maxSrcAmount));
            } else {
                // Since we are going to transfer the source amount to Kyber.
                _balanceBefore = _balanceBefore.sub(_maxSrcAmount);
            }

            _destAmount = kyber.trade.value(
                _src == ETH_ADDRESS ? _maxSrcAmount : 0
            )(
                _src,
                _maxSrcAmount,
                _dest,
                _receiver,
                _maxDestAmount,
                _minConversionRate,
                address(0)
            );
            
            uint256 _balanceAfter = _getTokenBalance(_src, address(this));
            _srcAmount = _maxSrcAmount;

            // Handle back the change, if there is any, to the message sender.
            if (_balanceAfter > _balanceBefore) {
                uint256 _change = _balanceAfter - _balanceBefore;
                _srcAmount = _srcAmount.sub(_change);

                if (_src != ETH_ADDRESS) {
                    require(IERC20(_src).transfer(_initiator, _change));
                } else {
                    _initiator.transfer(_change);
                }
            }
        }
    }
}

// File: contracts/purchase/FixedSupplyCratesSale.sol

pragma solidity = 0.5.16;











contract FixedSupplyCratesSale is ReferrableSale, Pausable, KyberAdapter, ICrateOpenEmitter {
    using SafeMath for uint256;

    struct Lot {
        F1DeltaCrate crateToken;
        uint256 price; // in stable coin
    }

    struct PurchaseForVars {
        Lot lot;
        uint256 discount;
        uint256 price;
        uint256 referralReward;
        uint256 tokensSent;
        uint256 tokensReceived;
    }

    event Purchased (
        address indexed owner,
        address operator,
        uint256 indexed lotId,
        uint256 indexed quantity,
        uint256 pricePaid,
        address tokenAddress,
        uint256 tokensSent,
        uint256 tokensReceived,
        uint256 discountApplied,
        address referrer,
        uint256 referralRewarded
    );

    event LotCreated (
        uint256 lotId,
        uint256 supply,
        uint256 price,
        string uri,
        ERC20 crateToken
    );

    event LotPriceUpdated (
        uint256 lotId,
        uint256 price
    );

    event CrateOpened(address indexed from, uint256 lotId, uint256 amount);

    uint256 private constant PERCENT_PRECISION = 10000;
    uint256 private constant MULTI_PURCHASE_DISCOUNT_STEP = 5;

    ERC20 public _stableCoinAddress;
    address payable public _payoutWallet;

    mapping (uint256 => Lot) public _lots; // lotId => lot
    mapping (uint256 => mapping (address => address)) public _referrersByLot; // lotId => (buyer => referrer)
    mapping (address => mapping(uint256 => uint256)) public _cratesPurchased; // owner => (lot id => quantity)

    uint256 public _initialDiscountPercentage;
    uint256 public _initialDiscountPeriod;
    uint256 public _startedAt;
    uint256 public _multiPurchaseDiscount;

    modifier whenStarted() {
        require(_startedAt != 0);
        _;
    }

    modifier whenNotStarted() {
        require(_startedAt == 0);
        _;
    }

    constructor(
        address payable payoutWallet, 
        address kyberProxy, 
        ERC20 stableCoinAddress
    ) KyberAdapter(kyberProxy) public {
        require(payoutWallet != address(0));
        require(stableCoinAddress != ERC20(address(0)));
        setPayoutWallet(payoutWallet); 

        _stableCoinAddress = stableCoinAddress;
        pause();
    }

    function setPayoutWallet(address payable payoutWallet) public onlyOwner {
        require(payoutWallet != address(uint160(address(this))));
        _payoutWallet = payoutWallet;
    }

    function start(
        uint256 initialDiscountPercentage, 
        uint256 initialDiscountPeriod, 
        uint256 multiPurchaseDiscount
    ) 
    public 
    onlyOwner 
    whenNotStarted
    {
        require(initialDiscountPercentage < PERCENT_PRECISION);
        require(multiPurchaseDiscount < PERCENT_PRECISION);

        _initialDiscountPercentage = initialDiscountPercentage;
        _initialDiscountPeriod = initialDiscountPeriod;
        _multiPurchaseDiscount = multiPurchaseDiscount;
        
        // solium-disable-next-line security/no-block-members
        _startedAt = now;
        unpause();
    }

    function initialDiscountActive() public view returns (bool) {
        if (_initialDiscountPeriod == 0 || _initialDiscountPercentage == 0 || _startedAt == 0) {
            // No discount set or sale not started
            return false;
        }

        // solium-disable-next-line security/no-block-members
        uint256 elapsed = (now - _startedAt);
        return elapsed < _initialDiscountPeriod;
    }

    // owner can provide crate contract address which is compatible with F1DeltaCrate interface 
    // Make sure that crate contract has FixedSupplyCratesSale contract as minter.
    // if crate contract isn't provided sales contract will create simple F1DeltaCrate on it's own
    function createLot(
        uint256 lotId,
        uint256 supply,
        uint256 price,
        string memory name,
        string memory symbol,
        string memory uri,
        F1DeltaCrate crateToken
    ) 
        public 
        onlyOwner 
    {
        require(price != 0 && supply != 0);
        require(_lots[lotId].price == 0);
        
        Lot memory lot;
        lot.price = price;
        if (crateToken == F1DeltaCrate(address(0))) {
            lot.crateToken = new F1DeltaCrate(lotId, supply, name, symbol, uri, address(this));
            lot.crateToken.transferOwnership(owner());
            lot.crateToken.addMinter(owner());
        } else {
            lot.crateToken = crateToken;
        }
        
        _lots[lotId] = lot;

        emit LotCreated(lotId, supply, price, uri, ERC20(address(lot.crateToken)));
    }

    function updateLotPrice(uint256 lotId, uint128 price) external onlyOwner whenPaused {
        require(price != 0);
        require(_lots[lotId].price != 0);
        require(_lots[lotId].price != price);

        _lots[lotId].price = price;

        emit LotPriceUpdated(lotId, price);
    }

    function _nthPurchaseDiscount(uint lotPrice, uint quantity, uint cratesPurchased) private view returns(uint) {
        uint discountsApplied = cratesPurchased / MULTI_PURCHASE_DISCOUNT_STEP;
        uint discountsToApply = (cratesPurchased + quantity) / MULTI_PURCHASE_DISCOUNT_STEP - discountsApplied;

        return lotPrice.mul(discountsToApply).mul(_multiPurchaseDiscount).div(PERCENT_PRECISION);
    }

    function _getPriceWithDiscounts(Lot memory lot, uint quantity, uint cratesPurchased) private view returns(uint price, uint discount) {
        price = lot.price.mul(quantity);
        // Discounts are additive

        // apply early bird discount
        if (initialDiscountActive()) {
            discount = price.mul(_initialDiscountPercentage).div(PERCENT_PRECISION);
        }

        // apply multi purchase discount if any
        discount += _nthPurchaseDiscount(lot.price, quantity, cratesPurchased);
        price = price.sub(discount);
    }

    function purchaseFor(
        address payable destination,
        uint256 lotId,
        ERC20Capped tokenAddress,
        uint256 quantity,
        uint256 maxTokenAmount,
        uint256 minConversionRate,
        address payable referrer
    )
        external 
        payable
        whenNotPaused 
        whenStarted
    {
        require (quantity > 0);
        require (referrer != destination && referrer != msg.sender); //Inefficient

        // hack to fit as many variables on stack as required.
        PurchaseForVars memory vars;

        vars.lot = _lots[lotId];
        require(vars.lot.price != 0);

        (vars.price, vars.discount) = _getPriceWithDiscounts(vars.lot, quantity, _cratesPurchased[destination][lotId]);

        (vars.tokensSent, vars.tokensReceived) = _swapTokenAndHandleChange(
            tokenAddress,
            maxTokenAmount,
            _stableCoinAddress,
            vars.price,
            minConversionRate,
            msg.sender,
            address(uint160(address(this)))
        );
        
        // Check if received enough tokens.
        require(vars.tokensReceived >= vars.price);
        
        if (referrer != address(0)) {
            bool sendReferral = true;
            if (_customReferralPercentages[referrer] == 0) {
                // not a VIP
                if (_referrersByLot[lotId][destination] == referrer) { 
                    // buyer already used a referrer for this item before
                    sendReferral = false;
                }
            }
            
            if (sendReferral) {
                vars.referralReward = vars.tokensReceived
                    .mul(Math.max(_customReferralPercentages[referrer], _defaultReferralPercentage))
                    .div(PERCENT_PRECISION);

                if (vars.referralReward > 0) {
                    _referrersByLot[lotId][destination] = referrer;
                    // send stable coin as reward
                    require(_stableCoinAddress.transfer(referrer, vars.referralReward));
                }
            }
        }

        vars.tokensReceived = vars.tokensReceived.sub(vars.referralReward);

        require(vars.lot.crateToken.mint(destination, quantity)); 
        require(_stableCoinAddress.transfer(_payoutWallet, vars.tokensReceived));
        _cratesPurchased[destination][lotId] += quantity;

        emit Purchased(
            destination,
            msg.sender,
            lotId,
            quantity,
            vars.price,
            address(tokenAddress),
            vars.tokensSent,
            vars.tokensReceived,
            vars.discount,
            referrer,
            vars.referralReward
        );
    }

    function getPrice(
        uint256 lotId,
        uint256 quantity,
        ERC20 tokenAddress,
        address destination
    )
    external
    view
    returns (
        uint256 minConversionRate,
        uint256 lotPrice,
        uint256 lotPriceWithoutDiscount
    )
    {
        // convert Stable Coin -> Target Token (ETH is included)
        lotPriceWithoutDiscount = _lots[lotId].price.mul(quantity);
        (uint totalPrice, ) = _getPriceWithDiscounts(_lots[lotId], quantity, _cratesPurchased[destination][lotId]);

        (, uint tokenAmount) = _convertToken(_stableCoinAddress, totalPrice, tokenAddress);
        (, minConversionRate) = kyber.getExpectedRate(tokenAddress, _stableCoinAddress, tokenAmount);
        lotPrice = ceilingDiv(totalPrice.mul(10**36), minConversionRate);
        lotPrice = _fixTokenDecimals(_stableCoinAddress, tokenAddress, lotPrice, true);

        lotPriceWithoutDiscount = ceilingDiv(lotPriceWithoutDiscount.mul(10**36), minConversionRate);
        lotPriceWithoutDiscount = _fixTokenDecimals(_stableCoinAddress, tokenAddress, lotPriceWithoutDiscount, true);
    }

    function openCrate(address from, uint256 lotId, uint256 amount) external {
        require(address(_lots[lotId].crateToken) == msg.sender);
        for (uint256 i = 0; i < amount; i++ ) {
            emit CrateOpened(from, lotId, 1);
        }
    }

    // /**
    //  * @dev Withdraws the recipient's deposits in `RelayHub`.
    //  */
    // function withdrawDepositsForLot(uint256 lotId, uint256 amount, address payable payee) external onlyOwner {
    //     lots[lotId].crateToken.withdrawDeposits(amount, payee);
    // }
}