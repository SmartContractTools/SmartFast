// File: contracts/DkargoPrefix.sol

pragma solidity >=0.5.0 <0.6.0;

/// @title DkargoPrefix
/// @notice     prefix  
/// @author jhhong
contract DkargoPrefix {
    
    string internal _dkargoPrefix; // -
    
    /// @author jhhong
    /// @notice   .
    /// @return   (string)
    function getDkargoPrefix() public view returns(string memory) {
        return _dkargoPrefix;
    }

    /// @author jhhong
    /// @notice   .
    /// @param prefix  
    function _setDkargoPrefix(string memory prefix) internal {
        _dkargoPrefix = prefix;
    }
}

// File: contracts/authority/Ownership.sol

pragma solidity >=0.5.0 <0.6.0;

/// @title Onwership
/// @dev      
/// @author jhhong
contract Ownership {
    address private _owner;

    event OwnershipTransferred(address indexed old, address indexed expected);

    /// @author jhhong
    /// @notice     .
    modifier onlyOwner() {
        require(isOwner() == true, "Ownership: only the owner can call");
        _;
    }

    /// @author jhhong
    /// @notice  .
    constructor() internal {
        emit OwnershipTransferred(_owner, msg.sender);
        _owner = msg.sender;
    }

    /// @author jhhong
    /// @notice  .
    /// @param expected   
    function transferOwnership(address expected) public onlyOwner {
        require(expected != address(0), "Ownership: new owner is the zero address");
        emit OwnershipTransferred(_owner, expected);
        _owner = expected;
    }

    /// @author jhhong
    /// @notice   .
    /// @return  
    function owner() public view returns (address) {
        return _owner;
    }

    /// @author jhhong
    /// @notice  .
    /// @return   (boolean)
    function isOwner() public view returns (bool) {
        return msg.sender == _owner;
    }
}

// File: contracts/libs/refs/SafeMath.sol

pragma solidity >=0.5.0 <0.6.0;

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
     * NOTE: This is a feature of the next version of OpenZeppelin Contracts.
     * @dev Get it via `npm install @openzeppelin/contracts@next`.
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
        // See: https://github.com/OpenZeppelin/openzeppelin-solidity/pull/522
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

// File: contracts/chain/AddressChain.sol

pragma solidity >=0.5.0 <0.6.0;


/// @title AddressChain
/// @notice     
/// @dev ,       .
/// @author jhhong
contract AddressChain {
    using SafeMath for uint256;

    //  :  
    struct NodeInfo {
        address prev; //  
        address next; //  
    }
    //  :  
    struct NodeList {
        uint256 count; //   
        address head; //  
        address tail; //  
        mapping(address => NodeInfo) map; //     
    }

    //  
    NodeList private _slist; //   ()

    //  
    event AddressChainLinked(address indexed node); // :  
    event AddressChainUnlinked(address indexed node); // :  

    /// @author jhhong
    /// @notice     .
    /// @return    
    function count() public view returns(uint256) {
        return _slist.count;
    }

    /// @author jhhong
    /// @notice    .
    /// @return   
    function head() public view returns(address) {
        return _slist.head;
    }

    /// @author jhhong
    /// @notice    .
    /// @return   
    function tail() public view returns(address) {
        return _slist.tail;
    }

    /// @author jhhong
    /// @notice node    .
    /// @param node   (       )
    /// @return node   
    function nextOf(address node) public view returns(address) {
        return _slist.map[node].next;
    }

    /// @author jhhong
    /// @notice node    .
    /// @param node   (       )
    /// @return node   
    function prevOf(address node) public view returns(address) {
        return _slist.map[node].prev;
    }

    /// @author jhhong
    /// @notice node    .
    /// @param node      
    /// @return   (boolean), true: (linked), false:  (unlinked)
    function isLinked(address node) public view returns (bool) {
        if(_slist.count == 1 && _slist.head == node && _slist.tail == node) {
            return true;
        } else {
            return (_slist.map[node].prev == address(0) && _slist.map[node].next == address(0))? (false) :(true);
        }
    }

    /// @author jhhong
    /// @notice      .
    /// @param node     
    function _linkChain(address node) internal {
        require(node != address(0), "AddressChain: try to link to the zero address");
        require(!isLinked(node), "AddressChain: the node is aleady linked");
        if(_slist.count == 0) {
            _slist.head = _slist.tail = node;
        } else {
            _slist.map[node].prev = _slist.tail;
            _slist.map[_slist.tail].next = node;
            _slist.tail = node;
        }
        _slist.count = _slist.count.add(1);
        emit AddressChainLinked(node);
    }

    /// @author jhhong
    /// @notice node    .
    /// @param node      
    function _unlinkChain(address node) internal {
        require(node != address(0), "AddressChain: try to unlink to the zero address");
        require(isLinked(node), "AddressChain: the node is aleady unlinked");
        address tempPrev = _slist.map[node].prev;
        address tempNext = _slist.map[node].next;
        if (_slist.head == node) {
            _slist.head = tempNext;
        }
        if (_slist.tail == node) {
            _slist.tail = tempPrev;
        }
        if (tempPrev != address(0)) {
            _slist.map[tempPrev].next = tempNext;
            _slist.map[node].prev = address(0);
        }
        if (tempNext != address(0)) {
            _slist.map[tempNext].prev = tempPrev;
            _slist.map[node].next = address(0);
        }
        _slist.count = _slist.count.sub(1);
        emit AddressChainUnlinked(node);
    }
}

