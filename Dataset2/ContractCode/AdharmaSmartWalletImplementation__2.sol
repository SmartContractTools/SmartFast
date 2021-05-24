pragma solidity 0.5.11; // optimization runs: 200, evm: petersburg


/**
 * @title AdharmaSmartWalletImplementation
 * @author 0age
 * @notice The Adharma Smart Wallet is an emergency smart wallet implementation
 * that can be immediately upgraded to by the Upgrade Beacon Controller Manager
 * in the event of a critical-severity exploit, or after a 90-day period of
 * inactivity by Dharma. It gives the user direct, sole custody and control over
 * their smart wallet until the Upgrade Beacon Controller Manager issues another
 * upgrade to the implementation contract. Note that meta-transactions are not
 * supported on this implementation - calls must originate from the account
 * itself.
 */
contract AdharmaSmartWalletImplementation {
  // The user's key is still held in storage slot zero.
  address private _key;

  // The smart wallet can still receive funds, though it is inadvisable.
  function () external payable {}

  // Keep the initializer function on the contract in case a smart wallet has
  // not yet been deployed but the account still contains user funds.
  function initialize(address key) external {
    // Ensure that this function is only callable during contract construction.
    assembly { if extcodesize(address) { revert(0, 0) } }

    // Set up the user's key.
    _key = key;
  }

  // The key's owner has sole authority to make calls from the smart wallet.
  function performCall(
    address payable to,
    uint256 amount,
    bytes calldata data
  ) external payable returns (
    bool ok,
    bytes memory returnData
  ) {
    require(msg.sender == _key, "Caller prohibited.");
    (ok, returnData) = to.call.value(amount)(data);
    require(ok, string(returnData));
  }
}