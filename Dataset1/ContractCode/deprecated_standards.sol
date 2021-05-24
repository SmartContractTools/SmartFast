contract ContractWithDeprecatedReferences {
    bytes32 globalBlockHash = block.blockhash(0);
    uint lastUpdated = now;

    // Deprecated: Change constant -> view
    function functionWithDeprecatedThrow() public constant {
        // Deprecated: Change msg.gas -> gasleft()
        if(msg.gas == msg.value) {
            // Deprecated: Change throw -> revert()
            throw;
        }
    }

    function fiveMinutesHavePassed() public view returns (bool) {
	   return ((now - lastUpdated) >= 5 years);
    }

    function varbianliang() public view returns (bool) {
    	uint aa = 1;
    	var bb = 10;
    	//var cc;
    	for(var i=1; i<200; i++)
    	{
                aa = aa + 1;
    	}
    }

    // Deprecated: Change constant -> view
    function functionWithDeprecatedReferences() public constant {
        // Deprecated: Change sha3() -> keccak256()
        bytes32 sha3Result = sha3("test deprecated sha3 usage");
    }
    // Deprecated: Change constant -> view
    function functionWithDeprecatedReferences_1() public constant {
        // Deprecated: Change block.blockhash() -> blockhash()
        bytes32 blockHashResult = block.blockhash(0);
    }
    // Deprecated: Change constant -> view
    function functionWithDeprecatedReferences_2() public constant {
        // Deprecated: Change callcode() -> delegatecall()
        address(this).callcode();
    }
    // Deprecated: Change constant -> view
    function functionWithDeprecatedReferences_3() public constant {
        // Deprecated: Change suicide() -> selfdestruct()
        suicide(address(0));
    }
}
