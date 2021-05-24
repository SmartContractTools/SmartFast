pragma solidity ^0.5.8;

/**
 * @title ERC20 interface
 * @dev see https://github.com/ethereum/EIPs/issues/20
 */
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

/**
 * @title Helps contracts guard against reentrancy attacks.
 * @author Remco Bloemen <remco@2.com>, Eenae <alexey@mixbytes.io>
 * @dev If you mark a function `nonReentrant`, you should also
 * mark it `external`.
 */
contract ReentrancyGuard {
    /// @dev counter to allow mutex lock with only one SSTORE operation
    uint256 private _guardCounter;

    constructor() public {
        // The counter starts at one to prevent changing it from zero to a non-zero
        // value, which is a more expensive operation.
        _guardCounter = 1;
    }

    /**
     * @dev Prevents a contract from calling itself, directly or indirectly.
     * Calling a `nonReentrant` function from another `nonReentrant`
     * function is not supported. It is possible to prevent this from happening
     * by making the `nonReentrant` function external, and make it call a
     * `private` function that does the actual work.
     */
    modifier nonReentrant() {
        _guardCounter += 1;
        uint256 localCounter = _guardCounter;
        _;
        require(localCounter == _guardCounter);
    }
}

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

/// @title Main contract for WrappedNFT. This contract converts any NFT between the ERC721 standard and the
///  ERC20 standard by locking NFT's into the contract and minting 1:1 backed ERC20 tokens, that
///  can then be redeemed for NFTs's when desired.
/// @notice When wrapping an NFT, you get a generic WNFT token. Since the WNFT token is generic, it has no
///  no information about which specific NFT you submitted besides the originating NFT's contract address, so
///  you will most likely not receive the same NFT back when redeeming the token unless you specify that NFT's
///  ID, although you are guaranteed that it will be from the same NFT contract address. The token only entitles
///  you to receive *an* NFT from that NFT contract in return, not necessarily the *same* NFT in return. A
///  different user can submit their own WNFT tokens to the contract and withdraw the NFT that you originally
///  deposited. WNFT tokens have no information about which NFT was originally deposited to mint WNFT besides
///  which NFT contract it originated from - this is due to the very nature of the ERC20 standard being fungible,
///  and the ERC721 standard being nonfungible.
contract WrappedNFT is IERC20, ReentrancyGuard {

    // OpenZeppelin's SafeMath library is used for all arithmetic operations to avoid overflows/underflows.
    using SafeMath for uint256;

    /* ****** */
    /* EVENTS */
    /* ****** */

    /// @dev This event is fired when a user deposits an NFT into the contract in exchange
    ///  for an equal number of WNFT ERC20 tokens.
    /// @param nftId  The NFT id of the NFT that was deposited into the contract.
    event DepositNFTAndMintToken(
        uint256 nftId
    );

    /// @dev This event is fired when a user deposits WNFT ERC20 tokens into the contract in exchange
    ///  for an equal number of locked NFTs.
    /// @param nftId  The NF id of the NFT that was withdrawn from the contract.
    event BurnTokenAndWithdrawNFT(
        uint256 nftId
    );

    /* ******* */
    /* STORAGE */
    /* ******* */

    /// @dev An Array containing all of the NFTs that are locked in the contract, backing
    ///  WNFT ERC20 tokens 1:1
    /// @notice Some of the NFTs in this array were indeed deposited to the contract, but they
    ///  are no longer held by the contract. This is because burnTokensAndWithdrawNfts() allows a
    ///  user to withdraw an NFT "out of order". Since it would be prohibitively expensive to
    ///  shift the entire array once we've withdrawn a single element, we instead maintain the
    ///  mapping nftIsDepositedInContract to determine whether an element is still contained in
    ///  the contract or not.
    uint256[] private depositedNftsArray;

    /// @dev A mapping keeping track of which nftIDs are currently contained within the contract.
    /// @notice We cannot rely on depositedNftsArray as the source of truth as to which NFTs are
    ///  deposited in the contract. This is because burnTokensAndWithdrawNfts() allows a user to
    ///  withdraw an NFT "out of order" of the order that they are stored in the array. Since it
    ///  would be prohibitively expensive to shift the entire array once we've withdrawn a single
    ///  element, we instead maintain this mapping to determine whether an element is still contained
    ///  in the contract or not.
    mapping (uint256 => bool) public nftIsDepositedInContract;

    /* ********* */
    /* CONSTANTS */
    /* ********* */

    /// @dev The metadata details about the "Wrapped NFT" WNFT ERC20 token.
    uint8 constant public decimals = 18;
    string public name = 'Wrapped NFT';
    string public symbol = 'WNFT';

    /// @dev The address of official NFT contract that stores the metadata about each NFT.
    /// @notice The contract creator is not capable of changing the address of the NFTCore contract
    ///  once the contract has been deployed.
    address public nftCoreAddress;
    NFTCoreContract nftCore;

    /// @dev Addresses that begin as whitelisted in all WNFT contracts that are created
    ///  by this factory. The WNFT contracts begin with an allowance of UINT256_MAX for
    ///  these addresses for all users, but any user can subsequently override that
    ///  allowance if they wish.
    address public wyvernTokenTransferProxyAddress;
    address public wrappedNFTLiquidationProxyAddress;
    address public uniswapFactoryAddress;

    /* ********* */
    /* FUNCTIONS */
    /* ********* */

    /// @notice Allows a user to lock NFTs in the contract in exchange for an equal number
    ///  of WCK ERC20 tokens.
    /// @param _nftIds  The ids of the NFTs that will be locked into the contract.
    /// @notice If the NFT contract does not implement onERC721Received() or approveAll(), then the
    ///  user must first call approve() in the NFT's Core contract on each NFT that they wish to
    ///  deposit before calling depositNftsAndMintTokens(). If the contract implements approveAll() but
    ///  not onERC721Received, then the user simply needs to call approveAll() once for this contract.
    function depositNftsAndMintTokens(uint256[] calldata _nftIds) external nonReentrant {
        require(_nftIds.length > 0, 'you must submit an array with at least one element');
        for(uint i = 0; i < _nftIds.length; i++){
            uint256 nftToDeposit = _nftIds[i];
            require(msg.sender == nftCore.ownerOf(nftToDeposit), 'you do not own this NFT');
            nftCore.transferFrom(msg.sender, address(this), nftToDeposit);
            _pushNft(nftToDeposit);
            emit DepositNFTAndMintToken(nftToDeposit);
        }
        _mint(msg.sender, (_nftIds.length).mul(10**18));
    }

    /// @notice Allows a user to burn WNFT ERC20 tokens in exchange for an equal number of locked
    ///  NFTs.
    /// @param _nftIds  The IDs of the NFTs that the user wishes to withdraw. If the user submits 0
    ///  as the ID for any NFT, the contract uses the last NFT in the array for that NFT.
    /// @param _destinationAddresses  The addresses that the withdrawn NFTs will be sent to (this allows
    ///  anyone to "airdrop" NFTs to addresses that they do not own in a single transaction).
    function burnTokensAndWithdrawNfts(uint256[] calldata _nftIds, address[] calldata _destinationAddresses) external nonReentrant {
        require(_nftIds.length == _destinationAddresses.length, 'you did not provide a destination address for each of the NFTs you wish to withdraw');
        require(_nftIds.length > 0, 'you must submit an array with at least one element');

        uint256 numTokensToBurn = _nftIds.length;
        uint256 numTokensToBurnInWei = numTokensToBurn.mul(10**18);
        require(balanceOf(msg.sender) >= numTokensToBurnInWei, 'you do not own enough ERC20 tokens to withdraw this many NFTs');
        _burn(msg.sender, numTokensToBurnInWei);

        for(uint i = 0; i < numTokensToBurn; i++){
            uint256 nftToWithdraw = _nftIds[i];
            if(nftToWithdraw == 0){
                nftToWithdraw = _popNft();
            } else {
                require(nftIsDepositedInContract[nftToWithdraw] == true, 'this NFT has already been withdrawn');
                require(address(this) == nftCore.ownerOf(nftToWithdraw), 'the contract does not own this NFT');
                nftIsDepositedInContract[nftToWithdraw] = false;
            }
            nftCore.transferFrom(address(this), _destinationAddresses[i], nftToWithdraw);
            emit BurnTokenAndWithdrawNFT(nftToWithdraw);
        }
    }

    /// @notice Adds a locked NFT to the end of the array
    /// @param _nftId  The id of the NFT that will be locked into the contract.
    function _pushNft(uint256 _nftId) internal {
        depositedNftsArray.push(_nftId);
        nftIsDepositedInContract[_nftId] = true;
    }

    /// @notice Removes an unlocked NFT from the end of the array
    /// @notice The reason that this function must check if the nftIsDepositedInContract
    ///  is that the burnTokensAndWithdrawNfts() function allows a user to withdraw an NFT
    ///  from the array "out of order" of the order that they entered the array..
    /// @return  The id of the NFT that will be unlocked from the contract.
    function _popNft() internal returns(uint256){
        require(depositedNftsArray.length > 0, 'there are no NFTs in the array');
        uint256 nftId = depositedNftsArray[depositedNftsArray.length - 1];
        depositedNftsArray.length--;
        while(nftIsDepositedInContract[nftId] == false){
            nftId = depositedNftsArray[depositedNftsArray.length - 1];
            depositedNftsArray.length--;
        }
        nftIsDepositedInContract[nftId] = false;
        return nftId;
    }

    /// @notice Removes any NFTs that exist in the array but are no longer held in the
    ///  contract, which happens if the first few NFTs have previously been withdrawn
    ///  out of order using the burnTokensAndWithdrawNfts() function.
    /// @notice This function exists to prevent a griefing attack where a malicious attacker
    ///  could call burnTokensAndWithdrawNfts() on a large number of specific NFTs at the
    ///  front of the array, causing the while-loop in _popNft to always run out of gas.
    /// @notice It is unclear whether this griefing attack is even possible, because when a
    ///  user is forced to traverse the array, they delete an item at each step of walking the
    ///  array, so the repeated gas refunds may be sufficient to cover the repeated walking of
    ///  the array.
    /// @param _numSlotsToCheck  The number of slots to check in the array.
    function batchRemoveWithdrawnNFTsFromStorage(uint256 _numSlotsToCheck) external {
        require(_numSlotsToCheck <= depositedNftsArray.length, 'you are trying to batch remove more slots than exist in the array');
        uint256 arrayIndex = depositedNftsArray.length;
        for(uint i = 0; i < _numSlotsToCheck; i++){
            arrayIndex = arrayIndex.sub(1);
            uint256 nftId = depositedNftsArray[arrayIndex];
            if(nftIsDepositedInContract[nftId] == false){
                depositedNftsArray.length--;
            } else {
                return;
            }
        }
    }

    /// @dev If a user sends an NFT from nftCoreContract directly to this contract using a
    ///  transfer function that implements onERC721Received, then we can simply mint a token
    ///  for them here rather than having them call approve() and then have them call
    ///  depositNftsAndMintTokens().
    /// @notice The contract address is always the message sender.
    /// @param _operator The address which called `safeTransferFrom` function
    /// @param _from The address which previously owned the token
    /// @param _tokenId The NFT identifier which is being transferred
    /// @param _data Additional data with no specified format
    /// @return `bytes4(keccak256("onERC721Received(address,address,uint256,bytes)"))` to indicate that
    ///  this contract is written in such a way to be prepared to receive ERC721 tokens.
    function onERC721Received(address _operator, address _from, uint256 _tokenId, bytes calldata _data) external returns(bytes4) {
        require(msg.sender == nftCoreAddress, 'you can only mint tokens if the ERC721 token originates from nftCoreContract');
        _pushNft(_tokenId);
        _mint(_from, 10**18);
        emit DepositNFTAndMintToken(_tokenId);
        return bytes4(keccak256("onERC721Received(address,address,uint256,bytes)"));
    }

    /// @notice The contract creator is not capable of changing any of the hardcoded addresses
    ///  once the contract is deployed.
    /// @notice This contract whitelists three addresses (wyvernTokenTransferProxyAddress,
    ///  uniswapExchange, and wrappedNFTLiquidationProxyAddress) for easier UX for users using
    ///  OpenSea for the WNFTs. It accomplishes this by starting every user's account with an
    ///  allowance of UINT256_MAX for these three addresses. However, any user can subsequently
    ///  override this allowance if they wish by either calling approve() or calling
    ///  decreaseAllowance().
    constructor(address _nftCoreAddress, address _uniswapFactoryAddress, address _wyvernTokenTransferProxyAddress, address _wrappedNFTLiquidationProxyAddress) public {
        nftCore = NFTCoreContract(_nftCoreAddress);
        nftCoreAddress = _nftCoreAddress;

        // Modified _transfer() auto-adds max allowance to whitelisted addresses the first
        // time that someone receives WNFT tokens, but not again. Users can subsequently
        // revoke this approval by calling approve() or decreaseAllowance(). This is added
        // for easier UX for users using OpenSea for their WNFTs.
        wyvernTokenTransferProxyAddress = _wyvernTokenTransferProxyAddress;
        wrappedNFTLiquidationProxyAddress = _wrappedNFTLiquidationProxyAddress;
        uniswapFactoryAddress = _uniswapFactoryAddress;
    }

    /// @dev We revert on any payment to the fallback function, since any ether sent directly to
    ///  this contract would be lost forever.
    function() external payable {
        revert("This contract does not accept direct payments");
    }

    /* *********************************************** */
    /* ERC20_With_Whitelisted_Addresses Implementation */
    /* *********************************************** */

    mapping (address => uint256) private _balances;

    mapping (address => mapping (address => uint256)) private _allowed;

    uint256 private _totalSupply;

    mapping (address => bool) private _haveAddedAllowancesForWhitelistedAddresses;

    /**
    * @dev Total number of tokens in existence
    */
    function totalSupply() public view returns (uint256) {
        return _totalSupply;
    }

    /**
    * @dev Gets the balance of the specified address.
    * @param owner The address to query the balance of.
    * @return An uint256 representing the amount owned by the passed address.
    */
    function balanceOf(address owner) public view returns (uint256) {
        return _balances[owner];
    }

    /**
     * @dev Function to check the amount of tokens that an owner allowed to a spender.
     * @param owner address The address which owns the funds.
     * @param spender address The address which will spend the funds.
     * @return A uint256 specifying the amount of tokens still available for the spender.
     */
    function allowance(address owner, address spender) public view returns (uint256) {
        return _allowed[owner][spender];
    }

    /**
    * @dev Transfer token for a specified address
    * @param to The address to transfer to.
    * @param value The amount to be transferred.
    */
    function transfer(address to, uint256 value) public returns (bool) {
        _transfer(msg.sender, to, value);
        return true;
    }

    /**
     * @dev Approve the passed address to spend the specified amount of tokens on behalf of msg.sender.
     * Beware that changing an allowance with this method brings the risk that someone may use both the old
     * and the new allowance by unfortunate transaction ordering. One possible solution to mitigate this
     * race condition is to first reduce the spender's allowance to 0 and set the desired value afterwards:
     * https://github.com/ethereum/EIPs/issues/20#issuecomment-263524729
     * @param spender The address which will spend the funds.
     * @param value The amount of tokens to be spent.
     */
    function approve(address spender, uint256 value) public returns (bool) {
        require(spender != address(0));

        _allowed[msg.sender][spender] = value;
        emit Approval(msg.sender, spender, value);
        return true;
    }

    /**
     * @dev Transfer tokens from one address to another.
     * Note that while this function emits an Approval event, this is not required as per the specification,
     * and other compliant implementations may not emit the event.
     * @param from address The address which you want to send tokens from
     * @param to address The address which you want to transfer to
     * @param value uint256 the amount of tokens to be transferred
     */
    function transferFrom(address from, address to, uint256 value) public returns (bool) {
        _allowed[from][msg.sender] = _allowed[from][msg.sender].sub(value);
        _transfer(from, to, value);
        emit Approval(from, msg.sender, _allowed[from][msg.sender]);
        return true;
    }

    /**
     * @dev Increase the amount of tokens that an owner allowed to a spender.
     * approve should be called when allowed_[_spender] == 0. To increment
     * allowed value is better to use this function to avoid 2 calls (and wait until
     * the first transaction is mined)
     * From MonolithDAO Token.sol
     * Emits an Approval event.
     * @param spender The address which will spend the funds.
     * @param addedValue The amount of tokens to increase the allowance by.
     */
    function increaseAllowance(address spender, uint256 addedValue) public returns (bool) {
        require(spender != address(0));

        _allowed[msg.sender][spender] = _allowed[msg.sender][spender].add(addedValue);
        emit Approval(msg.sender, spender, _allowed[msg.sender][spender]);
        return true;
    }

    /**
     * @dev Decrease the amount of tokens that an owner allowed to a spender.
     * approve should be called when allowed_[_spender] == 0. To decrement
     * allowed value is better to use this function to avoid 2 calls (and wait until
     * the first transaction is mined)
     * From MonolithDAO Token.sol
     * Emits an Approval event.
     * @param spender The address which will spend the funds.
     * @param subtractedValue The amount of tokens to decrease the allowance by.
     */
    function decreaseAllowance(address spender, uint256 subtractedValue) public returns (bool) {
        require(spender != address(0));

        _allowed[msg.sender][spender] = _allowed[msg.sender][spender].sub(subtractedValue);
        emit Approval(msg.sender, spender, _allowed[msg.sender][spender]);
        return true;
    }

    // Modified _transfer() and _mint() auto-adds max allowance to whitelisted addresses the first
    // time that someone receives WNFT tokens, but not again. Users can subsequently
    // revoke this approval by calling approve() or decreaseAllowance(). This is added
    // for easier UX for users using OpenSea for their WNFTs.
    function _addMaxAllowanceToWhitelistedAddressesIfFirstTimeReceivingToken(address to, uint256 value) private {
        if(_haveAddedAllowancesForWhitelistedAddresses[to] == false){
            if(uniswapFactoryAddress != address(0)){
                address uniswapExchangeAddress = UniswapFactory(uniswapFactoryAddress).getExchange(address(this));
                if(uniswapExchangeAddress != address(0)){
                    _allowed[to][uniswapExchangeAddress] = ~uint256(0);
                }
            }
            if(wyvernTokenTransferProxyAddress != address(0)){
                _allowed[to][wyvernTokenTransferProxyAddress] = ~uint256(0);
            }
            if(wrappedNFTLiquidationProxyAddress != address(0)){
                _allowed[to][wrappedNFTLiquidationProxyAddress] = ~uint256(0);
            }
            _haveAddedAllowancesForWhitelistedAddresses[to] = true;
        }
    }

    /// @notice The _trasfer() and _mint() functions are modified to set max allowance for whitelisted
    ///  addresses the first time that a user receives any WNFT tokens. They can subsequently
    ///  revoke this approval by calling approve() or decreaseAllowance(), and the contract
    ///  will not auto-add the whitelisted contract's allowance again. This is added
    ///  for easier UX for users using OpenSea for their WNFTs.
    /**
    * @dev Transfer token for a specified addresses
    * @param from The address to transfer from.
    * @param to The address to transfer to.
    * @param value The amount to be transferred.
    */
    function _transfer(address from, address to, uint256 value) internal {
        require(to != address(0));

        // Modified _transfer() and _mint() auto-adds max allowance to whitelisted addresses the first
        // time that someone receives WNFT tokens, but not again. Users can subsequently
        // revoke this approval by calling approve() or decreaseAllowance(). This is added
        // for easier UX for users using OpenSea for their WNFTs.
        _addMaxAllowanceToWhitelistedAddressesIfFirstTimeReceivingToken(to, value);

        _balances[from] = _balances[from].sub(value);
        _balances[to] = _balances[to].add(value);
        emit Transfer(from, to, value);
    }

    /// @notice The _trasfer() and _mint() functions are modified to set max allowance for whitelisted
    ///  addresses the first time that a user receives any WNFT tokens. They can subsequently
    ///  revoke this approval by calling approve() or decreaseAllowance(), and the contract
    ///  will not auto-add the whitelisted contract's allowance again. This is added
    ///  for easier UX for users using OpenSea for their WNFTs.
    /**
     * @dev Internal function that mints an amount of the token and assigns it to
     * an account. This encapsulates the modification of balances such that the
     * proper events are emitted.
     * @param account The account that will receive the created tokens.
     * @param value The amount that will be created.
     */
    function _mint(address account, uint256 value) internal {
        require(account != address(0));

        // Modified _transfer() and _mint() auto-adds max allowance to whitelisted addresses the first
        // time that someone receives WNFT tokens, but not again. Users can subsequently
        // revoke this approval by calling approve() or decreaseAllowance(). This is added
        // for easier UX for users using OpenSea for their WNFTs.
        _addMaxAllowanceToWhitelistedAddressesIfFirstTimeReceivingToken(account, value);

        _totalSupply = _totalSupply.add(value);
        _balances[account] = _balances[account].add(value);
        emit Transfer(address(0), account, value);
    }

    /**
     * @dev Internal function that burns an amount of the token of a given
     * account.
     * @param account The account whose tokens will be burnt.
     * @param value The amount that will be burnt.
     */
    function _burn(address account, uint256 value) internal {
        require(account != address(0));

        _totalSupply = _totalSupply.sub(value);
        _balances[account] = _balances[account].sub(value);
        emit Transfer(account, address(0), value);
    }

    /**
     * @dev Internal function that burns an amount of the token of a given
     * account, deducting from the sender's allowance for said account. Uses the
     * internal burn function.
     * Emits an Approval event (reflecting the reduced allowance).
     * @param account The account whose tokens will be burnt.
     * @param value The amount that will be burnt.
     */
    function _burnFrom(address account, uint256 value) internal {
        _allowed[account][msg.sender] = _allowed[account][msg.sender].sub(value);
        _burn(account, value);
        emit Approval(account, msg.sender, _allowed[account][msg.sender]);
    }
}

