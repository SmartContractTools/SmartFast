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

// File: contracts/libs/SafeMath64.sol

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
library SafeMath64 {
    /**
     * @dev Returns the addition of two unsigned integers, reverting on
     * overflow.
     *
     * Counterpart to Solidity's `+` operator.
     *
     * Requirements:
     * - Addition cannot overflow.
     */
    function add(uint64 a, uint64 b) internal pure returns (uint64) {
        uint64 c = a + b;
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
    function sub(uint64 a, uint64 b) internal pure returns (uint64) {
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
    function sub(uint64 a, uint64 b, string memory errorMessage) internal pure returns (uint64) {
        require(b <= a, errorMessage);
        uint64 c = a - b;

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
    function mul(uint64 a, uint64 b) internal pure returns (uint64) {
        // Gas optimization: this is cheaper than requiring 'a' not being zero, but the
        // benefit is lost if 'b' is also tested.
        // See: https://github.com/OpenZeppelin/openzeppelin-solidity/pull/522
        if (a == 0) {
            return 0;
        }

        uint64 c = a * b;
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
     * Requirements:uint64
     * - The divisor cannot be zero.
     */
    function div(uint64 a, uint64 b) internal pure returns (uint64) {
        // Solidity only automatically asserts when dividing by 0
        require(b > 0, "SafeMath: division by zero");
        uint64 c = a / b;
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
    function mod(uint64 a, uint64 b) internal pure returns (uint64) {
        require(b != 0, "SafeMath: modulo by zero");
        return a % b;
    }
}

// File: contracts/chain/Uint64Chain.sol

pragma solidity >=0.5.0 <0.6.0;


/// @title Uint64Chain
/// @notice Uint64 Type    
/// @dev     TIME-BASE    .
/// @author jhhong
contract Uint64Chain {
    using SafeMath64 for uint64;

    //  :  
    struct NodeInfo {
        uint64 prev; //  
        uint64 next; //  
    }
    //  :  
    struct NodeList {
        uint64 count; //   
        uint64 head; //  
        uint64 tail; //  
        mapping(uint64 => NodeInfo) map; //     
    }

    //  
    NodeList private _slist; //   ()

    //  
    event Uint64ChainLinked(uint64 indexed node); // :  
    event Uint64ChainUnlinked(uint64 indexed node); // :  

    /// @author jhhong
    /// @notice     .
    /// @return    
    function count() public view returns(uint64) {
        return _slist.count;
    }

    /// @author jhhong
    /// @notice    .
    /// @return   
    function head() public view returns(uint64) {
        return _slist.head;
    }

    /// @author jhhong
    /// @notice    .
    /// @return   
    function tail() public view returns(uint64) {
        return _slist.tail;
    }

    /// @author jhhong
    /// @notice node    .
    /// @param node   (       )
    /// @return node   
    function nextOf(uint64 node) public view returns(uint64) {
        return _slist.map[node].next;
    }

    /// @author jhhong
    /// @notice node    .
    /// @param node   (       )
    /// @return node   
    function prevOf(uint64 node) public view returns(uint64) {
        return _slist.map[node].prev;
    }

    /// @author jhhong
    /// @notice node    .
    /// @param node      
    /// @return   (boolean), true: (linked), false:  (unlinked)
    function isLinked(uint64 node) public view returns (bool) {
        if(_slist.count == 1 && _slist.head == node && _slist.tail == node) {
            return true;
        } else {
            return (_slist.map[node].prev == uint64(0) && _slist.map[node].next == uint64(0))? (false) :(true);
        }
    }

    /// @author jhhong
    /// @notice      .
    /// @param node     
    function _linkChain(uint64 node) internal {
        require(!isLinked(node), "Uint64Chain: the node is aleady linked");
        if(_slist.count == 0) {
            _slist.head = _slist.tail = node;
        } else {
            _slist.map[node].prev = _slist.tail;
            _slist.map[_slist.tail].next = node;
            _slist.tail = node;
        }
        _slist.count = _slist.count.add(1);
        emit Uint64ChainLinked(node);
    }

    /// @author jhhong
    /// @notice node    .
    /// @param node      
    function _unlinkChain(uint64 node) internal {
        require(isLinked(node), "Uint64Chain: the node is aleady unlinked");
        uint64 tempPrev = _slist.map[node].prev;
        uint64 tempNext = _slist.map[node].next;
        if (_slist.head == node) {
            _slist.head = tempNext;
        }
        if (_slist.tail == node) {
            _slist.tail = tempPrev;
        }
        if (tempPrev != uint64(0)) {
            _slist.map[tempPrev].next = tempNext;
            _slist.map[node].prev = uint64(0);
        }
        if (tempNext != uint64(0)) {
            _slist.map[tempNext].prev = tempPrev;
            _slist.map[node].next = uint64(0);
        }
        _slist.count = _slist.count.sub(1);
        emit Uint64ChainUnlinked(node);
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

// File: contracts/libs/Address.sol

pragma solidity >=0.5.0 <0.6.0;

/**
 * @dev Collection of functions related to the address type,
 */
library Address {
    /**
     * @dev Returns true if `account` is a contract.
     *
     * This test is non-exhaustive, and there may be false-negatives: during the
     * execution of a contract's constructor, its address will be reported as
     * not containing a contract.
     *
     * > It is unsafe to assume that an address for which this function returns
     * false is an externally-owned account (EOA) and not a contract.
     */
    function isContract(address account) internal view returns (bool) {
        // This method relies in extcodesize, which returns 0 for contracts in
        // construction, since the code is only stored at the end of the
        // constructor execution.

        uint256 size;
        // solhint-disable-next-line no-inline-assembly
        assembly { size := extcodesize(account) }
        return size > 0;
    }

    /// @dev jhhong add features
    /// add useful functions and modifier definitions
    /// date: 2020.02.24

    /// @author jhhong
    /// @notice call     .
    /// @param addr    
    /// @param rawdata Bytes  ( + )
    /// @return   (bytes type) => abi.decode  
    function _call(address addr, bytes memory rawdata) internal returns(bytes memory) {
        (bool success, bytes memory data) = address(addr).call(rawdata);
        require(success == true, "Address: function(call) call failed");
        return data;
    }

    /// @author jhhong
    /// @notice delegatecall     .
    /// @param addr    
    /// @param rawdata Bytes  ( + )
    /// @return   (bytes type) => abi.decode  
    function _dcall(address addr, bytes memory rawdata) internal returns(bytes memory) {
        (bool success, bytes memory data) = address(addr).delegatecall(rawdata);
        require(success == true, "Address: function(delegatecall) call failed");
        return data;
    }

    /// @author jhhong
    /// @notice staticcall     .
    /// @dev bool    view / pure  CALL  .
    /// @param addr    
    /// @param rawdata Bytes  ( + )
    /// @return   (bytes type) => abi.decode  
    function _vcall(address addr, bytes memory rawdata) internal view returns(bytes memory) {
        (bool success, bytes memory data) = address(addr).staticcall(rawdata);
        require(success == true, "Address: function(staticcall) call failed");
        return data;
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

// File: contracts/DkargoFund.sol

pragma solidity >=0.5.0 <0.6.0;







/// @title DkargoFund
/// @notice    
/// @author jhhong
contract DkargoFund is Ownership, Uint64Chain, ERC165, DkargoPrefix {
    using Address for address;
    using SafeMath for uint256;

    mapping(uint64 => uint256) private _plans; //  
    address private _beneficier; //  
    address private _token; //   
    uint256 private _totals; //    ,      .
    
    event BeneficierUpdated(address indexed beneficier); // :  
    event PlanSet(uint64 time, uint256 amount); // :   (amount=0 )
    event Withdraw(uint256 amount); // : 

    /// @author jhhong
    /// @notice  .
    /// @param token   
    /// @param beneficier  
    constructor(address token, address beneficier) public {
        require(token != address(0), "DkargoFund: token is null");
        require(beneficier != address(0), "DkargoFund: beneficier is null");
        _setDkargoPrefix("fund"); //   (fund)
        _registerInterface(0x946edbed); // INTERFACE ID  (getDkargoPrefix)
        _token = token;
        _beneficier = beneficier;
    }

    /// @author jhhong
    /// @notice   .
    /// @dev   EOA, CA   .
    /// @param beneficier    (address)
    function setBeneficier(address beneficier) onlyOwner public {
        require(beneficier != address(0), "DkargoFund: beneficier is null");
        require(beneficier != _beneficier, "DkargoFund: should be not equal");
        _beneficier = beneficier;
        emit BeneficierUpdated(beneficier);
    }

    /// @author jhhong
    /// @notice   .
    /// @dev amount!=0    . linkChain  .      .
    /// amount=0   . unlinkChain  .      revert.
    /// time  (block.timestamp)   .
    ///    amount  balanceOf(fundCA)   .
    /// @param time   
    /// @param amount   
    function setPlan(uint64 time, uint256 amount) onlyOwner public {
        require(time > block.timestamp, "DkargoFund: invalid time");
        _totals = _totals.add(amount); //      
        _totals = _totals.sub(_plans[time]); //      
        require(_totals <= fundAmount(), "DkargoFund: over the limit"); //   
        _plans[time] = amount; //   
        emit PlanSet(time, amount); //  
        if(amount == 0) { //  
            _unlinkChain(time); //    , revert("AddressChain: the node is aleady unlinked")
        } else if(isLinked(time) == false) { //    ,    ,      
            _linkChain(time);
        }
    }

    /// @author jhhong
    /// @notice    .
    /// @dev   index  . revert!
    ///   ( )    revert!
    /// @param index  , setPlan    .
    function withdraw(uint64 index) onlyOwner public {
        require(index <= block.timestamp, "DkargoFund: an unexpired plan");
        require(_plans[index] > 0, "DkargoFund: plan is not set");
        bytes memory cmd = abi.encodeWithSignature("transfer(address,uint256)", _beneficier, _plans[index]);
        bytes memory data = address(_token)._call(cmd);
        bool result = abi.decode(data, (bool));
        require(result == true, "DkargoFund: failed to proceed raw-data");
        _totals = _totals.sub(_plans[index]); //      
        emit Withdraw(_plans[index]);
        _plans[index] = 0;
        _unlinkChain(index);
    }

    /// @author jhhong
    /// @notice Fund   .
    /// @return Fund   (uint256)
    function fundAmount() public view returns(uint256) {
        bytes memory data = address(_token)._vcall(abi.encodeWithSignature("balanceOf(address)", address(this)));
        return abi.decode(data, (uint256));
    }

    /// @author jhhong
    /// @notice     .
    /// @return     (uint256)
    function totalPlannedAmount() public view returns(uint256) {
        return _totals;
    }
    
    /// @author jhhong
    /// @notice      .
    /// @param index  , setPlan    .
    /// @return      (uint256)
    function plannedAmountOf(uint64 index) public view returns(uint256) {
        return _plans[index];
    }

    /// @author jhhong
    /// @notice   .
    /// @return   (address)
    function beneficier() public view returns(address) {
        return _beneficier;
    }

    /// @author jhhong
    /// @notice (ERC-20)  .
    /// @return   (address)
    function token() public view returns(address) {
        return _token;
    }
}