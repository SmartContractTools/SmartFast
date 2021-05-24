pragma solidity ^0.4.25;

/*******************************************************************************
 *
 * Copyright (c) 2019 Decentralization Authority MDAO.
 * Released under the MIT License.
 *
 * Minado - Crypto Token Mining & Forging Community
 * 
 *          Minado has been optimized for mining ERC918-compatible tokens via
 *          the InfinityPool; a public storage of mineable ERC-20 tokens.
 * 
 *          Learn more below:
 * 
 *          Official : https://minado.network
 *          Ethereum : https://eips.ethereum.org/EIPS/eip-918
 *          Github   : https://github.com/ethereum/EIPs/pull/918
 *          Reddit   : https://www.reddit.com/r/Tokenmining
 * 
 * Version 19.7.18
 *
 * Web    : https://d14na.org
 * Email  : support@d14na.org
 */


/*******************************************************************************
 *
 * SafeMath
 */
library SafeMath {
    function add(uint a, uint b) internal pure returns (uint c) {
        c = a + b;
        require(c >= a);
    }
    function sub(uint a, uint b) internal pure returns (uint c) {
        require(b <= a);
        c = a - b;
    }
    function mul(uint a, uint b) internal pure returns (uint c) {
        c = a * b;
        require(a == 0 || c / a == b);
    }
    function div(uint a, uint b) internal pure returns (uint c) {
        require(b > 0);
        c = a / b;
    }
}


/*******************************************************************************
 *
 * ECRecovery
 *
 * Contract function to validate signature of pre-approved token transfers.
 * (borrowed from LavaWallet)
 */
contract ECRecovery {
    function recover(bytes32 hash, bytes sig) public pure returns (address);
}


/*******************************************************************************
 *
 * Owned contract
 */
contract Owned {
    address public owner;
    address public newOwner;

    event OwnershipTransferred(address indexed _from, address indexed _to);

    constructor() public {
        owner = msg.sender;
    }

    modifier onlyOwner {
        require(msg.sender == owner);
        _;
    }

    function transferOwnership(address _newOwner) public onlyOwner {
        newOwner = _newOwner;
    }

    function acceptOwnership() public {
        require(msg.sender == newOwner);

        emit OwnershipTransferred(owner, newOwner);

        owner = newOwner;

        newOwner = address(0);
    }
}


/*******************************************************************************
 * 
 * Zer0netDb Interface
 */
contract Zer0netDbInterface {
    /* Interface getters. */
    function getAddress(bytes32 _key) external view returns (address);
    function getBool(bytes32 _key)    external view returns (bool);
    function getBytes(bytes32 _key)   external view returns (bytes);
    function getInt(bytes32 _key)     external view returns (int);
    function getString(bytes32 _key)  external view returns (string);
    function getUint(bytes32 _key)    external view returns (uint);

    /* Interface setters. */
    function setAddress(bytes32 _key, address _value) external;
    function setBool(bytes32 _key, bool _value) external;
    function setBytes(bytes32 _key, bytes _value) external;
    function setInt(bytes32 _key, int _value) external;
    function setString(bytes32 _key, string _value) external;
    function setUint(bytes32 _key, uint _value) external;

    /* Interface deletes. */
    function deleteAddress(bytes32 _key) external;
    function deleteBool(bytes32 _key) external;
    function deleteBytes(bytes32 _key) external;
    function deleteInt(bytes32 _key) external;
    function deleteString(bytes32 _key) external;
    function deleteUint(bytes32 _key) external;
}


/*******************************************************************************
 *
 * ERC Token Standard #20 Interface
 * https://github.com/ethereum/EIPs/blob/master/EIPS/eip-20-token-standard.md
 */
contract ERC20Interface {
    function totalSupply() public constant returns (uint);
    function balanceOf(address tokenOwner) public constant returns (uint balance);
    function allowance(address tokenOwner, address spender) public constant returns (uint remaining);
    function transfer(address to, uint tokens) public returns (bool success);
    function approve(address spender, uint tokens) public returns (bool success);
    function transferFrom(address from, address to, uint tokens) public returns (bool success);

    event Transfer(address indexed from, address indexed to, uint tokens);
    event Approval(address indexed tokenOwner, address indexed spender, uint tokens);
}


