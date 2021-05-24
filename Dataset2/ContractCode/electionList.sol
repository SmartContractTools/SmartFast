pragma solidity ^0.5.12;
/*
* This project is created to implement an election for 2019 Hong Kong local elections.
* Ofcause the Hong Kong government is not going to use it, but we have a chance to show that how an election can be done completely anonymously with blockchain
* Everyone can use this contract, but they must keep this statement here unchanged.
* Fight for freedom, Stand with Hong Kong
* Five Demands, Not One Less
* @secondphonejune2019 (You may find me via Telegram and Telegram only)
*/
/*
* This contract keeps the council list and candidate information. 
* A big problem here is how to include all candidate and council data into this contract effectively
*/
contract electionList{
	string public hashHead = "2019localelection";
	address payable public owner;
    //This one keeps the council list for easy checking by public
    //Information can be found in https://www.elections.gov.hk/dc2019/chi/intro_to_can/A.html
	string[] public councilList = ["","","","","","","","",
	"","","","","","",""
	];
	uint256 public councilNumber;
	//This one keeps the list of candidates grouped by council for easy checking
	mapping(string => string[]) public cadidateList;
	mapping(string => uint256) public candidateNumber;
	//address public dateTimeAddr = 0x1a6184CD4C5Bea62B0116de7962EE7315B7bcBce;
	//DateTime dateTime = DateTime(dateTimeAddr);
	//GMT+8, suppose it starts from 7th Nov 2019 9am in Hong Kong, it will be 7th Nov 2019 1am 
	//uint votingStartTime = dateTime.toTimestamp(2019,11,7,1); //7th Nov 2019 9am HKT
	//uint votingEndTime = dateTime.toTimestamp(2019,11,7,14); //7th Nov 2019 10pm HKT
	constructor() public{
	    owner = msg.sender;
	    councilNumber = councilList.length;
	    
	    cadidateList[""] = ["",""];
	    cadidateList[""] = ["",""];
	    cadidateList[""] = ["",""];
	    cadidateList[""] = ["",""];
	    cadidateList[""] = ["",""];
	    cadidateList[""] = ["","",""];
	    cadidateList[""] = ["","",""];
	    cadidateList[""] = ["","",""];
	    cadidateList[""] = ["","",""];
	    cadidateList[""] = ["",""];
	    cadidateList[""] = ["",""];
	    cadidateList[""] = ["",""];
	    cadidateList[""] = ["",""];
	    cadidateList[""] = ["",""];
	    cadidateList[""] = ["",""];
	    
	    for(uint i=0;i<councilNumber;i++){
	        candidateNumber[councilList[i]] = cadidateList[councilList[i]].length;
		}
	}
}