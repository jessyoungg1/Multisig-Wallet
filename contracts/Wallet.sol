//SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.7; //setting the version of solidity
pragma abicoder v2; //allows you to return a struct 

contract Wallet{

    //creating state variables - these will later be set in a contructor
    address[] public owners; //array of addresses named owners 
    Transfer[] public transferRequests; //an array of these objects - store all transfer requests
    uint[] public done; //Compute the number of approvals 
    address public owner; //create a state variable called owner of type address 
    uint public limit; //creating vairable of type unsigned integer called limit which represents how many of the owners needs to sign on 
    mapping(address => bool) public verify; // a mapping from an address to true/false called verify - confirms if an address is the owners or not 
    mapping(address => uint) public balance; //create a mapping called balance which input adress and outputs address balance
    mapping(address => mapping(uint => bool)) public approvals; //mapping[address][transferID] => true/false
    mapping(uint => uint) public computing; //mappping transfer ID to number of approvals

    struct Transfer{ //transfer requests
        uint idOfTransfer;
        address payable to;
        uint amount;
        bool approved;
    }

    event TransferRequestCreated(uint transferNumber, uint amount, address initiator, address reciever);
    event ApprovalReceived(uint transferNumber, uint NumberOfApprovals, address aprover);
    event TransferApproved(uint transferNumber);


    constructor(address owner2, address owner3, uint verifications){ //a function which is only run when the contract is deployed
        owner = msg.sender; 
        owners.push(msg.sender); //smart contract creator address is added to owners array  
        owners.push(owner2); //smart contract creator adds two more addresses when setting up contract 
        owners.push(owner3); 
        limit = verifications;
    }
    
    //require the sender to be a contract owner 
    modifier onlyOwners{ 
        bool isOwner = false;
        for(uint a = 0; a < owners.length; a = a+1){
            if(owners[a] == msg.sender){
                isOwner = true;
            }
        }
        require(isOwner == true);
        _; //This means run the function - (in theory this _ gets replaced with the function code ) 
    } 

            
    // public function = anyone can execute the function and get the variable from that state function
    // payable = a function which is going to recieve coins/tokens
    function deposit() public payable {}

    function getBalance() public view returns (uint) {
        return address(this).balance;
    }

    //Approve a transaction
    function createTransfer(address payable to, uint amount) public onlyOwners{
        require(address(this).balance >= amount);
        //adds the transfer to transferRequests array 
        emit TransferRequestCreated(transferRequests.length, amount, msg.sender, to);
        transferRequests.push(Transfer(transferRequests.length, to, amount, false));
    }    

    // msg.sender = ethereum address of function caller
    function approve(uint transferNumber) public onlyOwners {
        require(approvals[msg.sender][transferNumber] == false, "Transfer already approved by this address"); // Ensures each owner can only approve each transaction once
        require(transferRequests[transferNumber].approved == false, "Transfer already approved"); //Ensures transaction isnt already approved
        approvals[msg.sender][transferNumber] = true; //signs the transfer 
        emit ApprovalReceived(transferNumber, compute(transferNumber), msg.sender);
        //check if have enough confirmations
        if(compute(transferNumber)>= limit){
            transferRequests[transferNumber].approved = true;
            transferRequests[transferNumber].to.transfer(transferRequests[transferNumber].amount);
            emit TransferApproved(transferNumber);
        }
    }
        
    function compute(uint transferNumber) public view onlyOwners returns(uint){
        uint calc = 0;
        for (uint i = 0; i < owners.length; i++){
            if (approvals[owners[i]][transferNumber] == true){
                calc += 1;
            }
        }
        return calc;
    }

    function getTransferRequests() public view returns (Transfer[] memory){
        return transferRequests;
    }
}