/*******************************************************************************
 *
 * InfinityPool Interface
 */
contract InfinityPoolInterface {
    function transfer(address _token, address _to, uint _tokens) external returns (bool success);
}


/*******************************************************************************
 *
 * InfinityWell Interface
 */
contract InfinityWellInterface {
    function forgeStones(address _owner, uint _tokens) external returns (bool success);
    function destroyStones(address _owner, uint _tokens) external returns (bool success);
    function transferERC20(address _token, address _to, uint _tokens) external returns (bool success);
    function transferERC721(address _token, address _to, uint256 _tokenId) external returns (bool success);
}


/*******************************************************************************
 *
 * Staek(house) Factory Interface
 */
contract StaekFactoryInterface {
    function balanceOf(bytes32 _staekhouseId) public view returns (uint balance);
    function balanceOf(bytes32 _staekhouseId, address _owner) public view returns (uint balance);
    function getStaekhouse(bytes32 _staekhouseId, address _staeker) external view returns (address factory, address token, address owner, uint ownerLockTime, uint providerLockTime, uint debtLimit, uint lockInterval, uint balance);
}


/*******************************************************************************
 *
 * @notice Minado - Token Mining Contract
 *
 * @dev This is a multi-token mining contract, which manages the proof-of-work
 *      verifications before authorizing the movement of tokens from the
 *      InfinityPool and InfinityWell.
 */
