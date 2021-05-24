contract C {
    function f() internal returns (uint a) {
        a = 10;
		assembly {
            a := shr(a, 8) //reverse
        }
		return a;
    }
	
	function g() internal returns (uint a) {
        a = 10;
		assembly {
            a := shr(8, a) //good
        }
		return a;
    }
}