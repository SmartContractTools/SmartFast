pragma solidity 0.5.11; // optimization runs: 200, evm version: petersburg


interface UpgradeBeaconControllerInterface {
  function upgrade(address beacon, address implementation) external;
}


contract Ownable {
  address private _owner;

  event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

  constructor () internal {
    _owner = msg.sender;
    emit OwnershipTransferred(address(0), _owner);
  }

  function owner() public view returns (address) {
    return _owner;
  }

  modifier onlyOwner() {
    require(isOwner(), "Ownable: caller is not the owner");
    _;
  }

  function isOwner() public view returns (bool) {
    return msg.sender == _owner;
  }

  function renounceOwnership() public onlyOwner {
    emit OwnershipTransferred(_owner, address(0));
    _owner = address(0);
  }

  function transferOwnership(address newOwner) public onlyOwner {
    _transferOwnership(newOwner);
  }

  function _transferOwnership(address newOwner) internal {
    require(newOwner != address(0), "Ownable: new owner is the zero address");
    emit OwnershipTransferred(_owner, newOwner);
    _owner = newOwner;
  }
}


library SafeMath {
  function add(uint256 a, uint256 b) internal pure returns (uint256) {
    uint256 c = a + b;
    require(c >= a, "SafeMath: addition overflow");

    return c;
  }

  function sub(uint256 a, uint256 b) internal pure returns (uint256) {
    require(b <= a, "SafeMath: subtraction overflow");
    uint256 c = a - b;

    return c;
  }

  function mul(uint256 a, uint256 b) internal pure returns (uint256) {
    if (a == 0) {
      return 0;
    }

    uint256 c = a * b;
    require(c / a == b, "SafeMath: multiplication overflow");

    return c;
  }

  function div(uint256 a, uint256 b) internal pure returns (uint256) {
    require(b > 0, "SafeMath: division by zero");
    uint256 c = a / b;

    return c;
  }

  function mod(uint256 a, uint256 b) internal pure returns (uint256) {
    require(b != 0, "SafeMath: modulo by zero");
    return a % b;
  }
}


/**
 * @title Timelocker
 * @author 0age
 * @notice This contract allows contracts that inherit it to implement timelocks
 * on functions, where the `setTimelock` function must first be called, with the
 * same arguments that the function will be supplied with. Then, a given time
 * interval must first fully transpire before the timelock functions can be
 * successfully called. It also includes a `modifyTimelockInterval` function
 * that is itself able to be timelocked, and that is given a function selector
 * and a new timelock interval for the function as arguments. To make a function
 * timelocked, use the `_enforceTimelock` internal function. To set initial
 * minimum timelock intervals, use the `_setInitialTimelockInterval` internal
 * function - it can only be used from within a constructor. Finally, there are
 * two public getters: `getTimelock` and `getTimelockInterval`.
 */
