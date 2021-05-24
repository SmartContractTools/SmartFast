contract A {
    uint x;
    constructor() public {
        x = 0;
    }
    function A() public {
        x = 1;
    }
    
    function test() public returns(uint) {
        return x;
    }
}

contract B {
    uint x;
    constructor() public {
        x = 0;
    }
    
    function test() public returns(uint) {
        return x;
    }
}

contract C {
    uint x;
    function C() public {
        x = 1;
    }  
    function test() public returns(uint) {
        return x;
    }
}
