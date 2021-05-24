// File: contracts/UniswapExchangeInterface.sol

pragma solidity ^0.5.0;

contract UniswapExchangeInterface {
    // Address of ERC20 token sold on this exchange
    function tokenAddress() external view returns (address token);
    // Address of Uniswap Factory
    function factoryAddress() external view returns (address factory);
    // Provide Liquidity
    function addLiquidity(uint256 min_liquidity, uint256 max_tokens, uint256 deadline) external payable returns (uint256);
    function removeLiquidity(uint256 amount, uint256 min_eth, uint256 min_tokens, uint256 deadline) external returns (uint256, uint256);
    // Get Prices
    function getEthToTokenInputPrice(uint256 eth_sold) external view returns (uint256 tokens_bought);
    function getEthToTokenOutputPrice(uint256 tokens_bought) external view returns (uint256 eth_sold);
    function getTokenToEthInputPrice(uint256 tokens_sold) external view returns (uint256 eth_bought);
    function getTokenToEthOutputPrice(uint256 eth_bought) external view returns (uint256 tokens_sold);
    // Trade ETH to ERC20
    function ethToTokenSwapInput(uint256 min_tokens, uint256 deadline) external payable returns (uint256  tokens_bought);
    function ethToTokenTransferInput(uint256 min_tokens, uint256 deadline, address recipient) external payable returns (uint256  tokens_bought);
    function ethToTokenSwapOutput(uint256 tokens_bought, uint256 deadline) external payable returns (uint256  eth_sold);
    function ethToTokenTransferOutput(uint256 tokens_bought, uint256 deadline, address recipient) external payable returns (uint256  eth_sold);
    // Trade ERC20 to ETH
    function tokenToEthSwapInput(uint256 tokens_sold, uint256 min_eth, uint256 deadline) external returns (uint256  eth_bought);
    function tokenToEthTransferInput(uint256 tokens_sold, uint256 min_eth, uint256 deadline, address recipient) external returns (uint256  eth_bought);
    function tokenToEthSwapOutput(uint256 eth_bought, uint256 max_tokens, uint256 deadline) external returns (uint256  tokens_sold);
    function tokenToEthTransferOutput(uint256 eth_bought, uint256 max_tokens, uint256 deadline, address recipient) external returns (uint256  tokens_sold);
    // Trade ERC20 to ERC20
    function tokenToTokenSwapInput(uint256 tokens_sold, uint256 min_tokens_bought, uint256 min_eth_bought, uint256 deadline, address token_addr) external returns (uint256  tokens_bought);
    function tokenToTokenTransferInput(uint256 tokens_sold, uint256 min_tokens_bought, uint256 min_eth_bought, uint256 deadline, address recipient, address token_addr) external returns (uint256  tokens_bought);
    function tokenToTokenSwapOutput(uint256 tokens_bought, uint256 max_tokens_sold, uint256 max_eth_sold, uint256 deadline, address token_addr) external returns (uint256  tokens_sold);
    function tokenToTokenTransferOutput(uint256 tokens_bought, uint256 max_tokens_sold, uint256 max_eth_sold, uint256 deadline, address recipient, address token_addr) external returns (uint256  tokens_sold);
    // Trade ERC20 to Custom Pool
    function tokenToExchangeSwapInput(uint256 tokens_sold, uint256 min_tokens_bought, uint256 min_eth_bought, uint256 deadline, address exchange_addr) external returns (uint256  tokens_bought);
    function tokenToExchangeTransferInput(uint256 tokens_sold, uint256 min_tokens_bought, uint256 min_eth_bought, uint256 deadline, address recipient, address exchange_addr) external returns (uint256  tokens_bought);
    function tokenToExchangeSwapOutput(uint256 tokens_bought, uint256 max_tokens_sold, uint256 max_eth_sold, uint256 deadline, address exchange_addr) external returns (uint256  tokens_sold);
    function tokenToExchangeTransferOutput(uint256 tokens_bought, uint256 max_tokens_sold, uint256 max_eth_sold, uint256 deadline, address recipient, address exchange_addr) external returns (uint256  tokens_sold);
    // ERC20 comaptibility for liquidity tokens
    bytes32 public name;
    bytes32 public symbol;
    uint256 public decimals;
    function transfer(address _to, uint256 _value) external returns (bool);
    function transferFrom(address _from, address _to, uint256 value) external returns (bool);
    function approve(address _spender, uint256 _value) external returns (bool);
    function allowance(address _owner, address _spender) external view returns (uint256);
    function balanceOf(address _owner) external view returns (uint256);
    function totalSupply() external view returns (uint256);
    // Never use
    function setup(address token_addr) external;
}

