pragma solidity ^0.5.10;

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



interface IERC20 {
    function transfer(address to, uint256 value) external returns (bool);

    function approve(address spender, uint256 value) external returns (bool);

    function transferFrom(address from, address to, uint256 value) external returns (bool);

    function totalSupply() external view returns (uint256);

    function balanceOf(address who) external view returns (uint256);

    function allowance(address owner, address spender) external view returns (uint256);

    event Transfer(address indexed from, address indexed to, uint256 value);

    event Approval(address indexed owner, address indexed spender, uint256 value);
}


library Address {
    /**
     * Returns whether the target address is a contract
     * @dev This function will return false if invoked during the constructor of a contract,
     * as the code is not actually created until after the constructor finishes.
     * @param account address of the account to check
     * @return whether the target address is a contract
     */
    function isContract(address account) internal view returns (bool) {
        uint256 size;
        // XXX Currently there is no better way to check if there is a contract in an address
        // than to check the size of the code at that address.
        // See https://ethereum.stackexchange.com/a/14016/36603
        // for more details about how this works.
        // TODO Check this again before the Serenity release, because all addresses will be
        // contracts then.
        // solhint-disable-next-line no-inline-assembly
        assembly { size := extcodesize(account) }
        return size > 0;
    }
}


library ECDSA {
    /**
     * @dev Recover signer address from a message by using their signature
     * @param hash bytes32 message, the hash is the signed message. What is recovered is the signer address.
     * @param signature bytes signature, the signature is generated using web3.eth.sign()
     */
    function recover(bytes32 hash, bytes memory signature) internal pure returns (address) {
        bytes32 r;
        bytes32 s;
        uint8 v;

        // Check the signature length
        if (signature.length != 65) {
            return (address(0));
        }

        // Divide the signature in r, s and v variables
        // ecrecover takes the signature parameters, and the only way to get them
        // currently is to use assembly.
        // solhint-disable-next-line no-inline-assembly
        assembly {
            r := mload(add(signature, 0x20))
            s := mload(add(signature, 0x40))
            v := byte(0, mload(add(signature, 0x60)))
        }

        // Version of signature should be 27 or 28, but 0 and 1 are also possible versions
        if (v < 27) {
            v += 27;
        }

        // If the version is correct return the signer address
        if (v != 27 && v != 28) {
            return (address(0));
        } else {
            return ecrecover(hash, v, r, s);
        }
    }

    /**
     * toEthSignedMessageHash
     * @dev prefix a bytes32 value with "\x19Ethereum Signed Message:"
     * and hash the result
     */
    function toEthSignedMessageHash(bytes32 hash) internal pure returns (bytes32) {
        // 32 is the length in bytes of hash,
        // enforced by the type signature above
        return keccak256(abi.encodePacked("\x19Ethereum Signed Message:\n32", hash));
    }
}


contract AbstractAccount {

  event DeviceAdded(address device, bool isOwner);
  event DeviceRemoved(address device);
  event TransactionExecuted(address recipient, uint256 value, bytes data, bytes response);

  struct Device {
    bool isOwner;
    bool exists;
    bool existed;
  }

  mapping(address => Device) public devices;

  function addDevice(address _device, bool _isOwner) public;

  function removeDevice(address _device) public;

  function executeTransaction(address payable _recipient, uint256 _value, bytes memory _data) public returns (bytes memory _response);
}



/**
 * @title Account Library
 */
library AccountLibrary {

  using ECDSA for bytes32;

  function isOwnerDevice(
    AbstractAccount _account,
    address _device
  ) internal view returns (bool) {
    bool isOwner;
    (isOwner,,) = _account.devices(_device);
    return isOwner;
  }

  function isAnyDevice(
    AbstractAccount _account,
    address _device
  ) internal view returns (bool) {
    bool exists;
    (,exists,) = _account.devices(_device);
    return exists;
  }

  function isExistedDevice(
    AbstractAccount _account,
    address _device
  ) internal view returns (bool) {
    bool existed;
    (,,existed) = _account.devices(_device);
    return existed;
  }

  function verifyOwnerSignature(
    AbstractAccount _account,
    bytes32 _messageHash,
    bytes memory _signature
  ) internal view returns (bool _result) {
    address _recovered = _messageHash.recover(_signature);

    if (_recovered != address(0)) {
      _result = isOwnerDevice(_account, _recovered);
    }
  }

  function verifySignature(
    AbstractAccount _account,
    bytes32 _messageHash,
    bytes memory _signature,
    bool _strict
  ) internal view returns (bool _result) {
    address _recovered = _messageHash.recover(_signature);

    if (_recovered != address(0)) {
      if (_strict) {
        _result = isAnyDevice(_account, _recovered);
      } else {
        _result = isExistedDevice(_account, _recovered);
      }
    }
  }
}



/**
 * @title Address Library
 */
library AddressLibrary {

  using AccountLibrary for AbstractAccount;
  using Address for address;
  using ECDSA for bytes32;

  function verifySignature(
    address _address,
    bytes32 _messageHash,
    bytes memory _signature,
    bool _strict
  ) internal view returns (bool _result) {
    if (_address.isContract()) {
      _result = AbstractAccount(_address).verifySignature(
        _messageHash,
        _signature,
        _strict
      );
    } else {
      address _recovered = _messageHash.recover(_signature);
      _result = _recovered == _address;
    }
  }
}


/**
 * @title Virtual Payment Manager
 */
