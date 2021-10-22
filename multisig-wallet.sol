pragma solidity 0.8.7; //setting the version of solidity
pragma abicoder v2; //allows you to return a struct 

contract Wallet{

    //creating state variables - these will later be set in a contructor
    address[] owners; //array of addresses named owners 
    address owner; //create a state variable called owner of type address 
    uint limit; //creating vairable of type unsigned integer called limit which represents how many of the owners needs to sign on 
    mapping(address => bool) verify; // a mapping from an address to true/false called verify - confirms if an address is the owners or not 

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
    
    struct Transfer{ //transfer requests
        uint idOfTransfer;
        address payable to;
        uint amount;
        bool approved;
    }
    
    event TransferRequestCreated(uint transferNumber, uint amount, address initiator, address reciever);
    event ApprovalReceived(uint transferNumber, uint NumberOfApprovals, address aprover);
    event TransferApproved(uint transferNumber);
    
    Transfer[] transferRequests; //an array of these objects - store all transfer reuests 

    mapping (address => uint) balance; //create a mapping called balance which input adress and outputs address balance
    
    // public function = anyone can executethe function andget the variable from that state function
    // payable = a function which is going to recieve coins/tokens
    function deposit() public payable {}

    function getBalance() public view returns (uint) {
        return address(this).balance;
    }

    mapping(address => mapping(uint => bool)) approvals;
    //mapping[address][transferID] => true/false

    //Approve a transaction
    function createTransfer(address payable to, uint amount) public onlyOwners{
        require(address(this).balance >= amount);
        //adds the transfer to transferRequests array 
        emit TransferRequestCreated(transferRequests.length, amount, msg.sender, to);
        transferRequests.push(Transfer(transferRequests.length, to, amount, false));
    }    

    // msg.sender = ethereum address of function caller
    function approve(uint transferNumber) public onlyOwners{
        require(approvals[msg.sender][transferNumber] == false);// Ensures each owner can only approve each transaction once
        require(transferRequests[transferNumber].approved == false);//Ensures transaction isnt already approved
        approvals[msg.sender][transferNumber] = true; //signs the transfer 
        emit ApprovalReceived(transferNumber, compute(transferNumber), msg.sender);
        //check if have enough confirmations
        if(compute(transferNumber)>= limit){
            transferRequests[transferNumber].approved = true;
            transferRequests[transferNumber].to.transfer(transferRequests[transferNumber].amount);
            emit TransferApproved(transferNumber);
        }
    }
    
    //Compute the number of approvals
    uint[] done;
    mapping(uint => uint) computing; //mappping transfer ID to number of approvals
    
    function compute(uint transferNumber) public view onlyOwners returns(uint){
        uint calc = 0;
        for (uint i = 0; i < owners.length; i++){
            if (approvals[owners[i]][transferNumber] == true){
                calc += 1;
            }
        }
        return calc;
    }
    
//    function transfer (uint transferNumber) public payable {
//        transferRequests[transferNumber].approved = true;
//        transferRequests[transferNumber].to.transfer(transferRequests[transferNumber].amount);
//    }
    
    function getTransferRequests() public view returns (Transfer[] memory){
        return transferRequests;
    }
}
//:D!
