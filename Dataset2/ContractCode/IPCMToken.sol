pragma solidity ^0.6.1;


/**

 * @dev IPCM Author: AlanYan99@outlook.com, Date:2020/04

 */

contract IPCMToken {
    using SafeMath for uint256;

    string public constant name = "InterPlanetary Continuous Media"; //  token name
    string public constant symbol = "IPCM"; //  token symbol
    uint256 public decimals = 18; //  token digit

    uint256 public totalSupply_; // 
    uint256 public _maxSupply = 100000000 * 10**uint256(decimals); //

    address owner = address(0); //

    event Transfer(address indexed from, address indexed to, uint256 value); // 

    /**

  * @dev 

  */
  
    uint256 public unit_first = 1 days;
    uint256 public unit_second = 365 days;

    address public addr_pool = 0x44a16F5Ec33c845AB10343F8Cae4093b6c028ccB; //
    address public addr_private = 0x970603FaD5d239070593D33772451A533d2c3C5E; //
    address public addr_fund = 0xf4c0ee2707Da59bf57effE9Ee3034Bed18718EF5; //
    address public addr_promotion = 0x2D6b8F56E40296c251A88509f7Be00E97bCE27e7; //
    address public addr_team = 0x27e57a6dFCF442f1cAC135285A7434E8de364cA5; //
    

    mapping(address => uint256) balances; // 

    /** Reserve allocations */
    mapping(address => uint256) public allocations; // 

    /** When timeLocks are over (UNIX Timestamp) */
    mapping(address => uint256) public timeLocks; // 

    /** How many tokens each reserve wallet has claimed */
    mapping(address => uint256) public claimed; // 

    /** When token was locked (UNIX Timestamp)*/
    uint256 public lockedAt = 0;

    /** Allocated reserve tokens */
    event Allocated(address wallet, uint256 value);

    /** Distributed reserved tokens */
    event Distributed(address wallet, uint256 value);

    /** Tokens have been locked */
    event Locked(uint256 lockTime);

    modifier isOwner {
        assert(owner == msg.sender);
        _;
    }

    // 
    modifier onlyReserveWallets {
        require(
            msg.sender == addr_pool ||
                msg.sender == addr_private ||
                msg.sender == addr_fund ||
                msg.sender == addr_promotion ||
                msg.sender == addr_team
        );
        require(allocations[msg.sender] > 0);

        _;
    }

    constructor() public {
        owner = msg.sender;
        allocate();
    }

    /**

 * @dev total number of tokens in existence

 */

    function totalSupply() public view returns (uint256) {
        return totalSupply_;
    }

    /**

 * @dev Gets the balance of the specified address.

 * @param _owner The address to query the the balance of.

 * @return An uint256 representing the amount owned by the passed address.

 */

    function balanceOf(address _owner) public view returns (uint256) {
        require(_owner != address(0));

        //
        return balances[_owner];
    }

    function maxSupply() public view returns (uint256) {
        return _maxSupply;
    }

    //
    function _transfer(address _from, address _to, uint256 _value) internal {
        require(_value > 0);

        //0x0
        require(_to != address(0));

        //
        require(balances[_from].sub(_value) >= 0);

        //
        require(balances[_to].add(_value) > balances[_to]);

        //
        balances[_from] = balances[_from].sub(_value);

        //
        balances[_to] = balances[_to].add(_value);

        emit Transfer(_from, _to, _value);
    }

    function transfer(address _to, uint256 _value)
        public
        returns (bool success)
    {
        _transfer(msg.sender, _to, _value);
        return true;
    }

    //token
    function allocate() internal {
        balances[addr_private] = 1500000 * 10**uint256(decimals);
        balances[addr_fund] = 1500000 * 10**uint256(decimals);
        totalSupply_ = totalSupply_.add(balances[addr_private]);
        totalSupply_ = totalSupply_.add(balances[addr_fund]);

        emit Transfer(address(0), addr_private, balances[addr_private]);
        emit Transfer(address(0), addr_fund, balances[addr_fund]);

        allocations[addr_pool] = 50000000 * 10**uint256(decimals);
        allocations[addr_private] = 13500000 * 10**uint256(decimals);
        allocations[addr_fund] = 13500000 * 10**uint256(decimals);
        allocations[addr_promotion] = 10000000 * 10**uint256(decimals);
        allocations[addr_team] = 10000000 * 10**uint256(decimals);

        emit Allocated(addr_pool, allocations[addr_pool]);
        emit Allocated(addr_private, allocations[addr_private]);
        emit Allocated(addr_fund, allocations[addr_fund]);
        emit Allocated(addr_promotion, allocations[addr_promotion]);
        emit Allocated(addr_team, allocations[addr_team]);

        lock();
    }

    //
    function lock() internal {
        lockedAt = block.timestamp; // 

        uint256 next_year = ((lockedAt / (unit_second)) + 1) * (unit_second);
        uint256 third_year = ((lockedAt / (unit_second)) + 2) * (unit_second);

        timeLocks[addr_pool] = lockedAt;
        timeLocks[addr_private] = next_year;
        timeLocks[addr_promotion] = lockedAt;
        timeLocks[addr_fund] = next_year;
        timeLocks[addr_team] = third_year;

        emit Locked(lockedAt);
    }

    // Number of tokens that are still locked
    function getLockedBalance()
        public
        view
        onlyReserveWallets
        returns (uint256 tokensLocked)
    {
        return allocations[msg.sender].sub(claimed[msg.sender]);
    }

    //
    function claimToken() public onlyReserveWallets {
        if (msg.sender == addr_pool) claimToken_Pool();
        else if (msg.sender == addr_private) claimToken_Private();
        else if (msg.sender == addr_fund) claimToken_Fund();
        else if (msg.sender == addr_promotion) claimToken_Promotion();
        else if (msg.sender == addr_team) claimToken_Team();
    }

    //50%50,000,00050,00025,000
    function claimToken_Pool() public {
        address addr_claim = addr_pool;
        uint256 time_now = block.timestamp;

        require(addr_claim == msg.sender);

        //
        require(time_now > timeLocks[addr_claim]);
        //
        require(claimed[addr_claim] < allocations[addr_claim]);

        uint256 amnt_unit = 50000* 10**uint256(decimals);
        uint256 span_years = (time_now / (unit_second)) -
            (timeLocks[addr_claim] / (unit_second));
        uint256 claim_cnt = 0;
        

        //token
        for (uint256 i = 0; i <= span_years; i++) {
            uint256 amnt_day = amnt_unit / (2**i);

            if (i == 0) //
            {
                uint256 span_days;

                if(span_years<1)
                    span_days = ((time_now - timeLocks[addr_claim]) /
            (unit_first)) + 1;
                else
                    span_days = (unit_second/unit_first) -
                    (timeLocks[addr_claim] % (unit_second)) /
                    (unit_first);

                claim_cnt = claim_cnt.add(amnt_day * span_days);

            } else if (i < span_years) //
            {
                claim_cnt = claim_cnt.add(amnt_day * (unit_second/unit_first));
            } else if (i == span_years) {
                //
                uint256 span_days = (time_now % (unit_second)) / (unit_first) + 1;
                claim_cnt = claim_cnt.add(amnt_day * span_days);
            }
        }
       
        if(claim_cnt > allocations[addr_claim])
            claim_cnt = allocations[addr_claim];

        if (
            claimed[addr_claim] < claim_cnt
        ) //token
        {
            uint256 amount = claim_cnt.sub(claimed[addr_claim]);
            balances[addr_claim] = balances[addr_claim].add(amount);
            claimed[addr_claim] = claim_cnt;
            totalSupply_ = totalSupply_.add(amount);

            emit Transfer(address(0), addr_claim, amount);
            emit Distributed(addr_claim, amount);
        }
    }

    //15%15,000,0001,500,00013,500,00010,000
    function claimToken_Private() public {
        address addr_claim = addr_private;
        uint256 time_now = block.timestamp;

        require(addr_claim == msg.sender);

        //
        require(time_now > timeLocks[addr_claim]);

        //
        require(claimed[addr_claim] < allocations[addr_claim]);
        uint256 amnt_unit = 10000* 10**uint256(decimals);
        uint256 span_days = ((time_now - timeLocks[addr_claim]) / (unit_first)) + 1;
        uint256 claim_cnt = span_days.mul(amnt_unit);

        if(claim_cnt > allocations[addr_claim])
            claim_cnt = allocations[addr_claim];

        if (
            claimed[addr_claim] < claim_cnt
        ) //token
        {
            uint256 amount = claim_cnt.sub(claimed[addr_claim]);
            balances[addr_claim] = balances[addr_claim].add(amount);
            claimed[addr_claim] = claim_cnt;
            totalSupply_ = totalSupply_.add(amount);

            emit Transfer(address(0), addr_claim, amount);
            emit Distributed(addr_claim, amount);
        }
    }

    //15%15,000,0001,500,00013,500,00010,000
    function claimToken_Fund() public {
        address addr_claim = addr_fund;
        uint256 time_now = block.timestamp;

        require(addr_claim == msg.sender);

        //
        require(time_now > timeLocks[addr_claim]);

        //
        require(claimed[addr_claim] < allocations[addr_claim]);

        uint256 amnt_unit = 10000* 10**uint256(decimals);
        uint256 span_days = ((time_now - timeLocks[addr_claim]) / (unit_first)) + 1;
        uint256 claim_cnt = span_days.mul(amnt_unit);

        if(claim_cnt > allocations[addr_claim])
            claim_cnt = allocations[addr_claim];

        if (
            claimed[addr_claim] < claim_cnt
        ) //token
        {
            uint256 amount = claim_cnt.sub(claimed[addr_claim]);
            balances[addr_claim] = balances[addr_claim].add(amount);
            claimed[addr_claim] = claim_cnt;
            totalSupply_ = totalSupply_.add(amount);

            emit Transfer(address(0), addr_claim, amount);
            emit Distributed(addr_claim, amount);
        }
    }

    //10%10,000,000 20,000
    function claimToken_Promotion() public {
        address addr_claim = addr_promotion;
        uint256 time_now = block.timestamp;

        require(addr_claim == msg.sender);

        //
        require(time_now > timeLocks[addr_claim]);

        //
        require(claimed[addr_claim] < allocations[addr_claim]);

        uint256 amnt_unit = 20000* 10**uint256(decimals);
        uint256 span_days = ((time_now - timeLocks[addr_claim]) / (unit_first)) + 1;
        uint256 claim_cnt = span_days.mul(amnt_unit);

        if(claim_cnt > allocations[addr_claim])
            claim_cnt = allocations[addr_claim];

        if (
            claimed[addr_claim] < claim_cnt
        ) //token
        {
            uint256 amount = claim_cnt.sub(claimed[addr_claim]);
            balances[addr_claim] = balances[addr_claim].add(amount);
            claimed[addr_claim] = claim_cnt;
            totalSupply_ = totalSupply_.add(amount);

            emit Transfer(address(0), addr_claim, amount);
            emit Distributed(addr_claim, amount);
        }
    }

    //10%10,000,00020,000
    function claimToken_Team() public {
        address addr_claim = addr_team;
        uint256 time_now = block.timestamp;

        require(addr_claim == msg.sender);

        //
        require(time_now > timeLocks[addr_claim]);

        //
        require(claimed[addr_claim] < allocations[addr_claim]);

        uint256 amnt_unit = 20000* 10**uint256(decimals);
        uint256 span_days = ((time_now - timeLocks[addr_claim]) / (unit_first)) + 1;
        uint256 claim_cnt = span_days.mul(amnt_unit);

        if(claim_cnt > allocations[addr_claim])
            claim_cnt = allocations[addr_claim];

        if (
            claimed[addr_claim] < claim_cnt
        ) //token
        {
            uint256 amount = claim_cnt.sub(claimed[addr_claim]);
            balances[addr_claim] = balances[addr_claim].add(amount);
            claimed[addr_claim] = claim_cnt;
            totalSupply_ = totalSupply_.add(amount);

            emit Transfer(address(0), addr_claim, amount);
            emit Distributed(addr_claim, amount);
        }
    }
}


library SafeMath {
    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        if (a == 0) {
            return 0;
        }
        uint256 c = a * b;
        assert(c / a == b);
        return c;
    }

    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a / b;
        return c;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        assert(b <= a);
        return a - b;
    }

    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        assert(c >= a);
        return c;
    }
}