pragma solidity ^0.4.0;

// taken from https://solidity.readthedocs.io/en/v0.4.25/assembly.html

library GetCode {
    modifier modifiertest(address _addr) {
	uint size;
	assembly {          
	    size := extcodesize(_addr)
        }
	require(size != 5);
	_;
    }

    modifier modifiertest2(address _addr) {
	uint size;
	assembly {
            let size1 := extcodesize(_addr)
	    size := size1
        }
	require(size != 5);
	_;
    }

    function at(address _addr) public view returns (bytes o_code) {
        assembly {
            // retrieve the size of the code, this needs assembly
            let size := extcodesize(_addr)
            // allocate output byte array - this could also be done without assembly
            // by using o_code = new bytes(size)
            o_code := mload(0x40)
            // new "memory end" including padding
            mstore(0x40, add(o_code, and(add(add(size, 0x20), 0x1f), not(0x1f))))
            // store length in memory
            mstore(o_code, size)
            // actually retrieve the code, this needs assembly
            extcodecopy(_addr, add(o_code, 0x20), 0, size)
        }
    }

    function atceshi(address _addr) public view returns (uint size) {
        assembly {
            // retrieve the size of the code, this needs assembly
            size := extcodesize(_addr)
        }
    }
}

