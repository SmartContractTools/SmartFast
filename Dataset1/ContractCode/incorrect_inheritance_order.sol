contract A {
    address owner;
    uint constant aa = 1;
    function AA() {}
}


contract B is A {
    address owner;
    uint constant aa = 1;
    function AA() {}
}

contract C{
    address owner;
    uint constant aa = 1;
}

contract D is B,C{
     
}