contract Timelocker {
  using SafeMath for uint256;

  // Fire an event any time a timelock is initiated.
  event TimelockInitiated(
    bytes4 functionSelector, // selector of the function 
    uint256 timeComplete,    // timestamp at which the function can be called
    bytes arguments          // abi-encoded function arguments to call with
  );

  // Fire an event any time a minimum timelock interval is modified.
  event TimelockIntervalModified(
    bytes4 functionSelector, // selector of the function 
    uint256 oldInterval,     // new minimum timelock interval for the function
    uint256 newInterval      // new minimum timelock interval for the function
  );

  // Implement a timelock for each function and set of arguments.
  mapping(bytes4 => mapping(bytes32 => uint256)) private _timelocks;

  // Implement a timelock interval for each timelocked function.
  mapping(bytes4 => uint256) private _timelockIntervals;

  /**
   * @notice Public function for setting a new timelock interval for a given 
   * function selector. The default for this function may also be modified, but
   * excessive values will cause the `modifyTimelockInterval` function to become
   * unusable.
   * @param functionSelector the selector of the function to set the timelock
   * interval for.
   * @param newTimelockInterval the new minimum timelock interval to set for the
   * given function.
   */
  function modifyTimelockInterval(
    bytes4 functionSelector,
    uint256 newTimelockInterval
  ) public {
    // Ensure that the timelock has been set and is completed.
    _enforceTimelock(
      this.modifyTimelockInterval.selector, abi.encode(newTimelockInterval)
    );

    // Set new timelock interval and emit a `TimelockIntervalModified` event.
    _setTimelockInterval(functionSelector, newTimelockInterval);
  }

  /**
   * @notice View function to check if a timelock for the specified function and
   * arguments has completed.
   * @param functionSelector function to be called.
   * @param arguments The abi-encoded arguments of the function to be called.
   * @return A boolean indicating if the timelock exists or not and the time at
   * which the timelock completes if it does exist.
   */
  function getTimelock(
    bytes4 functionSelector,
    bytes memory arguments
  ) public view returns (bool exists, uint256 completionTime) {
    // Get timelock ID using the supplied function arguments.
    bytes32 timelockID = keccak256(abi.encodePacked(arguments));

    // Get the current timelock, if any.
    completionTime = _timelocks[functionSelector][timelockID];
    exists = completionTime != 0;
  }

  /**
   * @notice View function to check the current minimum timelock interval on a
   * given function.
   * @param functionSelector function to retrieve the timelock interval for.
   * @return The current minimum timelock interval for the given function.
   */
  function getTimelockInterval(
    bytes4 functionSelector
  ) public view returns (uint256 timelockInterval) {
    timelockInterval = _timelockIntervals[functionSelector];
  }

  /**
   * @notice Internal function that sets a timelock so that the specified
   * function can be called with the specified arguments. Note that existing
   * timelocks may be extended, but not shortened - this can also be used as a
   * method for "cancelling" a function call by extending the timelock to an
   * arbitrarily long duration. Keep in mind that new timelocks may be created
   * with a shorter duration on functions that already have other timelocks on
   * them, but only if they have different arguments.
   * @param functionSelector selector of the function to be called.   
   * @param arguments The abi-encoded arguments of the function to be called.
   * @param extraTime Additional time in seconds to add to the minimum timelock
   * interval for the given function.
   */
  function _setTimelock(
    bytes4 functionSelector,
    bytes memory arguments,
    uint256 extraTime
  ) internal {
    // Get timelock using current time, inverval for timelock ID, & extra time.
    uint256 timelock = _timelockIntervals[functionSelector].add(now).add(
      extraTime
    );

    // Get timelock ID using the supplied function arguments.
    bytes32 timelockID = keccak256(abi.encodePacked(arguments));

    // Get the current timelock, if any.
    uint256 currentTimelock = _timelocks[functionSelector][timelockID];

    // Ensure that the timelock duration does not decrease. Note that a new,
    // shorter timelock may still be set up on the same function in the event
    // that it is provided with different arguments.
    require(
      currentTimelock == 0 || timelock > currentTimelock,
      "Existing timelocks may only be extended."
    );

    // Set time that timelock will be complete using timelock ID and extra time.
    _timelocks[functionSelector][timelockID] = timelock;

    // Emit an event with all of the relevant information.
    emit TimelockInitiated(functionSelector, timelock, arguments);
  }

  /**
   * @notice Internal function to set an initial timelock interval for a given
   * function selector. Only callable during contract creation.
   * @param functionSelector the selector of the function to set the timelock
   * interval for.
   * @param newTimelockInterval the new minimum timelock interval to set for the
   * given function.
   */
  function _setInitialTimelockInterval(
    bytes4 functionSelector,
    uint256 newTimelockInterval
  ) internal {
    // Ensure that this function is only callable during contract construction.
    assembly { if extcodesize(address) { revert(0, 0) } }
    
    // Set the timelock interval and emit a `TimelockIntervalModified` event.
    _setTimelockInterval(functionSelector, newTimelockInterval);
  }

  /**
   * @notice Internal function to ensure that a timelock is complete and to
   * clear the existing timelock so it cannot later be reused.
   * @param functionSelector function to be called.   
   * @param arguments The abi-encoded arguments of the function to be called.
   */
  function _enforceTimelock(
    bytes4 functionSelector,
    bytes memory arguments
  ) internal {
    // Get timelock ID using the supplied function arguments.
    bytes32 timelockID = keccak256(abi.encodePacked(arguments));

    // Get the current timelock, if any.
    uint256 currentTimelock = _timelocks[functionSelector][timelockID];

    // Ensure that the timelock is set and has completed.
    require(
      currentTimelock != 0 && currentTimelock <= now,
      "Function cannot be called until a timelock has been set and has expired."
    );

    // Clear out the existing timelock so that it cannot be reused.
    delete _timelocks[functionSelector][timelockID];
  }

  /**
   * @notice Private function for setting a new timelock interval for a given 
   * function selector.
   * @param functionSelector the selector of the function to set the timelock
   * interval for.
   * @param newTimelockInterval the new minimum timelock interval to set for the
   * given function.
   */
  function _setTimelockInterval(
    bytes4 functionSelector,
    uint256 newTimelockInterval
  ) private {
    // Get the existing timelock interval, if any.
    uint256 oldTimelockInterval = _timelockIntervals[functionSelector];
    
    // Update the timelock interval on the provided function.
    _timelockIntervals[functionSelector] = newTimelockInterval;

    // Emit a `TimelockIntervalModified` event with the appropriate arguments.
    emit TimelockIntervalModified(
      functionSelector, oldTimelockInterval, newTimelockInterval
    );
  }
}