/// @title Interface for interacting with the NFT Core contract
contract NFTCoreContract {
    function ownerOf(uint256 _tokenId) public view returns (address owner);
    function transferFrom(address _from, address _to, uint256 _tokenId) external;
    function transfer(address _to, uint256 _tokenId) external;
    function approve(address _to, uint256 _tokenId) external;
}

/// @title Interface for interacting with the UniswapFactory contract
contract UniswapFactory {
    function getExchange(address token) external view returns (address exchange);
    function getToken(address exchange) external view returns (address token);
}

/**
 * @title Ownable
 * @dev The Ownable contract has an owner address, and provides basic authorization control
 * functions, this simplifies the implementation of "user permissions".
 */
contract Ownable {
    address private _owner;

    event OwnershipTransferred(address previousOwner, address newOwner);

    /**
     * @dev The Ownable constructor sets the original `owner` of the contract to the sender
     * account.
     */
    constructor () internal {
        _owner = msg.sender;
        emit OwnershipTransferred(address(0), _owner);
    }

    /**
     * @return the address of the owner.
     */
    function owner() public view returns (address) {
        return _owner;
    }

    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        require(isOwner());
        _;
    }

    /**
     * @return true if `msg.sender` is the owner of the contract.
     */
    function isOwner() public view returns (bool) {
        return msg.sender == _owner;
    }

    /**
     * @dev Allows the current owner to relinquish control of the contract.
     * @notice Renouncing to ownership will leave the contract without an owner.
     * It will not be possible to call the functions with the `onlyOwner`
     * modifier anymore.
     */
    function renounceOwnership() public onlyOwner {
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }

    /**
     * @dev Allows the current owner to transfer control of the contract to a newOwner.
     * @param newOwner The address to transfer ownership to.
     */
    function transferOwnership(address newOwner) public onlyOwner {
        _transferOwnership(newOwner);
    }

    /**
     * @dev Transfers control of the contract to a newOwner.
     * @param newOwner The address to transfer ownership to.
     */
    function _transferOwnership(address newOwner) internal {
        require(newOwner != address(0));
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}

