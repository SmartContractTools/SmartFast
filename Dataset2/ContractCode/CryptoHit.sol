/**
 * CryptoHit
 */

pragma solidity ^0.5.11;

contract CryptoHit {
  address public creator;
  uint public currentUserID;

  mapping (uint => uint) public levelPrice;
  mapping (address => User) public users;
  mapping (uint => address) public userAddresses;

  uint MAX_LEVEL = 4;
  uint REFERRALS_LIMIT = 2;
  uint LEVEL_DURATION = 35 days;

  struct User {
    uint id;
    uint referrerID;
    address[] referrals;
    mapping (uint => uint) levelExpiresAt;
  }

  event RegisterUserEvent(address indexed user, address indexed referrer, uint time);
  event BuyLevelEvent(address indexed user, uint indexed level, uint time);
  event GetLevelProfitEvent(address indexed user, address indexed referral, uint indexed level, uint time);
  event LostLevelProfitEvent(address indexed user, address indexed referral, uint indexed level, uint time);

  modifier userNotRegistered() {
    require(users[msg.sender].id == 0, 'User is already registered');
    _;
  }

  modifier userRegistered() {
    require(users[msg.sender].id != 0, 'User does not exist');
    _;
  }

  modifier validReferrerID(uint _referrerID) {
    require(_referrerID > 0 && _referrerID <= currentUserID, 'Invalid referrer ID');
    _;
  }

  modifier validLevel(uint _level) {
    require(_level > 0 && _level <= MAX_LEVEL, 'Invalid level');
    _;
  }

  modifier validLevelAmount(uint _level) {
    require(msg.value == levelPrice[_level], 'Invalid level amount');
    _;
  }

  constructor() public {
    levelPrice[1] = 0.1 ether;
    levelPrice[2] = 0.15 ether;
    levelPrice[3] = 0.3 ether;
    levelPrice[4] = 0.5 ether;

    currentUserID++;

    creator = msg.sender;

    users[creator] = createNewUser(0);
    userAddresses[currentUserID] = creator;

    for (uint i = 1; i <= MAX_LEVEL; i++) {
      users[creator].levelExpiresAt[i] = 1 << 37;
    }
  }

  function () external payable {
    uint level;

    for (uint i = 1; i <= MAX_LEVEL; i++) {
      if (msg.value == levelPrice[i]) {
        level = i;
        break;
      }
    }

    require(level > 0, 'Invalid amount has sent');

    if (users[msg.sender].id != 0) {
      buyLevel(level);
      return;
    }

    if (level != 1) {
      revert('Buy first level for 0.1 ETH');
    }

    address referrer = bytesToAddress(msg.data);
    registerUser(users[referrer].id);
  }

  function registerUser(uint _referrerID) public payable userNotRegistered() validReferrerID(_referrerID) validLevelAmount(1) {
    if (users[userAddresses[_referrerID]].referrals.length >= REFERRALS_LIMIT) {
      _referrerID = users[findReferrer(userAddresses[_referrerID])].id;
    }

    currentUserID++;

    users[msg.sender] = createNewUser(_referrerID);
    userAddresses[currentUserID] = msg.sender;
    users[msg.sender].levelExpiresAt[1] = now + LEVEL_DURATION;

    users[userAddresses[_referrerID]].referrals.push(msg.sender);

    transferLevelPayment(1, msg.sender, 1);
    emit RegisterUserEvent(msg.sender, userAddresses[_referrerID], now);
  }

  function buyLevel(uint _level) public payable userRegistered() validLevel(_level) validLevelAmount(_level) {
    for (uint l = _level - 1; l > 0; l--) {
      require(getUserLevelExpiresAt(msg.sender, l) >= now, 'Buy the previous level');
    }

    if (getUserLevelExpiresAt(msg.sender, _level) == 0 || getUserLevelExpiresAt(msg.sender, _level) < now) {
      users[msg.sender].levelExpiresAt[_level] = now + LEVEL_DURATION;
    } else {
      users[msg.sender].levelExpiresAt[_level] += LEVEL_DURATION;
    }

    transferLevelPayment(_level, msg.sender, _level);
    emit BuyLevelEvent(msg.sender, _level, now);
  }

  function findReferrer(address _user) public view returns (address) {
    if (users[_user].referrals.length < REFERRALS_LIMIT) {
      return _user;
    }

    address[1024] memory referrals;
    referrals[0] = users[_user].referrals[0];
    referrals[1] = users[_user].referrals[1];

    address referrer;

    for (uint i = 0; i < 1024; i++) {
      if (users[referrals[i]].referrals.length < REFERRALS_LIMIT) {
        referrer = referrals[i];
        break;
      }

      if (i >= 512) {
        continue;
      }

      referrals[(i+1)*2] = users[referrals[i]].referrals[0];
      referrals[(i+1)*2+1] = users[referrals[i]].referrals[1];
    }

    require(referrer != address(0), 'Referrer was not found');

    return referrer;
  }

  function transferLevelPayment(uint _level, address _user, uint height) internal {
    address referrer = getUserUpline(_user, height);

    if (referrer == address(0)) {
      referrer = creator;
    }

    if (getUserLevelExpiresAt(referrer, _level) < now) {
      emit LostLevelProfitEvent(referrer, msg.sender, _level, now);
      transferLevelPayment(_level, referrer, 1);
      return;
    }

    if (addressToPayable(referrer).send(msg.value)) {
      emit GetLevelProfitEvent(referrer, msg.sender, _level, now);
    }
  }


  function getUserUpline(address _user, uint height) public view returns (address) {
    if (height <= 0 || _user == address(0)) {
      return _user;
    }

    return this.getUserUpline(userAddresses[users[_user].referrerID], height - 1);
  }

  function getUserReferrals(address _user) public view returns (address[] memory) {
    return users[_user].referrals;
  }

  function getUserLevelExpiresAt(address _user, uint _level) public view returns (uint) {
    return users[_user].levelExpiresAt[_level];
  }


  function createNewUser(uint _referrerID) private view returns (User memory) {
    return User({ id: currentUserID, referrerID: _referrerID, referrals: new address[](0) });
  }

  function bytesToAddress(bytes memory _addr) private pure returns (address addr) {
    assembly {
      addr := mload(add(_addr, 20))
    }
  }

  function addressToPayable(address _addr) private pure returns (address payable) {
    return address(uint160(_addr));
  }
}