/**
 * @title DharmaUpgradeBeaconControllerManager
 * @author 0age
 * @notice This contract will be owned by DharmaUpgradeMultisig and will manage
 * upgrades to the global smart wallet and key ring implementation contracts via
 * dedicated control over the "upgrade beacon" controller contracts (and can
 * additionally be used to manage other upgrade beacon controllers). It contains
 * a set of timelocked functions, where the `setTimelock` function must first be
 * called, with the same arguments that the function will be supplied with.
 * Then, a given time interval must first fully transpire before the timelock
 * functions can be successfully called.
 *
 * The timelocked functions currently implemented include:
 *  upgrade(address controller, address implementation)
 *  transferControllerOwnership(address controller, address newOwner)
 *  modifyTimelockInterval(bytes4 functionSelector, uint256 newTimelockInterval)
 *
 * It also specifies dedicated implementations for the Dharma Smart Wallet and
 * Dharma Key Ring upgrade beacons that can be triggered in an emergency or in
 * the event of an extended period of inactivity from Dharma. These contingency
 * implementations give the user the ability to withdraw any funds on their
 * smart wallet by submitting a transaction directly from the account of any of
 * their signing keys, but are otherwise kept as simple as possible.
 *
 * This contract can transfer ownership of any upgrade beacon controller it owns
 * (subject to the timelock on `transferControllerOwnership`), in order to
 * introduce new upgrade conditions or to otherwise alter the way that upgrades
 * are carried out.
 */