// File: contracts/introspection/ERC165/IERC165.sol

pragma solidity >=0.5.0 <0.6.0;

/// @title IERC165
/// @dev EIP165 interface 
/// https://github.com/ethereum/EIPs/blob/master/EIPS/eip-165.md
/// @author jhhong
interface IERC165 {
    function supportsInterface(bytes4 interfaceId) external view returns (bool);
}

// File: contracts/introspection/ERC165/ERC165.sol

pragma solidity >=0.5.0 <0.6.0;


/// @title ERC165
/// @dev EIP165 interface 
/// @author jhhong
contract ERC165 is IERC165 {
    
    mapping(bytes4 => bool) private _infcs; // INTERFACE ID     

    /// @author jhhong
    /// @notice  .
    /// @dev bytes4(keccak256('supportsInterface(bytes4)')) == 0x01ffc9a7
    constructor() internal {
        _registerInterface(0x01ffc9a7); // supportsInterface() INTERFACE ID 
    }

    /// @author jhhong
    /// @notice  INTERFACE ID   .
    /// @param infcid   INTERFACE ID (Function Selector)
    /// @return  (boolean)
    function supportsInterface(bytes4 infcid) external view returns (bool) {
        return _infcs[infcid];
    }

    /// @author jhhong
    /// @notice INTERFACE ID .
    /// @param infcid  INTERFACE ID (Function Selector)
    function _registerInterface(bytes4 infcid) internal {
        require(infcid != 0xffffffff, "ERC165: invalid interface id");
        _infcs[infcid] = true;
    }
}

// File: contracts/token/ERC20/IERC20.sol

pragma solidity >=0.5.0 <0.6.0;

/// @title IERC20
/// @notice EIP20 interface 
/// https://github.com/ethereum/EIPs/blob/master/EIPS/eip-20.md
/// @author jhhong
interface IERC20 {
    function transfer(address recipient, uint256 amount) external returns (bool);
    function approve(address spender, uint256 amount) external returns (bool);
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
    function totalSupply() external view returns (uint256);
    function balanceOf(address account) external view returns (uint256);
    function allowance(address owner, address spender) external view returns (uint256);
    
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
}

// File: contracts/token/ERC20/ERC20.sol

pragma solidity >=0.5.0 <0.6.0;