contract VirtualPaymentManager {

  using AddressLibrary for address;
  using ECDSA for bytes32;
  using SafeMath for uint256;

  event NewDeposit(address owner, address token, uint256 value);
  event NewWithdrawal(address recipient, address token, uint256 value);
  event NewWithdrawalRequest(address owner, address token, uint256 unlockedAt);
  event NewPayment(address sender, address recipient, address token, uint256 id, uint256 value);

  struct Deposit {
    uint256 value;
    uint256 withdrawalUnlockedAt;
  }

  struct Payment {
    uint256 value;
  }

  mapping(address => mapping(address => Deposit)) public deposits;
  mapping(bytes32 => Payment) public payments;

  address public guardian;
  uint256 public depositWithdrawalLockPeriod;

  string constant ERR_INVALID_SIGNATURE = "Invalid signature";
  string constant ERR_INVALID_VALUE = "Invalid value";
  string constant ERR_INVALID_TOKEN = "Invalid token";

  constructor(
    address _guardian,
    uint256 _depositWithdrawalLockPeriod
  ) public {
    guardian = _guardian;
    depositWithdrawalLockPeriod = _depositWithdrawalLockPeriod;
  }

  function getDepositValue(address _owner, address _token) public view returns (uint256) {
    return deposits[_owner][_token].value;
  }

  function getDepositWithdrawalUnlockedAt(address _owner, address _token) public view returns (uint256) {
    return deposits[_owner][_token].withdrawalUnlockedAt;
  }

  function() external payable {
    deposits[msg.sender][address(0)].value = deposits[msg.sender][address(0)].value.add(msg.value);

    emit NewDeposit(msg.sender, address(0), msg.value);
  }

  function depositToken(address _token, uint256 _value) public {
    require(
      _token != address(0),
      ERR_INVALID_TOKEN
    );

    IERC20(_token).transferFrom(msg.sender, address(this), _value);

    deposits[msg.sender][_token].value = deposits[msg.sender][_token].value.add(_value);

    emit NewDeposit(msg.sender, _token, _value);
  }

  function depositPayment(
    address _sender,
    address _recipient,
    address _token,
    uint256 _id,
    uint256 _value,
    bytes memory _senderSignature,
    bytes memory _guardianSignature
  ) public {
    uint256 _processedValue = _processPayment(
      _sender,
      _recipient,
      _token,
      _id,
      _value,
      _senderSignature,
      _guardianSignature
    );

    deposits[_recipient][_token].value = deposits[_recipient][_token].value.add(_processedValue);

    emit NewPayment(_sender, _recipient, _token, _id, _processedValue);
    emit NewDeposit(_recipient, _token, _processedValue);
  }

  function withdrawPayment(
    address _sender,
    address _recipient,
    address _token,
    uint256 _id,
    uint256 _value,
    bytes memory _senderSignature,
    bytes memory _guardianSignature
  ) public {
    uint256 _processedValue = _processPayment(
      _sender,
      _recipient,
      _token,
      _id,
      _value,
      _senderSignature,
      _guardianSignature
    );

    _transfer(_recipient, _token, _processedValue);

    emit NewPayment(_sender, _recipient, _token, _id, _processedValue);
    emit NewWithdrawal(_recipient, _token, _processedValue);
  }

  function withdrawDeposit(address _token) public {
    if (
      deposits[msg.sender][_token].withdrawalUnlockedAt != 0 && deposits[msg.sender][_token].withdrawalUnlockedAt <= now
    ) {
      _transfer(msg.sender, _token, deposits[msg.sender][_token].value);

      emit NewWithdrawal(msg.sender, _token, deposits[msg.sender][_token].value);

      delete deposits[msg.sender][_token];
    } else {
      deposits[msg.sender][_token].withdrawalUnlockedAt = now.add(depositWithdrawalLockPeriod);

      emit NewWithdrawalRequest(msg.sender, _token, deposits[msg.sender][_token].withdrawalUnlockedAt);
    }
  }

  function _processPayment(
    address _sender,
    address _recipient,
    address _token,
    uint256 _id,
    uint256 _value,
    bytes memory _senderSignature,
    bytes memory _guardianSignature
  ) private returns (uint256 _processedValue) {
    bytes32 _messageHash = keccak256(
      abi.encodePacked(
        address(this),
        _sender,
        _recipient,
        _token,
        _id,
        _value
      )
    ).toEthSignedMessageHash();

    require(
      _sender.verifySignature(_messageHash, _senderSignature, false),
      ERR_INVALID_SIGNATURE
    );
    require(
      guardian.verifySignature(_messageHash, _guardianSignature, true),
      ERR_INVALID_SIGNATURE
    );

    bytes32 _paymentHash = keccak256(abi.encodePacked(
        _sender,
        _recipient,
        _token,
        _id
      ));

    require(
      _value > 0,
      ERR_INVALID_VALUE
    );

    if (payments[_paymentHash].value > 0) {
      require(
        payments[_paymentHash].value < _value,
        ERR_INVALID_VALUE
      );
      _processedValue = _value.sub(payments[_paymentHash].value);
    } else {
      _processedValue = _value;
    }

    require(
      deposits[_sender][_token].value >= _processedValue,
      ERR_INVALID_VALUE
    );

    if (deposits[_sender][_token].withdrawalUnlockedAt > 0) {
      delete deposits[_sender][_token].withdrawalUnlockedAt;
    }

    payments[_paymentHash].value = _value;
    deposits[_sender][_token].value = deposits[_sender][_token].value.sub(_processedValue);
  }

  function _transfer(address _recipient, address _token, uint256 _value) private {
    if (_token == address(0)) {
      address payable _payableRecipient = address(uint160(_recipient));
      _payableRecipient.transfer(_value);
    } else {
      IERC20(_token).transfer(_recipient, _value);
    }
  }
}