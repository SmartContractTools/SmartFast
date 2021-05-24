contract Incorrectconstructor { //bad
    address owner;
    function Incorrectconstructo() {
	   owner = msg.sender;
    }

    modifier ifowner()
    {
    	require(msg.sender == owner);
    	_;
    }

    function withdrawmoney() ifowner {
	   msg.sender.transfer(address(this).balance);
    }

    function() {revert();}
}

contract A {
    address owner;
    function B() {
	   owner = msg.sender;
    }

    modifier ifowner()
    {
    	require(msg.sender == owner);
    	_;
    }

    function withdrawmoney() ifowner {
	   msg.sender.transfer(address(this).balance);
    }
}

contract Incorrectconstructor1 { //good
    address owner;

    constructor() {
	   owner = msg.sender;
    }

    function Incorrectconstructor() {
	
    }

    modifier ifowner()
    {
    	require(msg.sender == owner);
    	_;
    }

    function withdrawmoney() ifowner {
	   msg.sender.transfer(address(this).balance);
    }
}

contract Incorrectconstructor2 { //good
    address owner;

    function Incorrectconstructor2() {
	   owner = msg.sender;
    }

    function Incorrectconstructor() {
	
    }

    modifier ifowner()
    {
    	require(msg.sender == owner);
    	_;
    }

    function withdrawmoney() ifowner {
	   msg.sender.transfer(address(this).balance);
    }
}
