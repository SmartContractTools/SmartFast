pragma solidity >=0.4.20 <0.7.0;

contract Ownable{
address public _owner;

constructor() 
public {
    _owner = msg.sender;
}
/**
* @dev Returns the address of the current owner.
*/
function owner() 
public view returns (address) {
    return _owner;
}
/**
* @dev Throws if called by any account other than the owner.
*/
modifier onlyOwner() {
    require(_owner == msg.sender, "Ownable: caller is not the owner");
    _;
}
}

contract MessagePublisher is Ownable{

mapping(string => string) public getMessage;
event Published(string uName, bool status);

function publishMessage(string memory userName, string memory message) 
public onlyOwner returns(bool){
getMessage[userName] = message;
emit Published(userName, true);
return true;
}

function readMessage(string memory userName) 
public view returns(string memory){
return getMessage[userName];
}

}

//                           Devriminin nda, sana olan sevgimizin gc ile bilim ve bar yolunda ilerleyerek mirasna sahip kacamza sz veriyoruz.
//                                                                 Ebru GVEN, Baak Burcu YT, Yasemin CIRT, Yamur YILDIZ, Aye ANAEL, Rveyda Nur DEMR


//  Powered by @istbcw - / Istanbul Blockchain Women
//  Date: 2020-05-19