/// @title ERC20
/// @notice EIP20 interface   mint/burn (internal)  
/// @author jhhong
contract ERC20 is IERC20 {
    using SafeMath for uint256;
    
    uint256 private _supply; //  
    mapping(address => uint256) private _balances; //   
    mapping(address => mapping(address => uint256)) private _allowances; //    " " 
    
    /// @author jhhong
    /// @notice  .
    /// @param supply  
    constructor(uint256 supply) internal {
        uint256 pebs = supply;
        _mint(msg.sender, pebs);
    }
    
    /// @author jhhong
    /// @notice (spender) (value) .
    /// @param spender  
    /// @param amount  
    /// @return   true
    function approve(address spender, uint256 amount) public returns (bool) {
        _approve(msg.sender, spender, amount);
        return true;
    }
    
    /// @author jhhong
    /// @notice (recipient) (amount) .
    /// @param recipient  
    /// @param amount 
    /// @return   true
    function transfer(address recipient, uint256 amount) public returns (bool) {
        _transfer(msg.sender, recipient, amount);
        return true;
    }
    
    /// @author jhhong
    /// @notice (sender) (recipient) (amount) .
    /// @param sender  
    /// @param recipient  
    /// @param amount 
    /// @return   true
    function transferFrom(address sender, address recipient, uint256 amount) public returns (bool) {
        _transfer(sender, recipient, amount);
        _approve(sender, msg.sender, _allowances[sender][msg.sender].sub(amount, "ERC20: transfer amount exceeds allowance"));
        return true;
    }

    /// @author jhhong
    /// @notice    .
    /// @return  
    function totalSupply() public view returns (uint256) {
        return _supply;
    }
    
    /// @author jhhong
    /// @notice (account)   .
    /// @param account 
    /// @return (account)  
    function balanceOf(address account) public view returns (uint256) {
        return _balances[account];
    }
    
    /// @author jhhong
    /// @notice (approver) (spender)   .
    /// @param approver  
    /// @param spender  
    /// @return (approver) (spender)  
    function allowance(address approver, address spender) public view returns (uint256) {
        return _allowances[approver][spender];
    }
    
    /// @author jhhong
    /// @notice (approver) (spender) (value) .
    /// @param approver  
    /// @param spender  
    /// @param value  
    function _approve(address approver, address spender, uint256 value) internal {
        require(approver != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");
        _allowances[approver][spender] = value;
        emit Approval(approver, spender, value);
    }
    
    /// @author jhhong
    /// @notice (sender) (recipient) (amount) .
    /// @param sender  
    /// @param recipient  
    /// @param amount 
    function _transfer(address sender, address recipient, uint256 amount) internal {
        require(sender != address(0), "ERC20: transfer from the zero address");
        require(recipient != address(0), "ERC20: transfer to the zero address");
        _balances[sender] = _balances[sender].sub(amount, "ERC20: transfer amount exceeds balance");
        _balances[recipient] = _balances[recipient].add(amount);
        emit Transfer(sender, recipient, amount);
    }

    /// @author jhhong
    /// @notice (amount)  (account)  .
    /// @dev ERC20Mint  private  supply balances access   ERC20 internal .
    /// @param account    
    /// @param amount  
    function _mint(address account, uint256 amount) internal {
        require(account != address(0), "ERC20: mint to the zero address");
        _supply = _supply.add(amount);
        _balances[account] = _balances[account].add(amount);
        emit Transfer(address(0), account, amount);
    }

    /// @author jhhong
    /// @notice (value)  (account)  .
    /// @dev ERC20Mint  private  supply balances access   ERC20 internal .
    /// @param account   
    /// @param value  
    function _burn(address account, uint256 value) internal {
        require(account != address(0), "ERC20: burn from the zero address");
        _balances[account] = _balances[account].sub(value, "ERC20: burn amount exceeds balance");
        _supply = _supply.sub(value);
        emit Transfer(account, address(0), value);
    }
}

// File: contracts/token/ERC20/ERC20Safe.sol

pragma solidity >=0.5.0 <0.6.0;



/// @title ERC20Safe
/// @notice Approve Bug Fix  (  )
/// @author jhhong
contract ERC20Safe is ERC20 {
    using SafeMath for uint256;

    /// @author jhhong
    /// @notice (spender) (amount) .
    /// @dev        0   .
    /// @param spender  
    /// @param amount  
    /// @return   true
    function approve(address spender, uint256 amount) public returns (bool) {
        require((amount == 0) || (allowance(msg.sender, spender) == 0), "ERC20Safe: approve from non-zero to non-zero allowance");
        return super.approve(spender, amount);
    }

    /// @author jhhong
    /// @notice (spender)   (addedValue)  .
    /// @dev    ,      
    /// @param spender  
    /// @param addedValue  
    /// @return   true
    function increaseAllowance(address spender, uint256 addedValue) public returns (bool) {
        uint256 amount = allowance(msg.sender, spender).add(addedValue);
        return super.approve(spender, amount);
    }
    
    /// @author jhhong
    /// @notice (spender)   (subtractedValue)  .
    /// @dev    ,      
    /// @param spender  
    /// @param subtractedValue  
    /// @return   true
    function decreaseAllowance(address spender, uint256 subtractedValue) public returns (bool) {
        uint256 amount = allowance(msg.sender, spender).sub(subtractedValue, "ERC20: decreased allowance below zero");
        return super.approve(spender, amount);
    }
}

// File: contracts/DkargoToken.sol

pragma solidity >=0.5.0 <0.6.0;






/// @title DkargoToken
/// @notice     ( deploy)
/// @dev burn   (public)
/// @author jhhong
contract DkargoToken is Ownership, ERC20Safe, AddressChain, ERC165, DkargoPrefix {
    
    string private _name; //  
    string private _symbol; //  
    
    /// @author jhhong
    /// @notice  .
    /// @dev    , msg.sender   .
    /// @param name  
    /// @param symbol  
    /// @param supply  
    constructor(string memory name, string memory symbol, uint256 supply) ERC20(supply) public {
        _setDkargoPrefix("token"); //   (token)
        _registerInterface(0x946edbed); // INTERFACE ID  (getDkargoPrefix)
        _name = name;
        _symbol = symbol;
        _linkChain(msg.sender);
    }

    /// @author jhhong
    /// @notice      .
    /// @param amount  
    function burn(uint256 amount) external {
        _burn(msg.sender, amount);
    }

    /// @author jhhong
    /// @notice  . (: msg.sender)
    /// @dev        .
    /// @param to   
    /// @param value   ()
    function transfer(address to, uint256 value) public returns (bool) {
        bool ret = super.transfer(to, value);
        if(isLinked(msg.sender) && balanceOf(msg.sender) == 0) {
            _unlinkChain(msg.sender);
        }
        if(!isLinked(to) && balanceOf(to) > 0) {
            _linkChain(to);
        }
        return ret;
    }

    /// @author jhhong
    /// @notice  . (: from)
    /// @dev        .
    /// @param from   
    /// @param to   
    /// @param value   ()
    function transferFrom(address from, address to, uint256 value) public returns (bool) {
        bool ret = super.transferFrom(from, to, value);
        if(isLinked(from) && balanceOf(from) == 0) {
            _unlinkChain(from);
        }
        if(!isLinked(to) && balanceOf(to) > 0) {
            _linkChain(to);
        }
        return ret;
    }

    /// @author jhhong
    /// @notice   .
    /// @return  
    function name() public view returns(string memory) {
        return _name;
    }
    
    /// @author jhhong
    /// @notice   .
    /// @return  
    function symbol() public view returns(string memory) {
        return _symbol;
    }

    /// @author jhhong
    /// @notice   .
    /// @dev   18 (peb)  .
    /// @return  
    function decimals() public pure returns(uint256) {
        return 18;
    }
}