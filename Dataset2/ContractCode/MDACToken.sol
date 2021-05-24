/**
 *Submitted for verification at Etherscan.io on 2020-04-16
*/

pragma solidity ^0.4.25;

contract ERC20Interface {
    // tokenpublicgettertotalSupply().
    function totalSupply() public constant returns (uint);
    //tokenOwnertoken 
    function balanceOf(address tokenOwner) public constant returns (uint balance);
    //_to_valuetokentotokenstoken
    function transfer(address to, uint tokens) public returns (bool success);
    //spendertokenstoken
    function approve(address spender, uint tokens) public returns (bool success);
    //fromtotokenstokenapprove
    function transferFrom(address from, address to, uint tokens) public returns (bool success);
    //_spender_ownertoken
    function allowance(address tokenOwner, address spender) public constant returns (uint remaining);


    event Transfer(address indexed from, address indexed to, uint tokens);
    event Approval(address indexed tokenOwner, address indexed spender, uint tokens);
    event ReportFormEvent(address indexed spender,string content);
}

contract Ownable {
  address public owner;  
  
  mapping (address => bool) public finances;
  
  event addFinanceEvent(address indexed newFinance, bool success);
  event delFinanceEvent(address indexed newFinance, bool success);
  
   /**
   * @dev 
   */
  constructor() public payable {
    owner = msg.sender;
    finances[msg.sender] = true;
  }
  
  /**
   * @dev 
   */
    modifier onlyOwner() {
        require(msg.sender == owner);
        _;
    }
      
    modifier onlyFinance() {
        require(finances[msg.sender] == true);
        _;
    }
  
    /**
    * @dev 
    * @param newOwner .
    */
    function transferOwnership(address newOwner) onlyOwner public {
        require(newOwner != address(0));
        owner = newOwner;
    }
  
  
    function addFinance(address newFinance) onlyOwner public returns (bool success){
        require(newFinance != address(0));
        require(finances[newFinance] != true);
        
        finances[newFinance] = true;
        
        bool isSuccess = finances[newFinance];
        emit addFinanceEvent(newFinance, isSuccess);
        return isSuccess;
    }
    
    function delFinance(address finance) onlyOwner public returns (bool success){
        require(finance != address(0));
        require(finances[finance] == true);
        
        delete finances[finance];
        emit delFinanceEvent(finance, finances[finance]);
        return true;
    }
}


contract MDACToken is ERC20Interface, Ownable {
  string public name;
  string public symbol;
  uint8 public decimals;
  uint256 public totalSupply;


  mapping (address => uint256) public balanceOf;

  mapping (address => mapping (address => uint256)) public allowanceOf;

   constructor(string _tokenName,string _tokenSymbol,uint8 _tokenDecimals,uint256 _tokenTotalSupply) public payable {
      name = _tokenName;// token
      symbol = _tokenSymbol;// token
      decimals = _tokenDecimals;// 
      totalSupply = _tokenTotalSupply * 10 ** uint256(decimals);// 
      balanceOf[msg.sender] = totalSupply;// token
   }
   
    function _transfer(address _from, address _to, uint _value) internal {
       require(_to != 0x0);
       require(balanceOf[_from] >= _value);
       require(balanceOf[_to] + _value > balanceOf[_to]);
       uint previousBalances = balanceOf[_from] + balanceOf[_to];
       balanceOf[_from] -= _value;
       balanceOf[_to] += _value;
       assert(balanceOf[_from] + balanceOf[_to] == previousBalances);
       emit Transfer(_from, _to, _value);
    }

    function transfer(address _to, uint256 _value) public returns (bool success) {
       _transfer(msg.sender, _to, _value);
       return true;
    }

    function financeReportForm(string content) public onlyFinance returns (bool success) {
       require(bytes(content).length < 100);
       
       emit ReportFormEvent(msg.sender, content);
       return true;
    }

    function transferFrom(address _from, address _to, uint256 _value) public returns (bool success) {
       require(allowanceOf[_from][msg.sender] >= _value);
       allowanceOf[_from][msg.sender] -= _value;
       _transfer(_from, _to, _value);
       return true;
   }

    function approve(address _spender, uint256 _value) public returns (bool success) {
       allowanceOf[msg.sender][_spender] = _value;
       emit Approval(msg.sender, _spender, _value);
       return true;
   }

   function allowance(address _owner, address _spender) view public returns (uint remaining){
     return allowanceOf[_owner][_spender];
   }

  function totalSupply() public constant returns (uint totalsupply){
      return totalSupply;
  }

  function balanceOf(address tokenOwner) public constant returns(uint balance){
      return balanceOf[tokenOwner];
  }
}