contract Minado is Owned {
    using SafeMath for uint;

    /* Initialize predecessor contract. */
    address private _predecessor;

    /* Initialize successor contract. */
    address private _successor;
    
    /* Initialize revision number. */
    uint private _revision;

    /* Initialize Zer0net Db contract. */
    Zer0netDbInterface private _zer0netDb;

    /**
     * Set Namespace
     * 
     * Provides a "unique" name for generating "unique" data identifiers,
     * most commonly used as database "key-value" keys.
     * 
     * NOTE: Use of `namespace` is REQUIRED when generating ANY & ALL
     *       Zer0netDb keys; in order to prevent ANY accidental or
     *       malicious SQL-injection vulnerabilities / attacks.
     */
    string private _namespace = 'minado';

    /**
     * Large Target
     * 
     * A big number used for difficulty targeting.
     * 
     * NOTE: Bitcoin uses `2**224`.
     */
    uint private _MAXIMUM_TARGET = 2**234;

    /**
     * Minimum Targets
     * 
     * Minimum number used for difficulty targeting.
     */
    uint private _MINIMUM_TARGET = 2**16;

    /**
     * Set basis-point multiplier.
     * 
     * NOTE: Used for (integer-based) fractional calculations.
     */
    uint private _BP_MUL = 10000;

    /* Set InfinityStone decimals. */
    uint private _STONE_DECIMALS = 18;

    /* Set single InfinityStone. */
    uint private _SINGLE_STONE = 1 * 10**_STONE_DECIMALS;
    
    /**
     * (Ethereum) Blocks Per Forge
     * 
     * NOTE: Ethereum blocks take approx 15 seconds each.
     *       1,000 blocks takes approx 4 hours.
     */
    uint private _BLOCKS_PER_STONE_FORGE = 1000;

    /**
     * (Ethereum) Blocks Per Generation
     * 
     * NOTE: We mirror the Bitcoin POW mining algorithm. 
     *       We want miners to spend 10 minutes to mine each 'block'.
     *       (about 40 Ethereum blocks for every 1 Bitcoin block)
     */
    uint BLOCKS_PER_GENERATION = 40; // Mainnet & Ropsten
    // uint BLOCKS_PER_GENERATION = 120; // Kovan

    /**
     * (Mint) Generations Per Re-adjustment
     * 
     * By default, we automatically trigger a difficulty adjustment
     * after 144 generations / mints (approx 24 hours). 
     * 
     * Frequent adjustments are especially important with low-liquidity 
     * tokens, which are more susceptible to mining manipulation.
     * 
     * For additional control, token providers retain the ability to trigger 
     * a difficulty re-calculation at any time.
     * 
     * NOTE: Bitcoin re-adjusts its difficulty every 2,016 generations,
     *       which occurs approx. every 14 days.
     */
    uint private _DEFAULT_GENERATIONS_PER_ADJUSTMENT = 144; // approx. 24hrs

    event Claim(
        address owner, 
        address token, 
        uint amount,
        address collectible,
        uint collectibleId
    );

    event Excavate(
        address indexed token, 
        address indexed miner, 
        uint mintAmount, 
        uint epochCount, 
        bytes32 newChallenge
    );
    
    event Mint(
        address indexed from, 
        uint rewardAmount, 
        uint epochCount, 
        bytes32 newChallenge
    );

    event ReCalculate(
        address token, 
        uint newDifficulty
    );

    event Solution(
        address indexed token, 
        address indexed miner, 
        uint difficulty,
        uint nonce,
        bytes32 challenge, 
        bytes32 newChallenge
    );

    /* Constructor. */
    constructor() public {
        /* Initialize Zer0netDb (eternal) storage database contract. */
        // NOTE We hard-code the address here, since it should never change.
        _zer0netDb = Zer0netDbInterface(0xE865Fe1A1A3b342bF0E2fcB11fF4E3BCe58263af);
        // _zer0netDb = Zer0netDbInterface(0x4C2f68bCdEEB88764b1031eC330aD4DF8d6F64D6); // ROPSTEN
        // _zer0netDb = Zer0netDbInterface(0x3e246C5038287DEeC6082B95b5741c147A3f49b3); // KOVAN

        /* Initialize (aname) hash. */
        bytes32 hash = keccak256(abi.encodePacked('aname.', _namespace));

        /* Set predecessor address. */
        _predecessor = _zer0netDb.getAddress(hash);

        /* Verify predecessor address. */
        if (_predecessor != 0x0) {
            /* Retrieve the last revision number (if available). */
            uint lastRevision = Minado(_predecessor).getRevision();
            
            /* Set (current) revision number. */
            _revision = lastRevision + 1;
        }
    }
    
    /**
     * @dev Only allow access to an authorized Zer0net administrator.
     */
    modifier onlyAuthBy0Admin() {
        /* Verify write access is only permitted to authorized accounts. */
        require(_zer0netDb.getBool(keccak256(
            abi.encodePacked(msg.sender, '.has.auth.for.', _namespace))) == true);

        _;      // function code is inserted here
    }

    /**
     * @dev Only allow access to "registered" authorized user/contract.
     */
    modifier onlyTokenProvider(
        address _token
    ) {
        /* Validate authorized token manager. */
        require(_zer0netDb.getBool(keccak256(abi.encodePacked(
            _namespace, '.',
            msg.sender, 
            '.has.auth.for.', 
            _token
        ))) == true);

        _;      // function code is inserted here
    }

    /**
     * THIS CONTRACT DOES NOT ACCEPT DIRECT ETHER
     */
    function () public payable {
        /* Cancel this transaction. */
        revert('Oops! Direct payments are NOT permitted here.');
    }


    /***************************************************************************
     * 
     * ACTIONS
     * 
     */

    /**
     * Initialize Token
     */
    function init(
        address _token,
        address _provider
    ) external onlyAuthBy0Admin returns (bool success) {
        /* Set hash. */
        bytes32 hash = keccak256(abi.encodePacked(
            _namespace, '.', 
            _token, 
            '.last.adjustment'
        ));

        /* Set current adjustment time in Zer0net Db. */
        _zer0netDb.setUint(hash, block.number);

        /* Set hash. */
        hash = keccak256(abi.encodePacked(
            _namespace, '.', 
            _token, 
            '.generations.per.adjustment'
        ));

        /* Set value in Zer0net Db. */
        _zer0netDb.setUint(hash, _DEFAULT_GENERATIONS_PER_ADJUSTMENT);

        /* Set hash. */
        hash = keccak256(abi.encodePacked(
            _namespace, '.', 
            _token, 
            '.challenge'
        ));

        /* Set current adjustment time in Zer0net Db. */
        _zer0netDb.setBytes(
            hash, 
            _bytes32ToBytes(blockhash(block.number - 1))
        );

        /* Set mining target. */
        // NOTE: This is the default difficulty of 1.
        _setMiningTarget(
            _token, 
            _MAXIMUM_TARGET
        );

        /* Set hash. */
        hash = keccak256(abi.encodePacked(
            _namespace, '.',
            _provider, 
            '.has.auth.for.', 
            _token
        ));

        /* Set value in Zer0net Db. */
        _zer0netDb.setBool(hash, true);

        return true;
    }

    /**
     * Mint
     */
    function mint(
        address _token,
        bytes32 _digest,
        uint _nonce
    ) public returns (bool success) {
        /* Retrieve the current challenge. */
        uint challenge = getChallenge(_token);

        /* Get mint digest. */
        bytes32 digest = getMintDigest(
            challenge, 
            msg.sender, 
            _nonce
        );

        /* The challenge digest must match the expected. */
        if (digest != _digest) {
            revert('Oops! That solution is NOT valid.');
        }

        /* The digest must be smaller than the target. */
        if (uint(digest) > getTarget(_token)) {
            revert('Oops! That solution is NOT valid.');
        }

        /* Set hash. */
        bytes32 hash = keccak256(abi.encodePacked(
            _namespace, '.', 
            digest, 
            '.solutions'
        ));

        /* Retrieve value from Zer0net Db. */
        uint solution = _zer0netDb.getUint(hash);

        /* Validate solution. */
        if (solution != 0x0) {
            revert('Oops! That solution is a DUPLICATE.');
        }

        /* Save this digest to 'solved' solutions. */
        _zer0netDb.setUint(hash, uint(digest));

        /* Set hash. */
        hash = keccak256(abi.encodePacked(
            _namespace, '.', 
            _token, 
            '.generation'
        ));

        /* Retrieve value from Zer0net Db. */
        uint generation = _zer0netDb.getUint(hash);

        /* Increment the generation. */
        generation = generation.add(1);

        /* Increment the generation count by 1. */
        _zer0netDb.setUint(hash, generation);

        /* Set hash. */
        hash = keccak256(abi.encodePacked(
            _namespace, '.', 
            _token, 
            '.generations.per.adjustment'
        ));

        /* Retrieve value from Zer0net Db. */
        uint genPerAdjustment = _zer0netDb.getUint(hash);

        // every so often, readjust difficulty. Dont readjust when deploying
        if (generation % genPerAdjustment == 0) {
            _reAdjustDifficulty(_token);
        }

        /* Set hash. */
        hash = keccak256(abi.encodePacked(
            _namespace, '.', 
            _token, 
            '.challenge'
        ));

        /**
         * Make the latest ethereum block hash a part of the next challenge 
         * for PoW to prevent pre-mining future blocks. Do this last, 
         * since this is a protection mechanism in the mint() function.
         */
        _zer0netDb.setBytes(
            hash, 
            _bytes32ToBytes(blockhash(block.number - 1))
        );

        /* Retrieve mining reward. */
        // FIXME Add support for percentage reward.
        uint rewardAmount = getMintFixed(_token);

        /* Transfer (token) reward to minter. */
        _infinityPool().transfer(
            _token, 
            msg.sender, 
            rewardAmount
        );

        /* Emit log info. */
        emit Mint(
            msg.sender, 
            rewardAmount, 
            generation, 
            blockhash(block.number - 1) // next target
        );

        /* Return success. */
        return true;
    }

    /**
     * Test Mint Solution
     */
    function testMint(
        bytes32 _digest, 
        uint _challenge, 
        address _minter,
        uint _nonce, 
        uint _target
    ) public pure returns (bool success) {
        /* Retrieve digest. */
        bytes32 digest = getMintDigest(
            _challenge, 
            _minter,
            _nonce
        );

        /* Validate digest. */
        // NOTE: Cast type to 256-bit integer
        if (uint(digest) > _target) {
            /* Set flag. */
            success = false;
        } else {
            /* Verify success. */
            success = (digest == _digest);
        }
    }

    /**
     * Re-calculate Difficulty
     * 
     * Token owner(s) can "manually" trigger the re-calculation of their token,
     * based on the parameters that have been set.
     * 
     * NOTE: This will help deter malicious miners from gaming the difficulty
     *       parameter, to the detriment of the token's community.
     */
    function reCalculateDifficulty(
        address _token
    ) external onlyTokenProvider(_token) returns (bool success) {
        /* Re-calculate difficulty. */
        return _reAdjustDifficulty(_token);
    }

    /**
     * Re-adjust Difficulty
     * 
     * Re-adjust the target by 5 percent.
     * (source: https://en.bitcoin.it/wiki/Difficulty#What_is_the_formula_for_difficulty.3F)
     * 
     * NOTE: Assume 240 ethereum blocks per hour (approx. 15/sec)
     * 
     * NOTE: As of 2017 the bitcoin difficulty was up to 17 zeroes, 
     *       it was only 8 in the early days.
     */
    function _reAdjustDifficulty(
        address _token
    ) private returns (bool success) {
        /* Set hash. */
        bytes32 lastAdjustmentHash = keccak256(abi.encodePacked(
            _namespace, '.', 
            _token, 
            '.last.adjustment'
        ));

        /* Retrieve value from Zer0net Db. */
        uint lastAdjustment = _zer0netDb.getUint(lastAdjustmentHash);

        /* Retrieve value from Zer0net Db. */
        uint blocksSinceLastAdjustment = block.number - lastAdjustment;

        /* Set hash. */
        bytes32 adjustmentHash = keccak256(abi.encodePacked(
            _namespace, '.', 
            _token, 
            '.generations.per.adjustment'
        ));

        /* Retrieve value from Zer0net Db. */
        uint genPerAdjustment = _zer0netDb.getUint(adjustmentHash);
        
        /* Calculate number of expected blocks per adjustment. */
        uint expectedBlocksPerAdjustment = genPerAdjustment.mul(BLOCKS_PER_GENERATION);

        /* Retrieve mining target. */
        uint miningTarget = getTarget(_token);

        /* Validate the number of blocks passed; if there were less eth blocks 
         * passed in time than expected, then miners are excavating too quickly.
         */
        if (blocksSinceLastAdjustment < expectedBlocksPerAdjustment) {
            // NOTE: This number will be an integer greater than 10000.
            uint excess_block_pct = expectedBlocksPerAdjustment.mul(10000)
                .div(blocksSinceLastAdjustment);

            /**
             * Excess Block Percentage Extra
             * 
             * For example:
             *     If there were 5% more blocks mined than expected, then this is 500.
             *     If there were 25% more blocks mined than expected, then this is 2500.
             */
            uint excess_block_pct_extra = excess_block_pct.sub(10000);
            
            /* Set a maximum difficulty INCREASE of 50%. */
            // NOTE: By default, this is within a 24hr period.
            if (excess_block_pct_extra > 5000) {
                excess_block_pct_extra = 5000;
            }

            /**
             * Reset the Mining Target
             * 
             * Calculate the difficulty difference, then SUBTRACT
             * that value from the current difficulty.
             */
            miningTarget = miningTarget.sub(
                /* Calculate difficulty difference. */
                miningTarget
                    .mul(excess_block_pct_extra)
                    .div(10000)
            );   
        } else {
            // NOTE: This number will be an integer greater than 10000.
            uint shortage_block_pct = blocksSinceLastAdjustment.mul(10000)
                .div(expectedBlocksPerAdjustment);

            /**
             * Shortage Block Percentage Extra
             * 
             * For example:
             *     If it took 5% longer to mine than expected, then this is 500.
             *     If it took 25% longer to mine than expected, then this is 2500.
             */
            uint shortage_block_pct_extra = shortage_block_pct.sub(10000);

            // NOTE: There is NO limit on the amount of difficulty DECREASE.

            /**
             * Reset the Mining Target
             * 
             * Calculate the difficulty difference, then ADD
             * that value to the current difficulty.
             */
            miningTarget = miningTarget.add(
                miningTarget
                    .mul(shortage_block_pct_extra)
                    .div(10000)
            );
        }

        /* Set current adjustment time in Zer0net Db. */
        _zer0netDb.setUint(lastAdjustmentHash, block.number);

        /* Validate TOO SMALL mining target. */
        // NOTE: This is very difficult to guess.
        if (miningTarget < _MINIMUM_TARGET) {
            miningTarget = _MINIMUM_TARGET;
        }

        /* Validate TOO LARGE mining target. */
        // NOTE: This is very easy to guess.
        if (miningTarget > _MAXIMUM_TARGET) {
            miningTarget = _MAXIMUM_TARGET;
        }

        /* Set mining target. */
        _setMiningTarget(
            _token,
            miningTarget
        );

        /* Return success. */
        return true;
    }


    /***************************************************************************
     * 
     * GETTERS
     * 
     */

    /**
     * Get Starting Block
     * 
     * Starting Blocks
     * ---------------
     * 
     * First blocks honoring the start of Miss Piggy's celebration year:
     *     - Mainnet :  7,175,716
     *     - Ropsten :  4,956,268
     *     - Kovan   : 10,283,438
     * 
     * NOTE: Pulls value from db `minado.starting.block` using the
     *       respective networks.
     */
    function getStartingBlock() public view returns (uint startingBlock) {
        /* Set hash. */
        bytes32 hash = keccak256(abi.encodePacked(
            _namespace, 
            '.starting.block'
        ));

        /* Retrieve value from Zer0net Db. */
        startingBlock = _zer0netDb.getUint(hash);
    }
    
    /**
     * Get minter's mintng address.
     */
    function getMinter() external view returns (address minter) {
        /* Set hash. */
        bytes32 hash = keccak256(abi.encodePacked(
            _namespace,
            '.minter'
        ));

        /* Retrieve value from Zer0net Db. */
        minter = _zer0netDb.getAddress(hash);
    }

    /**
     * Get generation details.
     */
    function getGeneration(
        address _token
    ) external view returns (
        uint generation,
        uint cycle
    ) {
        /* Set hash. */
        bytes32 hash = keccak256(abi.encodePacked(
            _namespace, '.', 
            _token, 
            '.generation'
        ));

        /* Retrieve value from Zer0net Db. */
        generation = _zer0netDb.getUint(hash);

        /* Set hash. */
        hash = keccak256(abi.encodePacked(
            _namespace, '.', 
            _token, 
            '.generations.per.adjustment'
        ));

        /* Retrieve value from Zer0net Db. */
        cycle = _zer0netDb.getUint(hash);
    }

    /**
     * Get Minting FIXED amount
     */
    function getMintFixed(
        address _token
    ) public view returns (uint amount) {
        /* Set hash. */
        bytes32 hash = keccak256(abi.encodePacked(
            _namespace, '.', 
            _token, 
            '.mint.fixed'
        ));

        /* Retrieve value from Zer0net Db. */
        amount = _zer0netDb.getUint(hash);
    }

    /**
     * Get Minting PERCENTAGE amount
     */
    function getMintPct(
        address _token
    ) public view returns (uint amount) {
        /* Set hash. */
        bytes32 hash = keccak256(abi.encodePacked(
            _namespace, '.', 
            _token, 
            '.mint.pct'
        ));

        /* Retrieve value from Zer0net Db. */
        amount = _zer0netDb.getUint(hash);
    }

    /**
     * Get (Mining) Challenge
     * 
     * This is an integer representation of a recent ethereum block hash, 
     * used to prevent pre-mining future blocks.
     */
    function getChallenge(
        address _token
    ) public view returns (uint challenge) {
        /* Set hash. */
        bytes32 hash = keccak256(abi.encodePacked(
            _namespace, '.', 
            _token, 
            '.challenge'
        ));

        /* Retrieve value from Zer0net Db. */
        // NOTE: Convert from bytes to integer.
        challenge = uint(_bytesToBytes32(
            _zer0netDb.getBytes(hash)
        ));
    }

    /**
     * Get (Mining) Difficulty
     * 
     * The number of zeroes the digest of the PoW solution requires.
     * (auto adjusts)
     */
    function getDifficulty(
        address _token
    ) public view returns (uint difficulty) {
        /* Caclulate difficulty. */
        difficulty = _MAXIMUM_TARGET.div(getTarget(_token));
    }

    /**
     * Get (Mining) Target
     */
    function getTarget(
        address _token
    ) public view returns (uint target) {
        /* Set hash. */
        bytes32 hash = keccak256(abi.encodePacked(
            _namespace, '.', 
            _token, 
            '.target'
        ));

        /* Retrieve value from Zer0net Db. */
        target = _zer0netDb.getUint(hash);
    }

    /**
     * Get Mint Digest
     * 
     * The PoW must contain work that includes a recent 
     * ethereum block hash (challenge hash) and the 
     * msg.sender's address to prevent MITM attacks
     */
    function getMintDigest(
        uint _challenge,
        address _minter,
        uint _nonce 
    ) public pure returns (bytes32 digest) {
        /* Calculate digest. */
        digest = keccak256(abi.encodePacked(
            _challenge, 
            _minter, 
            _nonce
        ));
    }

    /**
     * Get Revision (Number)
     */
    function getRevision() public view returns (uint) {
        return _revision;
    }

    
    /***************************************************************************
     * 
     * SETTERS
     * 
     */

    /**
     * Set Generations Per (Difficulty) Adjustment
     * 
     * Token owner(s) can adjust the number of generations 
     * per difficulty re-calculation.
     * 
     * NOTE: This will help deter malicious miners from gaming the difficulty
     *       parameter, to the detriment of the token's community.
     */
    function setGenPerAdjustment(
        address _token,
        uint _numBlocks
    ) external onlyTokenProvider(_token) returns (bool success) {
        /* Set hash. */
        bytes32 hash = keccak256(abi.encodePacked(
            _namespace, '.', 
            _token, 
            '.generations.per.adjustment'
        ));

        /* Set value in Zer0net Db. */
        _zer0netDb.setUint(hash, _numBlocks);
        
        /* Return success. */
        return true;
    }

    /**
     * Set (Fixed) Mint Amount
     */
    function setMintFixed(
        address _token,
        uint _amount
    ) external onlyTokenProvider(_token) returns (bool success) {
        /* Set hash. */
        bytes32 hash = keccak256(abi.encodePacked(
            _namespace, '.', 
            _token, 
            '.mint.fixed'
        ));

        /* Set value in Zer0net Db. */
        _zer0netDb.setUint(hash, _amount);
        
        /* Return success. */
        return true;
    }

    /**
     * Set (Dynamic) Mint Percentage
     */
    function setMintPct(
        address _token,
        uint _pct
    ) external onlyTokenProvider(_token) returns (bool success) {
        /* Set hash. */
        bytes32 hash = keccak256(abi.encodePacked(
            _namespace, '.', 
            _token, 
            '.mint.pct'
        ));

        /* Set value in Zer0net Db. */
        _zer0netDb.setUint(hash, _pct);
        
        /* Return success. */
        return true;
    }

    /**
     * Set Token Parent(s)
     * 
     * Enables the use of merged mining by specifying (parent) tokens 
     * that offer an acceptibly HIGH difficulty for the child's own 
     * mining challenge.
     * 
     * Parents are saved in priority levels:
     *     1 - Most significant parent
     *     2 - 2nd most significant parent
     *     ...
     *     # - Least significant parent
     */
    function setTokenParents(
        address _token,
        address[] _parents
    ) external onlyTokenProvider(_token) returns (bool success) {
        /* Set hash. */
        bytes32 hash = keccak256(abi.encodePacked(
            _namespace, '.', 
            _token, 
            '.parents'
        ));
        
        // FIXME How should we store a dynamic amount of parents?
        //       Packed as bytes??
        
        // FIXME TEMPORARILY LIMITED TO 3
        bytes memory allParents = abi.encodePacked(
            _parents[0],
            _parents[1],
            _parents[2]
        );

        /* Set value in Zer0net Db. */
        _zer0netDb.setBytes(hash, allParents);
        
        /* Return success. */
        return true;
    }
    
    /**
     * Set Token Provider
     */
    function setTokenProvider(
        address _token,
        address _provider,
        bool _auth
    ) external onlyAuthBy0Admin returns (bool success) {
        /* Set hash. */
        bytes32 hash = keccak256(abi.encodePacked(
            _namespace, '.',
            _provider, 
            '.has.auth.for.', 
            _token
        ));

        /* Set value in Zer0net Db. */
        _zer0netDb.setBool(hash, _auth);
        
        /* Return success. */
        return true;
    }

    /**
     * Set Mining Target
     */
    function _setMiningTarget(
        address _token,
        uint _target
    ) private returns (bool success) {
        /* Set hash. */
        bytes32 hash = keccak256(abi.encodePacked(
            _namespace, '.', 
            _token, 
            '.target'
        ));

        /* Set value in Zer0net Db. */
        _zer0netDb.setUint(hash, _target);
        
        /* Return success. */
        return true;
    }


    /***************************************************************************
     *
     * INTERFACES
     *
     */

    /**
     * Supports Interface (EIP-165)
     *
     * (see: https://github.com/ethereum/EIPs/blob/master/EIPS/eip-165.md)
     *
     * NOTE: Must support the following conditions:
     *       1. (true) when interfaceID is 0x01ffc9a7 (EIP165 interface)
     *       2. (false) when interfaceID is 0xffffffff
     *       3. (true) for any other interfaceID this contract implements
     *       4. (false) for any other interfaceID
     */
    function supportsInterface(
        bytes4 _interfaceID
    ) external pure returns (bool) {
        /* Initialize constants. */
        bytes4 InvalidId = 0xffffffff;
        bytes4 ERC165Id = 0x01ffc9a7;

        /* Validate condition #2. */
        if (_interfaceID == InvalidId) {
            return false;
        }

        /* Validate condition #1. */
        if (_interfaceID == ERC165Id) {
            return true;
        }

        // TODO Add additional interfaces here.

        /* Return false (for condition #4). */
        return false;
    }

    /**
     * ECRecovery Interface
     */
    function _ecRecovery() private view returns (
        ECRecovery ecrecovery
    ) {
        /* Initialize hash. */
        bytes32 hash = keccak256('aname.ecrecovery');

        /* Retrieve value from Zer0net Db. */
        address aname = _zer0netDb.getAddress(hash);

        /* Initialize interface. */
        ecrecovery = ECRecovery(aname);
    }

    /**
     * InfinityPool Interface
     * 
     * Retrieves the current InfinityPool interface,
     * using the aname record from Zer0netDb.
     */
    function _infinityPool() private view returns (
        InfinityPoolInterface infinityPool
    ) {
        /* Initailze hash. */
        bytes32 hash = keccak256('aname.infinitypool');
        
        /* Retrieve value from Zer0net Db. */
        address aname = _zer0netDb.getAddress(hash);
        
        /* Initialize interface. */
        infinityPool = InfinityPoolInterface(aname);
    }

    /**
     * InfinityWell Interface
     * 
     * Retrieves the current InfinityWell interface,
     * using the aname record from Zer0netDb.
     */
    function _infinityWell() private view returns (
        InfinityWellInterface infinityWell
    ) {
        /* Initailze hash. */
        bytes32 hash = keccak256('aname.infinitywell');
        
        /* Retrieve value from Zer0net Db. */
        address aname = _zer0netDb.getAddress(hash);
        
        /* Initialize interface. */
        infinityWell = InfinityWellInterface(aname);
    }


    /***************************************************************************
     * 
     * UTILITIES
     * 
     */

    /**
     * Bytes-to-Address
     * 
     * Converts bytes into type address.
     */
    function _bytesToAddress(bytes _address) private pure returns (address) {
        uint160 m = 0;
        uint160 b = 0;

        for (uint8 i = 0; i < 20; i++) {
            m *= 256;
            b = uint160(_address[i]);
            m += (b);
        }

        return address(m);
    }

    /**
     * Convert Bytes to Bytes32
     */
    function _bytesToBytes32(
        bytes _data
    ) private pure returns (bytes32 result) {
        /* Loop through each byte. */
        for (uint i = 0; i < 32; i++) {
            /* Shift bytes onto result. */
            result |= bytes32(_data[i] & 0xFF) >> (i * 8);
        }
    }
    
    /**
     * Convert Bytes32 to Bytes
     * 
     * NOTE: Since solidity v0.4.22, you can use `abi.encodePacked()` for this, 
     *       which returns bytes. (https://ethereum.stackexchange.com/a/55963)
     */
    function _bytes32ToBytes(
        bytes32 _data
    ) private pure returns (bytes result) {
        /* Pack the data. */
        return abi.encodePacked(_data);
    }
}