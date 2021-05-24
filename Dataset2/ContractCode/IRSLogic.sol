/*
*
*  Source code of DIB.ONE (https://dib.one) Interest Rate Swap product.
*  Synthetic product contract for Opium Protocol (https://opium.network)
*
*/

pragma solidity ^0.5.4;
pragma experimental ABIEncoderV2;

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

contract LibDerivative {
    struct Derivative {
        uint256 margin;
        uint256 endTime;
        uint256[] params;
        address oracleId;
        address token;
        address syntheticId;
    }

    function getDerivativeHash(Derivative memory _derivative) public pure returns (bytes32 derivativeHash) {
        derivativeHash = keccak256(abi.encodePacked(
            _derivative.margin,
            _derivative.endTime,
            _derivative.params,
            _derivative.oracleId,
            _derivative.token,
            _derivative.syntheticId
        ));
    }
}


contract IDerivativeLogic is LibDerivative {
    // Validates input data and returns whether derivative could be created
    function validateInput(Derivative memory _derivative) public view returns (bool);

    // Returns margin needed for the derivative creation
    function getMargin(Derivative memory _derivative) public view returns (uint256 buyerMargin, uint256 sellerMargin);

    // Returns payouts for derivative's execution
    function getExecutionPayout(Derivative memory _derivative, uint256 _result)	public view returns (uint256 buyerPayout, uint256 sellerPayout);

    // Returns author address
    function getAuthorAddress() public view returns (address authorAddress);

    // Returns author commission in base of COMMISSION_BASE
    function getAuthorCommission() public view returns (uint256 comission);

    // Returns whether thirdparty could execute on derivative's owner's behalf
    function thirdpartyExecutionAllowed(address derivativeOwner) public view returns (bool);

    // Returns whether synthetic implements pool logic
    function isPool() public view returns (bool);

    // Sets whether thirds parties are allowed or not to execute derivative's on msg.sender's behalf
    function allowThirdpartyExecution(bool allow) public;

    event MetadataSet(string metadata);
}

contract ExecutableByThirdParty {
    mapping (address => bool) thirdpartyExecutionAllowance;

    function thirdpartyExecutionAllowed(address derivativeOwner) public view returns (bool) {
        return thirdpartyExecutionAllowance[derivativeOwner];
    }

    function allowThirdpartyExecution(bool allow) public {
        thirdpartyExecutionAllowance[msg.sender] = allow;
    }
}

contract HasCommission {
    address public author;
    // 0.25%
    uint256 public commission = 25;

    constructor() public {
        author = msg.sender;
    }

    function getAuthorAddress() public view returns (address) {
        return author;
    }

    function getAuthorCommission() public view returns (uint256) {
        return commission;
    }
}

contract IRSLogic is IDerivativeLogic, ExecutableByThirdParty, HasCommission {
    using SafeMath for uint256;

    uint256 constant YEAR_DAYS = 360 days;
    
    constructor() public {
        /*
        {
            "author": "DIB.ONE",
            "type": "swap",
            "subtype": "irs",
            "description": "IRS logic contract"
        }
        */
        emit MetadataSet("{\"author\":\"DIB.ONE\",\"type\":\"swap\",\"subtype\":\"irs\",\"description\":\"IRS logic contract\"}");
    }

    // params[0] - nominal
    // params[1] - fixedRate
    // params[2] - initialIndex
    // params[3] - initialTimestamp
    function validateInput(Derivative memory _derivative) public view returns (bool) {
        if (_derivative.params.length < 3) {
            return false;
        }

        uint256 nominal = _derivative.params[0];
        uint256 fixedRate = _derivative.params[1];
        uint256 initialIndex = _derivative.params[2];
        uint256 initialTimestamp = _derivative.params[3];
        return (
            _derivative.margin > 0 &&
            _derivative.endTime > now &&
            nominal > 0 &&
            fixedRate > 0 &&
            initialIndex > 0 &&
            initialTimestamp <= now
        );
    }

    function getMargin(Derivative memory _derivative) public view returns (uint256 buyerMargin, uint256 sellerMargin) {
        buyerMargin = _derivative.margin;
        sellerMargin = _derivative.margin;
    }

    function getExecutionPayout(Derivative memory _derivative, uint256 _currentIndex) public view returns (uint256 buyerPayout, uint256 sellerPayout) {
        uint256 nominal = _derivative.params[0];
        uint256 fixedRate = _derivative.params[1];
        uint256 initialIndex = _derivative.params[2];
        uint256 initialTimestamp = _derivative.params[3];

        // timeElapsed = now - initialTimestamp
        uint256 timeElapsed = now.sub(initialTimestamp);

        // accumulatedRate = _currentIndex * 1e18 / initialIndex - 1e18
        uint256 accumulatedRate = _currentIndex.mul(10**18).div(initialIndex).sub(10**18);

        // fixedAmount = fixedRate * nominal * timeElapsed / YEARLY_BLOKS / 1e18
        uint256 fixedAmount = fixedRate.mul(nominal).mul(timeElapsed).div(YEAR_DAYS).div(10**18);
        
        // accumulatedAmount = accumulatedRate * nominal / 1e18
        uint256 accumulatedAmount = accumulatedRate.mul(nominal).div(10**18);
        
        uint256 profit;
        if (fixedAmount > accumulatedAmount) { // Buyer earns
            profit = fixedAmount - accumulatedAmount;

            if (profit > _derivative.margin) {
                buyerPayout = uint256(2).mul(_derivative.margin);
                sellerPayout = 0;
            } else {
                buyerPayout = _derivative.margin.add(profit);
                sellerPayout = _derivative.margin.sub(profit);
            }
        } else { // Seller earns
            profit = accumulatedAmount - fixedAmount;

            if (profit > _derivative.margin) {
                buyerPayout = 0;
                sellerPayout = uint256(2).mul(_derivative.margin);
            } else {
                buyerPayout = _derivative.margin.sub(profit);
                sellerPayout = _derivative.margin.add(profit);
            }
        }
    }

    function isPool() public view returns (bool) {
        return false;
    }
}