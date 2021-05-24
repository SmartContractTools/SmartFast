contract tautologies{
    function bad1(uint x) {
		if(x >= 0){
		    //bad
		}
    }

    modifier bad3(uint x) {
		if(x >= 0){
		    //bad
		}
		_;
    }

    function bad8(uint8 y) returns (bool) {
		uint bb = 256;
		return (y < bb); // bad!
    }

    function bad2(uint8 y) returns (bool) {
		return (y < 256); // bad!
    }

    function bad4(int8 x) {
		if(x == -128){
		    //bad-not
		}
    }

    function bad5(uint8 y) {
		if(y != 256){
		    //bad
		}
    }

    function bad7(uint8 y) {
		uint aa = 256;
		if(y != aa){
		    //bad
		}
    }

    function bad6(uint8 x) {
		if(x == 257){
		    //bad-not
		}
    }

    modifier bad10(uint8 x) {
		if(x == 257){
		    //bad-not
		}
		_;
    }
}
