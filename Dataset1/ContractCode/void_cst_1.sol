contract A{}
contract B is A{
    constructor() public A(){}
}
contract C{
    constructor() {}
}
contract D is C{
    modifier aka(){_;}
    constructor() public C() {}
}
contract E is D{
    constructor() {}
}
contract F is B{
    constructor() public B() {}
}

contract G is C{
}

contract H is G{
    constructor() public G() {}
}