/// @title Main contract for WrappedNFTFactory. This contract creates a WrappedNFT contract
///  for any NFT contract. The WrappedNFT contract then allows for the conversion of an NFT
///  Contrat's tokens from the ERC721 standard to the ERC20 standard by locking NFT's into
///  the WrappedNFT contract and minting 1:1 backed ERC20 tokens, that can then be redeemed
///  for NFTs's when desired.
/// Cite: Factory design inspired by the Uniswap Factory contract at
///  0xc0a47dfe034b400b47bdad5fecda2621de6c4d95
contract WrappedNFTFactory is Ownable {

    /* ****** */
    /* EVENTS */
    /* ****** */

    /// @dev This event is fired when a user creates a new NFTWrapperContract using this
    ///  factory contract.
    /// @param nftContract The address of the NFT contract that the new wrapperContract
    ///  is being made for.
    /// @param wrapperContract The address of the newly created wrapperContract
    event NewWrapperContractCreated(
        address nftContract,
        address wrapperContract
    );

    /* ******* */
    /* STORAGE */
    /* ******* */

    /// @dev The number of wrapperContracts that have been created from this factory
    uint256 public wrapperContractsCreated = 0;

    /// @dev A mapping from the core NFT contract to its corresponding wrapperContract
    ///  that was created from this factory.
    mapping (address => address) public nftContractToWrapperContract;

    /// @dev A mapping from the wrapperContract that was created from this factory to
    ///  the core NFT contract.
    mapping (address => address) public wrapperContractToNftContract;

    /// @dev An iterable mapping sequentially cataloguing each of the wrapperContracts
    ///  that have been created from this factory. The keys run from 0 to the current
    ///  value of wrapperContractsCreated minus 1, and the values are the addresses of
    ///  the core NFT contracts.
    mapping (uint256 => address) public idToNftContract;

    /// @dev Addresses that begin as whitelisted in all WNFT contracts that are created
    ///  by this factory. The WNFT contracts begin with an allowance of UINT256_MAX for
    ///  these addresses for all users, but any user can subsequently override that
    ///  allowance if they wish.
    address public uniswapFactoryAddress;
    address public wyvernTokenTransferProxyAddress;
    address public wrappedNFTLiquidationProxyAddress;

    /* ********* */
    /* FUNCTIONS */
    /* ********* */

    /// @dev Creates a new WrapperNFTContract for the specified NFTCoreContract address,
    ///  throws if one already exists for that address.
    /// @param _nftContractAddress  The address of the NFT contract that the new
    ///  wrapperContract is being made for.
    function createWrapperContract(address _nftContractAddress) external {
        require(nftContractToWrapperContract[_nftContractAddress] == address(0), 'a wrapper contract already exists for this nft');
        address wrapperContractAddress = address(new WrappedNFT(_nftContractAddress, uniswapFactoryAddress, wyvernTokenTransferProxyAddress, wrappedNFTLiquidationProxyAddress));
        _addMapping(_nftContractAddress, wrapperContractAddress);
        emit NewWrapperContractCreated(_nftContractAddress, wrapperContractAddress);
    }

    /// @dev If deploying a new WNFTFactory contract, this function allows the owner to
    ///  retrieve the addresses of the successfully deployed WNFT contracts from the
    ///  previous factory's storage
    /// @param _startIndex The start index within the previous factory's iterable list of
    ///  WNFT contracts that have been deployed
    /// @param _endIndex  The end index within the previous factory's iterable list of
    ///  WNFT contracts that have been deployed
    /// @param _previousFactoryAddress  The address of the previous WNFT Factory
    function importMappingsFromPreviousFactory(uint256 _startIndex, uint256 _endIndex, address _previousFactoryAddress) external onlyOwner {
        for(uint i = _startIndex; i <= _endIndex; i++){
            address nftContractAddress = WrappedNFTFactory(_previousFactoryAddress).idToNftContract(i);
            address wrapperContractAddress = WrappedNFTFactory(_previousFactoryAddress).nftContractToWrapperContract(nftContractAddress);
            require(nftContractToWrapperContract[nftContractAddress] == address(0), 'a wrapper contract already exists for this nft');
            _addMapping(nftContractAddress, wrapperContractAddress);
        }
    }

    /// @dev Allows the owner to updates the address for the UniswapFactory contract,
    ///  which begins as whitelisted in all WNFT contracts that are created from this
    ///  factory, although users can subsequently revoke the whitelisting if they wish.
    /// @param _newUniswapFactoryAddress The address of the uniswapFactory contract.
    function updateUniswapFactoryContractAddress(address _newUniswapFactoryAddress) external onlyOwner {
        uniswapFactoryAddress = _newUniswapFactoryAddress;
    }

    /// @dev Allows the owner to updates the address for the WyvernTokenTransferProxyAddress
    ///  contract, which begins as whitelisted in all WNFT contracts that are created from
    ///  this factory, although users can subsequently revoke the whitelisting if they wish.
    /// @param _newWyvernTokenTransferProxyAddress The address of the WyvernTokenTransferProxyAddress
    ///  contract.
    function updateWyvernTokenTransferProxyAddress(address _newWyvernTokenTransferProxyAddress) external onlyOwner {
        wyvernTokenTransferProxyAddress = _newWyvernTokenTransferProxyAddress;
    }

    /// @dev Allows the owner to update the address for the WrappedNFTLiquidationProxyAddress
    ///  contract, which begins as whitelisted in all WNFT contracts that are created from
    ///  this factory, although users can subsequently revoke the whitelisting if they wish.
    /// @param _newWrappedNFTLiquidationProxyAddress The address of the WrappedNFTLiquidationProxyAddress
    ///  contract.
    function updateWrappedNFTLiquidationProxyAddress(address _newWrappedNFTLiquidationProxyAddress) external onlyOwner {
        wrappedNFTLiquidationProxyAddress = _newWrappedNFTLiquidationProxyAddress;
    }

    /// @notice Due to a bug in the Solidity compiler, we must create getter functions for
    ///  public variables when we wish to call those getter functions from an interface in
    ///  another contract. Normally we could simply rely on the automatic getter function
    ///  that is created for all public variables.
    /// @dev Manually created getter function for nftContractToWrapperContract, needed due
    ///  to Soldiity compiler bug.
    /// @param _nftContractAddress  The address of the NFT contract that the new
    ///  wrapperContract is made for.
    /// @return The address of the corresponding wrapperContract for this NFT Contract
    function getWrapperContractForNFTContractAddress(address _nftContractAddress) external view returns (address){
        return nftContractToWrapperContract[_nftContractAddress];
    }

    constructor(address _uniswapFactoryAddress, address _wyvernTokenTransferProxyAddress) public {
        // We initialize both the UniswapFactory address and the WyvernTokenTransferProxyAddress
        // so that any WNFT contracts that are created by this factory whitelist these two addresses.
        // Users can subsequently revoke these permissions if they wish. This is added for easier
        // UX for users using OpenSea for their WNFTs.
        uniswapFactoryAddress = _uniswapFactoryAddress; // Currently on mainnet at: 0xc0a47dFe034B400B47bDaD5FecDa2621de6c4d95
        wyvernTokenTransferProxyAddress = _wyvernTokenTransferProxyAddress; // Currenlty on mainnet at: 0xE5c783EE536cf5E63E792988335c4255169be4E1
        ///  We initialize the CryptoKitties WrappedNFTContract in the constructor,
        ///  since a heavily used WrappedNFTContract already exists on-chain for
        ///  CryptoKitties, and we want to make use of its liquidity rather than initailizing
        ///  a new, empty WrapperNFTContract for CryptoKitties.
        _addMapping(0x06012c8cf97BEaD5deAe237070F9587f8E7A266d, 0x09fE5f0236F0Ea5D930197DCE254d77B04128075);
    }

    /* ****************** */
    /* INTERNAL FUNCTIONS */
    /* ****************** */

    /// @dev Creates mappings between the given nft core address and wrapper contract
    ///  address.
    /// @param _nftContractAddress  The address of the NFT contract that the new
    ///  wrapperContract is made for.
    /// @param _wrapperContractAddress  The address of the new wrapper contract
    function _addMapping(address _nftContractAddress, address _wrapperContractAddress) internal {
        nftContractToWrapperContract[_nftContractAddress] = _wrapperContractAddress;
        wrapperContractToNftContract[_wrapperContractAddress] = _nftContractAddress;
        idToNftContract[wrapperContractsCreated] = _nftContractAddress;
        wrapperContractsCreated++;
    }
}