contract DharmaUpgradeBeaconControllerManager is Ownable, Timelocker {
  using SafeMath for uint256;

  // Fire an event whenever the Adharma Contingency is activated or exited.
  event AdharmaContingencyActivated(address controller, address beacon);
  event AdharmaContingencyExited(address controller, address beacon);

  // Store timestamp and last implementation in case of Adharma Contingency.
  // Note that this is specific to a particular controller and beacon.
  struct AdharmaContingency {
    bool armed;
    bool activated;
    uint256 activationTime;
  }

  // Store the last implementation address for each controller + beacon pair.
  mapping(address => mapping (address => address)) private _lastImplementation;

  // Store information on contingency status of each controller + beacon pair.
  mapping(address => mapping (address => AdharmaContingency)) private _adharma;

  // Track the last heartbeat timestamp as well as the current heartbeat address
  uint256 private _lastHeartbeat;
  address private _heartbeater;

  // Store the address of the Dharma Smart Wallet Upgrade Beacon as a constant.
  address private constant _DHARMA_SMART_WALLET_UPGRADE_BEACON = address(
    0x000000000026750c571ce882B17016557279ADaa
  );

  // Store the Adharma Smart Wallet Contingency implementation. Note that this
  // is specific to the smart wallet and will not be activated on other beacons.
  address private constant _ADHARMA_SMART_WALLET_IMPLEMENTATION = address(
    0x00000000Fde3b69fECd50C8A4c001678f00011ab
  );

  // Store the address of the Dharma Key Ring Upgrade Beacon as a constant.
  address private constant _DHARMA_KEY_RING_UPGRADE_BEACON = address(
    0x0000000000BDA2152794ac8c76B2dc86cbA57cad
  );

  // Store the Adharma Key Ring Contingency implementation. Note that this is
  // specific to the key ring and will not be activated on other beacons.
  address private constant _ADHARMA_KEY_RING_IMPLEMENTATION = address(
    0x00000000480003d5eE4F51134CE73Cc9AC00f693
  );

  /**
   * @notice In the constructor, set the initial owner of this contract, the
   * initial minimum timelock interval values, and some initial variable values.
   */
  constructor() public {
    // Ensure Adharma Smart Wallet implementation has the correct runtime code.
    bytes32 adharmaSmartWalletHash;
    bytes32 expectedAdharmaSmartWalletHash = bytes32(
      0x75889568a40bc5b3e7ccf3c6579a0730705f089c083e36c52bbc911024afa47f
    );
    address adharmaSmartWallet = _ADHARMA_SMART_WALLET_IMPLEMENTATION;
    assembly { adharmaSmartWalletHash := extcodehash(adharmaSmartWallet) }
    require(
      adharmaSmartWalletHash == expectedAdharmaSmartWalletHash,
      "Adharma Smart Wallet implementation runtime code hash is incorrect."
    );

    // Ensure Adharma Key Ring implementation has the correct runtime code.
    bytes32 adharmaKeyRingHash;
    bytes32 expectedAdharmaKeyRingHash = bytes32(
      0x72f85d929335f00aee7e110513479e43febf22b0ee7826ee4f8cfc767be6c001
    );
    address adharmaKeyRing = _ADHARMA_KEY_RING_IMPLEMENTATION;
    assembly { adharmaKeyRingHash := extcodehash(adharmaKeyRing) }
    require(
      adharmaKeyRingHash == expectedAdharmaKeyRingHash,
      "Adharma Key Ring implementation runtime code hash is incorrect."
    );

    // Set the transaction submitter as the initial owner of this contract.
    _transferOwnership(tx.origin);

    // Set initial minimum timelock interval values.
    _setInitialTimelockInterval(
      this.transferControllerOwnership.selector, 4 weeks
    );
    _setInitialTimelockInterval(this.modifyTimelockInterval.selector, 4 weeks);
    _setInitialTimelockInterval(this.upgrade.selector, 7 days);

    // Set the initial owner as the initial heartbeater.
    _heartbeater = tx.origin;
    _lastHeartbeat = now;
  }

  /**
   * @notice Sets a timelock so that the specified function can be called with
   * the specified arguments. Note that existing timelocks may be extended, but
   * not shortened - this can also be used as a method for "cancelling" an
   * upgrade by extending the timelock to an arbitrarily long duration. Keep in
   * mind that new timelocks may be created with a shorter duration on functions
   * that already have other timelocks on them, but only if they have different
   * arguments.
   * @param functionSelector selector of the function to be called.   
   * @param arguments The abi-encoded arguments of the function to be called -
   * in the case of `update`, it is the beacon address and the implementation
   * address, each encoded as left-padded 32-byte values.
   * @param extraTime Additional time in seconds to add to the timelock.
   */
  function setTimelock(
    bytes4 functionSelector,
    bytes calldata arguments,
    uint256 extraTime
  ) external onlyOwner {
    // Set the timelock and emit a `TimelockInitiated` event.
    _setTimelock(functionSelector, arguments, extraTime);
  }

  /**
   * @notice Timelocked function to set a new implementation address on an
   * upgrade beacon contract. This function could optionally check the
   * runtime code of the specified upgrade beacon, but that step is not strictly
   * necessary.
   * @param controller address of controller to call into that will trigger the
   * update to the specified upgrade beacon.
   * @param beacon address of upgrade beacon to set the new implementation on.
   * @param implementation the address of the new implementation.
   */
  function upgrade(
    address controller, address beacon, address implementation
  ) external onlyOwner {
    // Ensure that the timelock has been set and is completed.
    _enforceTimelock(
      this.upgrade.selector, abi.encode(controller, beacon, implementation)
    );
    
    // Reset the heartbeat to the current time.
    _lastHeartbeat = now;

    // Call controller with beacon to upgrade and implementation to upgrade to.
    _upgrade(controller, beacon, implementation);
  }

  /**
   * @notice Timelocked function to set a new owner on an upgrade beacon
   * controller that is owned by this contract.
   * @param controller address of controller to transfer ownership of.
   * @param newOwner address to assign ownership of the controller to.
   */
  function transferControllerOwnership(
    address controller,
    address newOwner
  ) external onlyOwner {
    // Ensure that the timelock has been set and is completed.
    _enforceTimelock(
      this.transferControllerOwnership.selector,
      abi.encode(controller, newOwner)
    );
    
    // Transfer ownership of the controller to the new owner.
    Ownable(controller).transferOwnership(newOwner);
  }

  /**
   * @notice Send a new heartbeat. If 90 days pass without a heartbeat, anyone
   * may trigger the Adharma Contingency and force an upgrade to any controlled
   * upgrade beacon.
   */
  function heartbeat() external {
    require(msg.sender == _heartbeater, "Must be called from the heartbeater.");
    _lastHeartbeat = now;
  }

  /**
   * @notice Set a new heartbeater.
   * @param heartbeater address to designate as the heartbeating address.
   */
  function newHeartbeater(address heartbeater) external onlyOwner {
    require(heartbeater != address(0), "Must specify a heartbeater address.");
    _heartbeater = heartbeater;
  }

  /**
   * @notice Arm the Adharma Contingency upgrade. This is required as an extra
   * safeguard against accidentally triggering the Adharma Contingency.
   * @param controller address of controller to arm.
   * @param beacon address of upgrade beacon to arm.
   * @param armed Boolean that signifies the desired armed status.
   */
  function armAdharmaContingency(
    address controller, address beacon, bool armed
  ) external {
    // Determine if 90 days have passed since the last heartbeat.
    (bool expired, ) = heartbeatStatus();
    require(
      isOwner() || expired,
      "Only callable by the owner or after 90 days without a heartbeat."
    );

    // Arm (or disarm) the Adharma Contingency.
    _adharma[controller][beacon].armed = armed;
  }

  /**
   * @notice Trigger the Adharma Contingency upgrade. This requires that the
   * owner first call `armAdharmaContingency` and set `armed` to `true`. This is
   * only to be invoked in cases of a time-sensitive emergency, or if the owner
   * has become inactive for over 90 days.
   * @param controller address of controller to call into that will trigger the
   * update to the Adharma contingency implementation on the specified upgrade
   * beacon.
   * @param beacon address of upgrade beacon to set the Adharma contingency
   * implementation on.
   */
  function activateAdharmaContingency(
    address controller,
    address beacon
  ) external {
    // Determine if 90 days have passed since the last heartbeat.
    (bool expired, ) = heartbeatStatus();
    require(
      isOwner() || expired,
      "Only callable by the owner or after 90 days without a heartbeat."
    );

    // Ensure that the Adharma Contingency has been armed.
    require(
      _adharma[controller][beacon].armed,
      "Adharma Contingency is not armed - are SURE you meant to call this?"
    );

    require(
      !_adharma[controller][beacon].activated,
      "Adharma Contingency is already activated on this controller + beacon."
    );

    // Mark the Adharma Contingency as having been activated.
    _adharma[controller][beacon] = AdharmaContingency({
      armed: false,
      activated: true,
      activationTime: now
    });

    // Trigger the upgrade to the correct Adharma implementation contract.
    if (beacon == _DHARMA_SMART_WALLET_UPGRADE_BEACON) {
      _upgrade(controller, beacon, _ADHARMA_SMART_WALLET_IMPLEMENTATION);
    } else if (beacon == _DHARMA_KEY_RING_UPGRADE_BEACON) {
      _upgrade(controller, beacon, _ADHARMA_KEY_RING_IMPLEMENTATION);
    } else {
      revert("Only the smart wallet or key ring contingency can be activated.");
    }

    // Emit an event to signal that the Adharma Contingency has been activated.
    emit AdharmaContingencyActivated(controller, beacon);
  }

  /**
   * @notice Roll back an upgrade to the last implementation and exit from
   * contingency status if one currently exists. Note that you can also roll
   * back a rollback to restore it back to the original implementation that was
   * just rolled back from.
   * @param controller address of controller to call into that will trigger the
   * rollback on the specified upgrade beacon.
   * @param beacon address of upgrade beacon to roll back to the last
   * implementation.
   */
  function rollback(address controller, address beacon) external onlyOwner {
    // Ensure that there is an implementation address to roll back to.
    require(
      _lastImplementation[controller][beacon] != address(0),
      "No prior implementation to roll back to."
    );

    // Exit the contingency state if there is currently one active.
    if (_adharma[controller][beacon].activated) {
      delete _adharma[controller][beacon];

      emit AdharmaContingencyExited(controller, beacon);
    }

    // Reset the heartbeat to the current time.
    _lastHeartbeat = now;

    // Upgrade to the last implementation contract.
    _upgrade(controller, beacon, _lastImplementation[controller][beacon]);
  }

  /**
   * @notice Exit the Adharma Contingency by upgrading to a new contract. This
   * requires that the contingency is currently activated and that at least 48
   * hours has elapsed since it was activated.
   * @param controller address of controller to call into that will trigger the
   * update to the Adharma contingency implementation on the specified upgrade
   * beacon.
   * @param beacon address of upgrade beacon to set the Adharma contingency
   * implementation on.
   * @param implementation the address of the new implementation.
   */
  function exitAdharmaContingency(
    address controller,
    address beacon,
    address implementation
  ) external onlyOwner {
    // Ensure that the Adharma Contingency is currently active.
    require(
      _adharma[controller][beacon].activated,
      "Adharma Contingency is not currently activated."
    );

    // Ensure that at least 48 hours has elapsed since the contingency commenced.
    require(
      now > _adharma[controller][beacon].activationTime + 48 hours,
      "Cannot exit contingency with a new upgrade until 48 hours have elapsed."
    );

    // Exit the contingency state.
    delete _adharma[controller][beacon];

    // Reset the heartbeat to the current time.
    _lastHeartbeat = now;

    // Call controller with beacon to upgrade and implementation to upgrade to.
    _upgrade(controller, beacon, implementation);

    // Emit an event to signal that the Adharma Contingency has been activated.
    emit AdharmaContingencyExited(controller, beacon);
  }

  /**
   * @notice Sets a new timelock interval for a given function selector. The
   * default for this function may also be modified, but has a maximum allowable
   * value of eight weeks.
   * @param functionSelector the selector of the function to set the timelock
   * interval for.
   * @param newTimelockInterval new minimum time interval for the new timelock.
   */
  function modifyTimelockInterval(
    bytes4 functionSelector,
    uint256 newTimelockInterval
  ) public onlyOwner {
    // Ensure that a function selector is specified (no 0x00000000 selector).
    require(
      functionSelector != bytes4(0),
      "Function selector cannot be empty."
    );

    // Ensure a timelock interval over eight weeks is not set on this function.
    if (functionSelector == this.modifyTimelockInterval.selector) {
      require(
        newTimelockInterval <= 8 weeks,
        "Timelock interval of modifyTimelockInterval cannot exceed eight weeks."
      );
    }

    // Continue via logic in the inherited `modifyTimelockInterval` function.
    Timelocker.modifyTimelockInterval(functionSelector, newTimelockInterval);
  }

  /**
   * @notice Determine if the deadman's switch has expired and get the time at
   * which it is set to expire (i.e. 90 days from the last heartbeat).
   */
  function heartbeatStatus() public view returns (
    bool expired,
    uint256 expirationTime
  ) {
    expirationTime = _lastHeartbeat + 90 days;
    expired = now > expirationTime;
  }

  /**
   * @notice Private function that sets a new implementation address on an
   * upgrade beacon contract.
   * @param controller address of controller to call into that will trigger the
   * update to the specified upgrade beacon.
   * @param beacon address of upgrade beacon to set the new implementation on.
   * @param implementation the address of the new implementation.
   */
  function _upgrade(
    address controller,
    address beacon,
    address implementation
  ) private {
    // Ensure that the implementaton contract is not the null address.
    require(
      implementation != address(0),
      "Implementation cannot be the null address."
    );

    // Ensure that the implementation contract has code via extcodesize.
    uint256 size;
    assembly {
      size := extcodesize(implementation)
    }
    require(size > 0, "Implementation must have contract code.");

    // Try to get current implementation contract, defaulting to null address.
    address currentImplementation;
    (bool ok, bytes memory returnData) = beacon.call("");
    if (ok && returnData.length == 32) {
      currentImplementation = abi.decode(returnData, (address));
    } else {
      currentImplementation = address(0);
    }

    // Record the last implementation in case it needs to be restored.
    _lastImplementation[controller][beacon] = currentImplementation;

    // Trigger the upgrade to the new implementation contract.
    UpgradeBeaconControllerInterface(controller).upgrade(
      beacon, implementation
    );
  }
}