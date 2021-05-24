pragma solidity ^0.5.2;

 /**
 * @title Pausable
 * @dev Base contract which allows children to implement an emergency stop mechanism.
 */
contract Pausable {
  event Pause();
  event Unpause();

  bool public paused = false;
  address public owner;

  constructor() public {
    owner = msg.sender;
  }

  modifier onlyOwner() {
    if (msg.sender == owner)
      _;
  }

  /**
   * @dev Modifier to make a function callable only when the contract is not paused.
   */
  modifier whenNotPaused() {
    require(!paused);
    _;
  }

  /**
   * @dev Modifier to make a function callable only when the contract is paused.
   */
  modifier whenPaused() {
    require(paused);
    _;
  }

  /**
   * @dev called by the owner to pause, triggers stopped state
   */
  function pause() onlyOwner whenNotPaused public {
    paused = true;
    emit Pause();
  }

  /**
   * @dev called by the owner to unpause, returns to normal state
   */
  function unpause() onlyOwner whenPaused public {
    paused = false;
    emit Unpause();
  }
}

/**
 * Utility library of inline functions on addresses
 */
library AddressUtils {

  /**
   * Returns whether the target address is a contract
   * @dev This function will return false if invoked during the constructor of a contract,
   * as the code is not actually created until after the constructor finishes.
   * @param addr address to check
   * @return whether the target address is a contract
   */
  function isContract(address addr) internal view returns (bool) {
    uint256 size;
    // XXX Currently there is no better way to check if there is a contract in an address
    // than to check the size of the code at that address.
    // See https://ethereum.stackexchange.com/a/14016/36603
    // for more details about how this works.
    // TODO Check this again before the Serenity release, because all addresses will be
    // contracts then.
    // solium-disable-next-line security/no-inline-assembly
    assembly { size := extcodesize(addr) }
    return size > 0;
  }

}


/**
 * @title UpgradeabilityProxy
 * @dev This contract implements a proxy that allows to change the
 * implementation address to which it will delegate.
 * Such a change is called an implementation upgrade.
 */
contract UpgradeabilityProxy {
  /**
   * @dev Storage slot with the address of the current implementation.
   * This is the keccak-256 hash of "www.invault.io.proxy.implementation", and is
   * validated in the constructor.
   */
  bytes32 private constant IMPLEMENTATION_SLOT = 0xbe2c1a60709d4c60c413b72a0999dd04a683092d060b4c9def249fa6bc842b2d;

  /**
   * @dev Contract constructor.
   * @param _implementation Address of the initial implementation.
   * It should include the signature and the parameters of the function to be called, as described in
   * https://solidity.readthedocs.io/en/v0.4.24/abi-spec.html#function-selector-and-argument-encoding.
   * This parameter is optional, if no data is given the initialization call to proxied contract will be skipped.
   */
  constructor(address _implementation) public {
    assert(IMPLEMENTATION_SLOT == keccak256("www.invault.io.proxy.implementation"));
    _setImplementation(_implementation);
  }

  /**
   * @dev Returns the current implementation.
   * @return Address of the current implementation
   */
  function _implementation() internal view returns (address impl) {
    bytes32 slot = IMPLEMENTATION_SLOT;
    assembly {
      impl := sload(slot)
    }
  }

  /**
   * @dev Upgrades the proxy to a new implementation.
   * @param newImplementation Address of the new implementation.
   */
  function _upgradeTo(address newImplementation) internal {
    _setImplementation(newImplementation);
  }

  /**
   * @dev proxyImpl
   * @param newImplementation Address of the new implementation.
   */
  function _setImplementation(address newImplementation) private {
    require(AddressUtils.isContract(newImplementation), "Cannot set a proxy implementation to a non-contract address");

    bytes32 slot = IMPLEMENTATION_SLOT;

    assembly {
      sstore(slot, newImplementation)
    }
  }
}


/**
 * @title IVTProxy
 * @dev Contract for Proxy applications.
 */
contract IVTProxy is UpgradeabilityProxy, Pausable {

  /**
   * @dev Storage slot with the perm of the contract.
   * This is the keccak-256 hash of "www.invault.io.proxy.permission", and is
   * validated in the constructor.
   */
  bytes32 private constant PERM_SLOT = 0x9f2b05956adf3f5dc678f8c50dd9693f2163f4bec0d0b84a13327b894102a4e5;

  /**
   * @dev Modifier to check whether the `msg.sender` is the Permission.
   * If it is, it will run the function.
   */
  modifier OnlyPermission() {
    require(msg.sender == _perm());
      _;
  }

  /**
   * Contract constructor.
   * @param _implementation address of the initial implementation.
   * It should include the signature and the parameters of the function to be called, as described in
   * https://solidity.readthedocs.io/en/v0.4.24/abi-spec.html#function-selector-and-argument-encoding.
   * This parameter is optional, if no data is given the initialization call to proxied contract will be skipped.
   */
  constructor(address _implementation, address _permission) UpgradeabilityProxy(_implementation) public {
    assert(PERM_SLOT == keccak256("www.invault.io.proxy.permission"));
    _setPermission(_permission);
  }

  /**
   * @return The address of the proxy admin.
   */
  function getPermAddress() external view whenNotPaused returns (address) {
    return _perm();
  }

  /**
   * @return The address of the implementation.
   */
  function getImplAddress() external view whenNotPaused returns (address) {
    return _implementation();
  }

  /**
   * @dev proxyimplementationPermission
   * @param newImplementation Address of the new implementation.
   */
  function upgradeImpl(address newImplementation) external OnlyPermission whenNotPaused returns(bool) {
    _upgradeTo(newImplementation);
    return true;
  }



  /**
   * @dev proxypermissionPermission
   * @param newPermission Address.
   */
  function upgradePerm(address newPermission) external OnlyPermission whenNotPaused returns(bool)  {
    _setPermission(newPermission);
    return true;
  }


/**
 * @dev 
 * @param _data call
 * @return {[type]}
 */
  function requestUpgrade(bytes calldata _data) external onlyOwner whenNotPaused {
     address permission = _perm();
     permission.call(_data);

  }

  /**
   * @return The permission slot.
   */
  function _perm() internal view returns (address adm) {
    bytes32 slot = PERM_SLOT;
    assembly {
      adm := sload(slot)
    }
  }

  /**
   * @dev Sets the address of the proxy permission.
   * @param newPerm Address of the new proxy permission.
   */
  function _setPermission(address newPerm) internal {

    require(AddressUtils.isContract(newPerm), "Cannot set a proxy permission to a non-contract address");

    bytes32 slot = PERM_SLOT;

    assembly {
      sstore(slot, newPerm)
    }
  }

}