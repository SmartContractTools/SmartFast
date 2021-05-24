contract BaseContract{
    address owner;

}

contract DerivedContract is BaseContract{
    address owner;
    address owner1;
}

contract DerivedContract_1 is DerivedContract{
    address owner1;
}