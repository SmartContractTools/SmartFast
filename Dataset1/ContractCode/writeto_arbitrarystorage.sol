pragma solidity ^0.4.24;

contract Map {
    address public owner;
    uint256[] map;

    function set(uint256 key, uint256 value) public {
        map[key] = value; //bad
    }

    function set_bad(uint256 key, uint256 value) public {
        uint256 key2 = key;
        map[key2] = value; //bad
    }

    function set_good(uint256 key, uint256 value) public {
        if(key<=map.length) {
	       map[key] = value; //good
        }
    }

    function set_good1(uint256 key, uint256 value) public {
        uint256 key2 = key;
    	if(key2<=map.length) {
    	    map[key2] = value; //good
    	}
    }

    function get(uint256 key) public view returns (uint256) {
        return map[key]; //good
    }
    function withdraw() public{
        require(msg.sender == owner);
        msg.sender.transfer(address(this).balance);
    }

    function bad(uint256 key, uint256 value) public{ //state variable
    	uint[] ss;
    	ss[key] = value;
    }
}
