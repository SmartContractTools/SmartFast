contract BaseContract{
    address owner;
    address owner1;
    address owner2;

    modifier isOwner(){
        require(owner == msg.sender);
	require(owner1 == msg.sender);
        _;
    }

}

contract DerivedContract is BaseContract{
    address owner;
    address owner1;
    address owner2;

    constructor(){
        owner = msg.sender;
    }

    function withdraw() isOwner() external{
        msg.sender.transfer(this.balance);
    }
}

contract DerivedContract1 is DerivedContract{
    address owner;
    address derived;
    address owner2;

    constructor(){
        owner = msg.sender;
    }

    function withdraw() isOwner() external{
        msg.sender.transfer(this.balance);
    }
}

contract DerivedContract_Base{
    address owner_1;
}

contract DerivedContract_1 is DerivedContract_Base{
    address owner_1;
    address owner_2;
}
