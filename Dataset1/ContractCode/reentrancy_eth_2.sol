pragma solidity ^0.4.24;

contract Reentrancy {
    mapping (address => uint) userBalance;
   
    function getBalance(address u) view public returns(uint){
        return userBalance[u];
    }

    function addToBalance() payable public{
        userBalance[msg.sender] += msg.value;
    }

    function withdrawBalance() public{
        // send userBalance[msg.sender] ethers to msg.sender
        // if mgs.sender is a contract, it will call its fallback function
        if( ! (msg.sender.call.value(userBalance[msg.sender])() ) ){ //eth
            revert();
        }
        userBalance[msg.sender] = 0;
    }   

    function withdrawBalance_bad2() public{
        // send userBalance[msg.sender] ethers to msg.sender
        // if mgs.sender is a contract, it will call its fallback function
        require(msg.sender.call.value(userBalance[msg.sender])()); //eth
        userBalance[msg.sender] = 0;
    } 

    function withdrawBalance_bad3() public{
        // send userBalance[msg.sender] ethers to msg.sender
        // if mgs.sender is a contract, it will call its fallback function
        msg.sender.call.value(userBalance[msg.sender])(); //eth
        userBalance[msg.sender] = 0;
    }   


    function withdrawBalance_good() public{
        // send userBalance[msg.sender] ethers to msg.sender
        // if mgs.sender is a contract, it will call its fallback function
        if( ! (msg.sender.send(userBalance[msg.sender]) ) ){ //no-gas-eth
            revert();
        }
        userBalance[msg.sender] = 0;
    }

    function withdrawBalance_good1() public{
        // send userBalance[msg.sender] ethers to msg.sender
        // if mgs.sender is a contract, it will call its fallback function
	if(userBalance[msg.sender]>1)
	{
            if( ! (msg.sender.call.value(0)() ) ){ //no-eth
                revert();
            }
	    userBalance[msg.sender] = userBalance[msg.sender] - 1;
	}      
    }

    function withdrawBalance_good2() public{
        // send userBalance[msg.sender] ethers to msg.sender
        // if mgs.sender is a contract, it will call its fallback function
	if(userBalance[msg.sender]>1)
	{
	    uint aa = 0;
            if( ! (msg.sender.call.value(aa)() ) ){ //no-eth
                revert();
            }
	    userBalance[msg.sender] = userBalance[msg.sender] - aa;
	}      
    }

    function withdrawBalance_fixed() public{
        // To protect against re-entrancy, the state variable
        // has to be change before the call
        uint amount = userBalance[msg.sender];
        userBalance[msg.sender] = 0;
        if( ! (msg.sender.call.value(amount)() ) ){ //good
            revert();
        }
    }   

    function withdrawBalance_fixed_1() public{
        // send() and transfer() are safe against reentrancy
        // they do not transfer the remaining gas
        // and they give just enough gas to execute few instructions    
        // in the fallback function (no further call possible)
        msg.sender.transfer(userBalance[msg.sender]); //no-gas-eth
        userBalance[msg.sender] = 0;
    }

    function withdrawBalance_fixed_2() public{
        // send() and transfer() are safe against reentrancy
        // they do not transfer the remaining gas
        // and they give just enough gas to execute few instructions    
        // in the fallback function (no further call possible)
        msg.sender.transfer(0); //no-gas-no-eth
        userBalance[msg.sender] = userBalance[msg.sender] - 0;
    }   
   
    function withdrawBalance_fixed_5() public{
        // send() and transfer() are safe against reentrancy
        // they do not transfer the remaining gas
        // and they give just enough gas to execute few instructions    
        // in the fallback function (no further call possible)
	uint aa = 0;
        msg.sender.transfer(aa); //no-gas-no-eth
        userBalance[msg.sender] = userBalance[msg.sender] - aa;
    }   

    function withdrawBalance_fixed_3() public{
        // The state can be changed
        // But it is fine, as it can only occur if the transaction fails 
        uint amount = userBalance[msg.sender];
        userBalance[msg.sender] = 0;
        if( ! (msg.sender.call.value(amount)() ) ){ //good
            userBalance[msg.sender] = amount;
        }
    }   
    function withdrawBalance_fixed_4() public{
        // The state can be changed
        // But it is fine, as it can only occur if the transaction fails 
        uint amount = userBalance[msg.sender];
        userBalance[msg.sender] = 0;
        if( (msg.sender.call.value(amount)() ) ){ //good
            return;
        }
        else{
            userBalance[msg.sender] = amount;
        }
    }   

    function withdrawBalance_nested() public{
        uint amount = userBalance[msg.sender];
        if( ! (msg.sender.call.value(amount/2)() ) ){ //eth
            msg.sender.call.value(amount/2)();
            userBalance[msg.sender] = 0;
        }
    }   

}


contract Called{
    function f() public;
    uint counter;
    function callme(){
        if( ! (msg.sender.call.value(1)() ) ){ //benign
            throw;
        }
        counter += 1;
    }
}

contract ReentrancyEvent {

    mapping (address => uint) userBalance;

    event E();

    function test(Called c) public{

        c.f(); //event
        emit E();

    }

    function test_4() public{
	uint aa = 0;
        msg.sender.call.value(aa)(); //event
        emit E();
    }

    function test_1() public{
	uint aa = 0;
        msg.sender.transfer(aa); //no-gas-event、no-gas-no-eth
	userBalance[msg.sender] = userBalance[msg.sender] - aa;
        emit E();
    }   

    function test_2() public{
	uint amount = userBalance[msg.sender];
        userBalance[msg.sender] = 0;
        if( ! (msg.sender.call.value(amount)() ) ){ //good、event
            userBalance[msg.sender] = amount;
        }
        emit E();
    }  

    function test_5() public{
	uint amount = userBalance[msg.sender];
        userBalance[msg.sender] = 0;
        if( ! (msg.sender.send(amount) ) ){ //good、no-gas-event
            userBalance[msg.sender] = amount;
        }
        emit E();
    }

    function test_3() public{
	if( ! (msg.sender.send(userBalance[msg.sender]) ) ){ //good、no-gas-event
            revert();
        }
        emit E();
    }  
}

