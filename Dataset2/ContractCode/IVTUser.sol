pragma solidity ^0.5.2;

/**
 * @title IVTUser
 * @dev Contract for upgradeable applications.
 * It handles the creation and upgrading of proxies.
 */
contract IVTUser {

    /// @dev  
    uint256 public required;
    /// @dev  owner
    address public owner;
    /// @dev  (==)
    mapping (address => bool) public signers;
    /// @dev  ==
    mapping (uint256 => bool) public transactions;
    /// @dev  
    IVTProxyInterface public proxy;

    event Deposit(address _sender, uint256 _value);
  /**
   * @dev Constructor function.
   */
  constructor(address[] memory _signers, IVTProxyInterface _proxy, uint8 _required) public {
    require(_required <= _signers.length && _required > 0 && _signers.length > 0);

    for (uint8 i = 0; i < _signers.length; i++){
        require(_signers[i] != address(0));
        signers[_signers[i]] = true;
    }
    required = _required;
    owner = msg.sender;
    proxy = _proxy;
}

  modifier onlyOwner() {
    require(msg.sender == owner);
    _;
  }

/**
 * @dev      
 * @return   {[null]}
 */
  function() payable external {
      if (msg.value > 0)
          emit Deposit(msg.sender, msg.value);
  }

  /**
   * @dev 
   * @param _data Data to send as msg.data in the low level call.
   * It should include the signature and the parameters of the function to be called, as described in
   * https://solidity.readthedocs.io/en/v0.4.24/abi-spec.html#function-selector-and-argument-encoding.
   */
  function callImpl(bytes calldata _data)  external onlyOwner {
    address implAddress = proxy.getImplAddress();
    implAddress.delegatecall(_data);// delegatecall
  }

/**
 * @dev      Id
 * @param _id _time to set
 */
  function setTransactionId(uint256 _id) public {
    transactions[_id] = true;
  }

/**
 * @dev      required
 * @return   {[uint256]}
 */
  function getRequired() public view returns (uint256) {
    return required;
  }

/**
 * @dev      
 * @param _signer _signer to sign
 * @return   {[bool]}
 */
  function hasSigner(address _signer) public view  returns (bool) {
    return signers[_signer];
  }

/**
 * @dev      Id
 * @param _transactionId _transactionTime to get
 * @return   {[bool]}
 */
  function hasTransactionId(uint256 _transactionId) public view returns (bool) {
    return transactions[_transactionId];
  }

}

/**
 * @title IVTProxyInterface
 * @dev Contract for ProxyInterface
 */
contract IVTProxyInterface {
  function getImplAddress() external view returns (address);
}