// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.10;

import "../interfaces/IPrimaryMarket";
import "./TicketNFT";
import "./PurchaseToken";
import "../interfaces/IERC20";

/**
 * The primary market is the first point of sale for tickets.
 * It is responsible for minting tickets and transferring them to the purchaser.
 * The NFT to be minted is an implementation of the ITicketNFT interface and should be created (i.e. deployed)
 * when a new event NFT collection is created
 * In this implementation, the purchase price and the maximum number of tickets
 * is set when an event NFT collection is created
 * The purchase token is an ERC20 token that is specified when the contract is deployed.
 */

contract PrimaryMarket is IPrimaryMarket {
    uint256 public price; 
    address public creator;
    IERC20 public erc20Token;
    srting public holderName;
    TicketNFT public ticketCollection;

    constructor (adress _creator, string memory _name) {
        // in units of the ERC20 token.
        creator = _creator;
        name = _name;
    }

    /**
     *
     * @param eventName is the name of the event to create
     * @param price is the price of a single ticket for this event
     * @param maxNumberOfTickets is the maximum number of tickets that can be created for this event
     */
    function createNewEvent(
        string memory eventName,
        uint256 price,
        uint256 maxNumberOfTickets
    ) external returns (ITicketNFT ticketCollection) {
        ticketCollection = new TicketNFT(eventName, maxNumberOfTickets, price);

        emit EventCreated(creator, ticketCollection, eventName, price, maxNumberOfTickets);

        return ticketCollection;
    }
    /**
     * @notice Allows a user to purchase a ticket from `ticketCollectionNFT`
     * @dev Takes the initial NFT token holder's name as a string input
     * and transfers ERC20 tokens from the purchaser to the creator of the NFT collection
     * @param ticketCollection the collection from which to buy the ticket
     * @param holderName the name of the buyer
     * @return id of the purchased ticket
     */
    function purchase(
        address ticketCollection,
        string memory holderName
    ) external returns (uint256 id) {   
        // TODO:the purchaser will have to approve the amount before calling the purchase function
        require(PurchaseToken.allowance(msg.sender, creator) >= price);
        // TODO: transfer ERC20 tokens from the purchaser to the creator of the ticket NFT.
        PurchaseToken.transfer(creator,price);
        // TODO: Only the primary market should be able to mint tickets and all tickets should be represented by instances of the same ticket NFT.

        //TODO:  check that msg.sender is the holder

        uint256 id = ticketCollection.mint(msg.sender, holdername);

        emit Purchase(holder, ticketCollection, id, holderName);
    }

    // given a certain collection or event (concert) return its price 
    function getPrice(
        address ticketCollection
    ) external view returns (uint256 price) {
        return ticketCollection.price(); 
    }
}