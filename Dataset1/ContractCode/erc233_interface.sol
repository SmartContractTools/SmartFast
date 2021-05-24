pragma solidity ^0.4.9;

 /* 新的 ERC23 contract 接口文件 */

contract ERC223 {
  uint public totalSupply;
  function balanceOf(address who) constant returns (uint);

  function name() constant;//returns (string _name)
  function symbol() constant returns (string _symbol);
  function decimals() constant returns (bool _decimals);//uint8
  function totalSupply() constant returns (uint256 _supply);

  function transfer(address to, uint value) returns (bool ok);
  function transfer(address to, uint value, bytes data) returns (bool ok);
  function transfer(address to, uint value, bytes data, string custom_fallback) returns (bool ok);
  event Transfer(address indexed from, address indexed to, uint value, bytes indexed data);
}
