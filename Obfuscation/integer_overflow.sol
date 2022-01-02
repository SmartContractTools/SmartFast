
pragma solidity ^0.4.24;
/**
 * @title SafeMath
 * @dev Math operations with safety checks that throw on error
   防止整数溢出问题
 */
library SafeMath {
  function mul(uint256 a, uint256 b) internal pure returns (uint256) {
    uint256 c = a * b;
    assert(a == 0 || c / a == b);
    return c;
  }
 
  function div(uint256 a, uint256 b) internal pure returns (uint256) {
    assert(b > 0); // Solidity automatically throws when dividing by 0
    uint256 c = a / b;
    assert(a == b * c + a % b); // There is no case in which this doesn't hold
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

contract Intergeroverflow{
    using SafeMath for uint256;
    function bad() {
	uint a;
	uint b;
	uint c;
	uint d = a + b + c;
    }

    function bad1() {
	uint a;
	uint b;
	uint d = a + b + 5;
    }

    function bad2() {
	uint a;
	uint c;
	if(!(a + c >=3)) {revert();}
	uint b = a - 5;
    }

    function good5() {
	uint a;
	if(!(a>=5)) {revert();}
	uint b = a - 5;
    }

    function good4() {
	uint a;
	uint b;
	if(!((a+b+5)>=5)) {revert();}
	uint d = a + b + 5;
    }

    function good3() {
	uint a;
	uint b;
	uint d = a + b + 5;
	if(!(d>=5)) {revert();}
    }

    function good2() {
	uint a;
	uint b;
	uint d = a + b + 5;
	assert(d >= a);
    }

    function good() {
	uint a;
	uint b;
	uint c = a + b;
	if(!(c>=a&&c>=b)) {revert();}
    }

    function good1() {
	uint a;
	uint b;
	if(!(a+b>=a&&a+b>=b)) {revert();}
	uint c = a + b;
    }
}
