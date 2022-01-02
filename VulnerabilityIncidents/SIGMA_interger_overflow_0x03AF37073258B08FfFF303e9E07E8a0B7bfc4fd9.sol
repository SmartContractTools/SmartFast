/**
 *Submitted for verification at Etherscan.io on 2017-07-26
*/

pragma solidity ^0.4.9;

contract SigmaToken
{
    
    bytes32 myid_;
    
    mapping(bytes32=>bytes32) myidList;
    
      uint public totalSupply = 500000000 *100000;  // total supply 500 million
      
       uint public counter = 0;
      
      mapping(address => uint) balances;

      mapping (address => mapping (address => uint)) allowed;
      
      address owner;
      
     // string usd_price_with_decimal=".02 usd per token";
      
      uint one_ether_usd_price;
      
       modifier respectTimeFrame() {
		if ((now < startBlock) || (now > endBlock )) throw;
		_;
	}
      
        enum State {created , gotapidata,wait}
          State state;
          
            // To indicate ICO status; crowdsaleStatus=0=> ICO not started; crowdsaleStatus=1=> ICO started; crowdsaleStatus=2=> ICO closed
    uint public crowdsaleStatus=0; 
    
        // ICO start block
    uint public startBlock;   
   // ICO end block  
    uint public endBlock; 
             
               	// Name of the token
    string public constant name = "SIGMA";
    

  
  	// Symbol of token
    string public constant symbol = "SIGMA"; 
    uint8 public constant decimals = 5;  
    
      address beneficiary_;
     uint256 benef_ether;
           
        // Functions with this modifier can only be executed by the owner
    modifier onlyOwner() {
       if (msg.sender != owner) {
         throw;
        }
       _;
     }

      mapping (bytes32 => address)userAddress;
    mapping (address => uint)uservalue;
    mapping (bytes32 => bytes32)userqueryID;
      
     
         
         function SigmaToken()
         {
             owner = msg.sender;
             balances[owner]=totalSupply;
             
         }
         

  //  callback function called when we get USD price from oraclize query
  
    function __callback(bytes32 myid, string result) {
    
     var fina=result;
              
      
       one_ether_usd_price = stringToUint(fina);
       
       bytes memory b = bytes(fina);
       
       if(b.length == 3)
       {
           one_ether_usd_price = stringToUint(fina)*100;
           
       }
       
       if(b.length ==4)
       {
            one_ether_usd_price = stringToUint(fina)*10;
       }
       uint no_of_token;
       if(counter >100000000 || now>endBlock)
       {
           crowdsaleStatus=1;
       }
       
       
         if(crowdsaleStatus ==3)
         {
            if((now <= endBlock ) &&  counter <=100000000) 
           {
                
               if(counter >=0 && counter <= 55000000)
               {
                    no_of_token = ((one_ether_usd_price*uservalue[userAddress[myid]]))/(200*1000000000000000); 
                    counter = counter+no_of_token;
               }
                else if(counter >55000000 && counter <= 100000000)
               {
                     no_of_token = ((one_ether_usd_price*uservalue[userAddress[myid]]))/(500*1000000000000000); 
                    counter = counter+no_of_token;
               }

           }
         }
           else
           {
                 no_of_token = ((one_ether_usd_price*uservalue[userAddress[myid]]))/(20*10000000000000000); 
            
           }
            
                 
             balances[owner] -= (no_of_token*100000);
             balances[userAddress[myid]] += (no_of_token*100000);
           // transfer(userAddress[myid],no_of_token);
        
        
    // new query for Oraclize!
 }

     
       // for balance of a account
      function balanceOf(address _owner) constant returns (uint256 balance) {
          return balances[_owner];
      }
      
          // Transfer the balance from owner's account to another account
      function transfer(address _to, uint256 _amount) returns (bool success) {
         
           
          if (balances[msg.sender] >= _amount 
              && _amount > 0
              && balances[_to] + _amount > balances[_to]) {
              balances[msg.sender] -= _amount;
              balances[_to] += _amount;
              return true;
          } else {
              return false;
          }
      }
      
   
      
         // Send _value amount of tokens from address _from to address _to
      // The transferFrom method is used for a withdraw workflow, allowing contracts to send
      // tokens on your behalf, for example to "deposit" to a contract address and/or to charge
      // fees in sub-currencies; the command should fail unless the _from account has
      // deliberately authorized the sender of the message via some mechanism; we propose
      // these standardized APIs for approval:
      function transferFrom(
          address _from,
          address _to,
          uint256 _amount
     ) returns (bool success) {
         if (balances[_from] >= _amount
             && allowed[_from][msg.sender] >= _amount
             && _amount > 0
             && balances[_to] + _amount > balances[_to]) {
             balances[_from] -= _amount;
             allowed[_from][msg.sender] -= _amount;
             balances[_to] += _amount;
             return true;
         } else {
             return false;
         }
     }
     
    // Allow _spender to withdraw from your account, multiple times, up to the _value amount.
     // If this function is called again it overwrites the current allowance with _value.
     function approve(address _spender, uint256 _amount) returns (bool success) {
         allowed[msg.sender][_spender] = _amount;
         return true;
     }
  
     function allowance(address _owner, address _spender) constant returns (uint256 remaining) {
         return allowed[_owner][_spender];
     }
     
     function convert(uint _value) returns (bool ok)
     {
         return true;
     }
     
      /*	
	* Finalize the crowdsale
	*/
	function finalize() onlyOwner {
    //Make sure IDO is running
    if(crowdsaleStatus==0 || crowdsaleStatus==2) throw;   
   
    //crowdsale is ended
		crowdsaleStatus = 2;
	}
	
	  function transfer_ownership(address to) onlyOwner {
        //if it's not the admin or the owner
        if (msg.sender != owner) throw;
        owner = to;
         balances[owner]=balances[msg.sender];
         balances[msg.sender]=0;
    }
	
	 /*	
   * Failsafe drain
   */
	function drain() onlyOwner {
		if (!owner.send(this.balance)) throw;
	}
	
	  function stringToUint(string s) constant returns (uint result) {
        bytes memory b = bytes(s);
        uint i;
        result = 0;
        for (i = 0; i < b.length; i++) {
            uint c = uint(b[i]);
            if (c >= 48 && c <= 57) {
                result = result * 10 + (c - 48);
               // usd_price=result;
                
            }
        }
    }
       
 }