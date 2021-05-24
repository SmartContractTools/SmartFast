pragma solidity ^0.4.24;

contract TypoOneCommand {
    uint numberOne = 1;
    string numberstring = "";

    function alwaysOne() public {
        numberOne =+ 1; //bad
    }

    function alwaysOne_bad() public {
        numberOne =- 1; //bad
    }

    function alwaysOne_bad1() public {
        numberOne =* 1; //bad
    }

    function alwaysOne_bad2() public {
        numberOne =/ 1; //bad
    }

    function command_good() public {
	   numberstring = "numberOne =+ 2";
    }
}
