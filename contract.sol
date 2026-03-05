// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract Escrow {
    
    enum DealStatus { INITIATED, APPROVED, COMPLETED, REFUNDED, CANCELLED}

    struct DealData {
        address sender;
        address receiver;
        uint amount;
        uint time;
        uint ID;
        DealStatus status;
    }
    
    mapping(uint => DealData) public deals;
    mapping(address => uint[]) public userDeals;
    
    uint dealId = 1;
    address public immutable owner;
    bool public paused;
    bool private locked;

    event dealCreated(address indexed sender, address indexed receiver, uint time, uint amount, uint dealId, DealStatus status);
    event dealApproved(address indexed sender, uint indexed dealId, DealStatus status);
    event dealCompleted(address indexed receiver, uint amount, uint indexed dealId, DealStatus status);
    event dealRefunded(address indexed sender, uint amount, uint indexed dealId, DealStatus status);
    event dealCanceled(address indexed sender, uint amount, uint indexed dealId, DealStatus status);

    modifier onlyOwner() {
        require(msg.sender == owner, "You are not the owner");
        _;
    }

    modifier whenNotPaused() {
        require(paused == false, "contract is paused");
        _;
    }
    
    modifier nonReentrant() {
        require(!locked, "reentrant");
        locked = true;
        _;
        locked = false;
    }
    
    constructor() {
        owner = msg.sender;
    }

    function pause() public onlyOwner{
        paused = true;
    }

    function unPause() public onlyOwner {
        paused = false;
    }
    
    // create deal
    function createDeal(address receiver) public payable whenNotPaused nonReentrant{
        require(msg.value > 0, "send ETH");
        require(receiver != address(0), "invalid receiver");
        require(receiver != msg.sender, "cannot escrow to yourself");
        uint currentId = dealId;
        deals[currentId] = DealData({
            sender: msg.sender,
            receiver: receiver,
            amount: msg.value,
            time: block.timestamp,
            ID: currentId,
            status : DealStatus.INITIATED
        });
        userDeals[msg.sender].push(currentId);
        userDeals[receiver].push(currentId);
        dealId++;

        emit dealCreated(msg.sender, receiver, block.timestamp, msg.value, currentId, DealStatus.INITIATED);
    }

    //approve deal
    function approveDeal(uint dealId) public whenNotPaused {
        DealData storage deal = deals[dealId];
        require(deal.status == DealStatus.INITIATED, "deal isn't initiated or its already completed");
        require(msg.sender == deal.sender, "only deal creator can approve this deal");
        deal.status = DealStatus.APPROVED;

        emit dealApproved(msg.sender, dealId, deal.status);
    }

    //complete deal
    function completeDeal(uint dealId) public nonReentrant whenNotPaused{
        DealData storage deal = deals[dealId];
        require(deal.status == DealStatus.APPROVED , "deal isn't approved or its already completed");
        require(msg.sender == deal.receiver, "this deal can be complete by reciever only");
        deal.status = DealStatus.COMPLETED;
        uint amount = deal.amount;
        deal.amount = 0;
        (bool success, ) = payable(msg.sender).call{value: amount}("");
        require(success, "trasnfer failed");

        emit dealCompleted(msg.sender, amount, dealId, deal.status);
    }

    //cancel deal
    function cancelDeal(uint dealId) public whenNotPaused nonReentrant{
        DealData storage deal = deals[dealId];
        require(deal.status == DealStatus.INITIATED , "deal isn't initiated or its already completed");
        require(msg.sender == deal.sender, "this deal can be cancel by sender only");
        deal.status = DealStatus.CANCELLED;
        uint amount = deal.amount;
        deal.amount = 0;
        (bool success, ) = payable(msg.sender).call{value: amount}("");
        require(success, "trasnfer failed");

        emit dealCanceled(msg.sender, amount, dealId, deal.status);
    }

    //refund deal
    function refundDeal(uint dealId) public whenNotPaused nonReentrant onlyOwner{
        DealData storage deal = deals[dealId];
        require(deal.status == DealStatus.APPROVED , "only approved deal can be refund");
        deal.status = DealStatus.REFUNDED;
        uint amount = deal.amount;
        deal.amount = 0;
        (bool success, ) = payable(deal.sender).call{value: amount}("");
        require(success, "trasnfer failed");

        emit dealRefunded(owner, amount, dealId, deal.status);
    }

    function getDeal(uint dealId) public view returns (address sender, address receiver, uint amount,uint time, DealStatus status) {
        DealData storage deal = deals[dealId];
        return (deal.sender, deal.receiver,deal.amount,deal.time,deal.status); 
    }

    function getUserDeals(address usr) public view returns(uint[] memory){
        return userDeals[usr];
    }    

    function getMyDeals() public view returns(uint[] memory) {
        return userDeals[msg.sender];
    }

    function getTotalDeals() public view returns(uint) {
        return dealId - 1;
    }



}