// File: contracts/WETH9Interface.sol

pragma solidity ^0.5.0;

contract WETH9Interface {
    function balanceOf(address who) external view returns (uint256);
    function allowance(address owner, address spender) external view returns (uint256);

    function deposit() public payable;
    function withdraw(uint wad) public;

    function totalSupply() public view returns (uint);
    function approve(address guy, uint wad) public returns (bool);
    function transfer(address dst, uint wad) public returns (bool);
    function transferFrom(address src, address dst, uint wad) public returns (bool);
}

// File: contracts/UniswapWethLiquidityAdder.sol

pragma solidity ^0.5.0;



/**
 * @title Uniswap V1 ETH-WETH Exchange Liquidity Adder
 * @dev Help adding ETH to Uniswap ETH-WETH exchange in one tx.
 * @notice Do not send WETH or UNI token to this contract.
 */
contract UniswapWethLiquidityAdder {
    // Uniswap V1 ETH-WETH Exchange Address
    address public uniswapWethExchangeAddress = 0xA2881A90Bf33F03E7a3f803765Cd2ED5c8928dFb;
    address public wethAddress = 0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2;

    WETH9Interface weth = WETH9Interface(wethAddress);
    UniswapExchangeInterface uniswapWethExchange = UniswapExchangeInterface(uniswapWethExchangeAddress);

    constructor() public {
        // approve Uniswap ETH-WETH Exchange to transfer WETH from this contract
        weth.approve(uniswapWethExchangeAddress, 2**256 - 1);
    }

    function () external payable {
        addLiquidity();
    }

    // TODO: should this function return anything?
    /// @dev Receive ETH, add to Uniswap ETH-WETH exchange, and return UNI token.
    /// Will try to add all ETH in this contract to the liquidity pool.
    /// There may be WETH token stuck in this contract?, but we don't care
    function addLiquidity() public payable {
        // If no ETH is received, revert.
        // require(msg.value > 0);

        // Get the amount of ETH now in this contract as the total amount of ETH we are going to add.
        uint256 totalEth = address(this).balance;

        // Get the amount of ETH and WETH in the liquidity pool.
        uint256 ethInPool = uniswapWethExchangeAddress.balance;
        uint256 wethInPool = weth.balanceOf(uniswapWethExchangeAddress);

        // Calculate the amount of WETH we need to wrap.
        // We are solving this:
        //     Find maximum integer `ethToAdd` s.t.
        //     ethToAdd + wethToAdd <= totalEth
        //     wethToAdd = floor(ethToAdd * wethInPool / ethInPool) + 1
        // Solution:
        //     Let x = ethToAdd
        //         A = wethInPool
        //         B = ethInPool
        //         C = totalEth
        //     Then
        //         x + floor(x * A / B) + 1 <= C
        //         <=> x + x * A / B + 1 < C + 1
        //         <=> x + x * A / B < C
        //         <=> x < C * B / (A + B)
        //         <=> max int x = ceil(C * B / (A + B)) - 1
        //     So max `ethToAdd` is ceil(totalEth * ethInPool / (wethInPool + ethInPool)) - 1
        // Notes:
        //     1. In the following code, we set `ethToAdd = floor(C * B / (A + B)) - 1`
        //         instead of `ethToAdd = ceil(C * B / (A + B)) - 1`
        //         because it's cheaper to compute `floor` (just an integer division),
        //         and the difference is at most 1 wei.
        //     2. We don't use SafeMath here because it's almost impossible to overflow
        //         when computing `ethBalance * ethBalance` or `ethBalance * wethBalance`
        uint256 ethToAdd = totalEth * ethInPool / (wethInPool + ethInPool) - 1;
        uint256 wethToAdd = ethToAdd * wethInPool / ethInPool + 1;

        // Wrap ETH.
        weth.deposit.value(wethToAdd)();
        // require(weth.balanceOf(address(this)) == wethToAdd);

        // Add liquidity.
        uint256 liquidityMinted = uniswapWethExchange.addLiquidity.value(ethToAdd)(1, 2**256-1, 2**256-1);
        // require(liquidityMinted > 0);

        // Transfer liquidity token to msg.sender.
        // uint256 liquidityTokenBalance = uniswapWethExchange.balanceOf(msg.sender);
        uniswapWethExchange.transfer(msg.sender, liquidityMinted);
        // require(uniswapWethExchange.transfer(msg.sender, liquidityMinted));
    }
}