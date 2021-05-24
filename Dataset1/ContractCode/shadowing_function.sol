contract BaseContract{
    function aa(uint a,uint b) returns (uint) {
		return a;
    }
}

contract DerivedContract is BaseContract{
    function aa(uint a,uint b) returns (uint) {
		return b;
    }
    function bb(uint a,uint b) returns (uint) {
		return b;
    }
}

contract DerivedContract_1 is DerivedContract{
    function bb(uint a,uint b) returns (uint) {
		return b;
    }
}