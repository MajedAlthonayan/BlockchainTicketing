// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.10;

import "../interfaces/ITicketNFT.sol";

contract TicketNFT is ITicketNFT {
    //TODO:chceck whether should be public or not
    string public eventName;
    uint256 public creator;
    uint256 public maxNumberOfTickets;
    uint256 public ticketCount;
    uint256 public price; 
    
    mapping(uint256 => address) public ticketOwners;
    mapping(uint256 => address) public ticketApproved;
    mapping(uint256 => string) public ticketHolderNames;
    mapping(uint256 => uint256) public ticketExpiryDates;
    mapping(uint256 => bool) public ticketUsedFlags;


    
    constructor (string memory _eventName, uint256 _maxNumberOfTickets, uint256 _price) {
        //TODO: make sure creator is the caller of primary market and not the primary market itself 
        creator = msg.sender;
        eventName = _eventName;
        maxNumberOfTickets = _maxNumberOfTickets;

    }
    function creator() external view override returns (address){
        return creator;
    }

    function ticketCount() external view override returns (uint256){
        return ticketCount;
    }

    function price() external view override returns (uint256){
        return price;
    }
    
    function maxNumberOfTickets() external view override returns (uint256){
        return maxNumberOfTickets;
    }


    function eventName() external view override returns (string memory){
        return eventName;
    }

    function mint(address holder, string memory holderName) external returns (uint256 id){
        // TODO: The caller must be the primary market, where creator is the address of the user who called `createNewEvent` in the primary market
        require(msg.sender == creator, "The caller must be the primary market!");
        require(ticketCount < maxNumberOfTickets, "Maximum number of tickets has been reached");

        uint256 expiryDate = block.timestamp + 10 days;
        uint256 ticketID = ticketCount;

        ticketOwners[ticketID] = holder;
        ticketApproved[ticketID] = 0x0;
        ticketHolderNames[ticketID] = holderName;
        ticketExpiryDates[ticketID] = expiryDate;
        ticketUsedFlags[ticketID] = false;

        ticketCount++;

        emit Transfer(0x0, holder, ticketID);

        return ticketID;

    }

    function balanceOf(address holder) external view override returns (uint256 balance){
        uint256 sum = 0 ;
        for(uint256 i = 0; i < ticketCount; i++){
            if(ticketOwners[i] == holder){
                sum++;
            }
        }
        return sum;
    }

    function holderOf(uint256 ticketID) external view returns (address holder){
        require(ticketID < ticketCount, "Ticket does not exist");
        return ticketOwners[ticketID];
    }

    function transferFrom(
        address from,
        address to,
        uint256 ticketID
    ) external {

        require(from != 0x0, "Cannot be the 0 address");
        require(to != 0x0, "Cannot be the 0 address");
        require(ticketUsedFlags[ticketID] == false, "Cannot send expired tickets" );
        require(ticketOwners[ticketID] == msg.sender || ticketApproved[ticketID] == msg.sender, "Caller must own or be approved to move the ticket");

        ticketOwners[ticketID] = to;
        ticketApproved[ticketID] = 0x0;
        ticketHolderNames[ticketID] = "";

        emit Transfer(from, to, ticketID);
        emit Approval(ticketOwners[ticketID], 0x0, ticketID);
    }
    
    function approve(address to, uint256 ticketID) external{

        require(ticketOwners[ticketID] == msg.sender,"Caller must own the ticket");
        require(ticketID < ticketCount, "Ticket does not exist");

        ticketApproved[ticketID] = to;

        emit Approval(ticketOwners[ticketID], to, ticketID);
    }

    function getApproved(uint256 ticketID) external view returns (address operator) {
            require(ticketID < ticketCount, "Ticket does not exist");
            return(ticketApproved[ticketID]);
        }
    
    function holderNameOf(uint256 ticketID) external view returns (string memory holderName){
            require(ticketID < ticketCount, "Ticket does not exist");
            return ticketHolderNames[ticketID];
        }

    function updateHolderName(uint256 ticketID, string calldata newName) external{
            require(msg.sender == ticketOwners[ticketID],"Only the current holder can change the name");
            require(ticketID < ticketCount, "Ticket does not exist");

            ticketHolderNames[ticketID] = newName;
        }

    function setUsed(uint256 ticketID) external{
        require(ticketID < ticketCount, "Ticket does not exist");
        require(ticketUsedFlags[ticketID] == false, "Ticket must not already be used");
        require(ticketExpiryDates[ticketID] >= block.timestamp, "Ticket must not already be expired");
        require(msg.sender == creator, "Only the creator of this collection can call this function");

        ticketUsedFlags[ticketID] = true;
    }


    function isExpiredOrUsed(uint256 ticketID) external view returns (bool){
        require(ticketID < ticketCount, "Ticket does not exist");
        // logical OR will return true if either is true 
        return ticketUsedFlags[ticketID] || (block.timestamp > ticketExpiryDates[ticketID]);


    }
}



   