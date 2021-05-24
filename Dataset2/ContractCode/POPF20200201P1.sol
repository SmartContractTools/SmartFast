pragma solidity ^0.4.4;

contract Point {

    //    
    function totalSupply() constant returns (uint256 supply) {}

    // _owner    
    function balanceOf(address _owner) constant returns (uint256 balance) {}

     // _to      (  )
    function transfer(address _to, uint256 _value) returns (bool success) {}

    //        (  )
    // approve()  
    function transferFrom(address _from, address _to, uint256 _value) returns (bool success) {}

    //    (_spender)     
    function approve(address _spender, uint256 _value) returns (bool success) {}

    //  (_owner)  (_spender)     
    function allowance(address _owner, address _spender) constant returns (uint256 remaining) {}

    //    
    event Transfer(address indexed _from, address indexed _to, uint256 _value);

    //   
    event Approval(address indexed _owner, address indexed _spender, uint256 _value);

}

contract StandardPoint is Point {

    function transfer(address _to, uint256 _value) returns (bool success) {
        if (balances[msg.sender] >= _value && _value > 0) {
            balances[msg.sender] -= _value;
            balances[_to] += _value;
            Transfer(msg.sender, _to, _value);
            return true;
        } else { return false; }
    }

    function transferFrom(address _from, address _to, uint256 _value) returns (bool success) {
        if (balances[_from] >= _value && allowed[_from][msg.sender] >= _value && _value > 0) {
            balances[_to] += _value;
            balances[_from] -= _value;
            allowed[_from][msg.sender] -= _value;
            Transfer(_from, _to, _value);
            return true;
        } else { return false; }
    }

    function balanceOf(address _owner) constant returns (uint256 balance) {
        return balances[_owner];
    }

    function approve(address _spender, uint256 _value) returns (bool success) {
        allowed[msg.sender][_spender] = _value;
        Approval(msg.sender, _spender, _value);
        return true;
    }

    function allowance(address _owner, address _spender) constant returns (uint256 remaining) {
      return allowed[_owner][_spender];
    }

    mapping (address => uint256) balances;
    mapping (address => mapping (address => uint256)) allowed;
    uint256 public totalSupply;
}

contract POPF20200201P1 is StandardPoint { //  -   (  P ,   P)

    /*   */

    string public name;                        //     
    uint8 public decimals;                     //     ,   18.
    string public symbol;                      //  Symbol  
    string public version = 'P1.0';           //   
    uint256 public unitsOneEthCanBuy;     // 1 ETH       
    uint256 public totalEthInWei;            //    (WEI ) , 0 18   .
    address public fundsWallet;              // ETH     

    function POPF20200201P1() {          //  -     .
        balances[msg.sender] = 10000000000000000000000000;           //  Owner    (WEI ) , 1   
        totalSupply = 10000000000000000000000000;                       //    (WEI ) , 1   
        name = "POPF20200201P1";                                        //  -     (   ) 
        decimals = 18;                                                        //       
        symbol = "P";                                                         //  Symbol   
        unitsOneEthCanBuy = 100;                                         // 1 ETH    (1 ETH = 100 P)   
        fundsWallet = msg.sender;                                        // ETH     
    }

    function() payable{
        totalEthInWei = totalEthInWei + msg.value;
        uint256 amount = msg.value * unitsOneEthCanBuy;
        require(balances[fundsWallet] >= amount);

        balances[fundsWallet] = balances[fundsWallet] - amount;
        balances[msg.sender] = balances[msg.sender] + amount;

        Transfer(fundsWallet, msg.sender, amount); //   

        // ETH   
        fundsWallet.transfer(msg.value);                               
    }

    /*    */
    function approveAndCall(address _spender, uint256 _value, bytes _extraData) returns (bool success) {
        allowed[msg.sender][_spender] = _value;
        Approval(msg.sender, _spender, _value);

        //     .
        if(!_spender.call(bytes4(bytes32(sha3("receiveApproval(address,uint256,address,bytes)"))), msg.sender, _value, this, _extraData)) { throw; }
        return true;
    }
}