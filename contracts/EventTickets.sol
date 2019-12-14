pragma solidity ^0.5.0;

    /*
        The EventTickets contract keeps track of the details and ticket sales of one event.
     */

contract EventTickets {

    /*
        Create a public state variable called owner.
        Use the appropriate keyword to create an associated getter function.
        Use the appropriate keyword to allow ether transfers.
     */
    address payable public owner;
    uint   TICKET_PRICE = 100 wei;

    /*
        Create a struct called "Event".
        The struct has 6 fields: description, website (URL), totalTickets, sales, buyers, and isOpen.
        Choose the appropriate variable type for each field.
        The "buyers" field should keep track of addresses and how many tickets each buyer purchases.
    */
    struct Event {
        string description;
        string website;
        uint totalTickets;
        uint sales;
        mapping (address => uint) buyers;
        bool isOpen;
    }

    Event myEvent;

    /*
        Define 3 logging events.
        LogBuyTickets should provide information about the purchaser and the number of tickets purchased.
        LogGetRefund should provide information about the refund requester and the number of tickets refunded.
        LogEndSale should provide infromation about the contract owner and the balance transferred to them.
    */
    event LogBuyTickets(address indexed purchaser, uint indexed totalTickets);
    event LogGetRefund(address indexed refund, uint indexed totalTickets);
    event LogEndSale(address indexed owner, uint indexed transferBalance);
    /*
        Create a modifier that throws an error if the msg.sender is not the owner.
    */
    modifier isOwner(address _address) {require(msg.sender == owner,'You are not the owner');_;}
    modifier eventIsOpen() {require(myEvent.isOpen, 'Event needs to be open'); _;}

    /*
        Define a constructor.
        The constructor takes 3 arguments, the description, the URL and the number of tickets for sale.
        Set the owner to the creator of the contract.
        Set the appropriate myEvent details.
    */
    constructor(string memory description, string memory website, uint totalTickets) public {
        owner = msg.sender;
        myEvent = Event ({
            description: description,
            website: website,
            totalTickets: totalTickets,
            sales: 0,
            isOpen:true
        });
    }
    /*
        Define a function called readEvent() that returns the event details.
        This function does not modify state, add the appropriate keyword.
        The returned details should be called description, website, uint totalTickets, uint sales, bool isOpen in that order.
    */
    function readEvent()
        public view
        returns(string memory description, string memory website, uint totalTickets, uint sales, bool isOpen)
    {
        return (myEvent.description, myEvent.website, myEvent.totalTickets, myEvent.sales, myEvent.isOpen);
    }

    /*
        Define a function called getBuyerTicketCount().
        This function takes 1 argument, an address and
        returns the number of tickets that address has purchased.
    */
    function getBuyerTicketCount(address buyer) public view returns (uint){
        return myEvent.buyers[buyer];
    }
    /*
        Define a function called buyTickets().
        This function allows someone to purchase tickets for the event.
        This function takes one argument, the number of tickets to be purchased.
        This function can accept Ether.
        Be sure to check:
            - That the event isOpen
            - That the transaction value is sufficient for the number of tickets purchased
            - That there are enough tickets in stock
        Then:
            - add the appropriate number of tickets to the purchasers count
            - account for the purchase in the remaining number of available tickets
            - refund any surplus value sent with the transaction
            - emit the appropriate event
    */
function buyTickets(uint ticketBuy) public payable eventIsOpen() {

    uint total = (TICKET_PRICE * ticketBuy);
    uint surplus = (msg.value - total);
    require((myEvent.totalTickets - myEvent.sales) >= ticketBuy, 'not enough tickets remaining');
    require(msg.value >= total, 'not enough eth');
    require(myEvent.totalTickets >= ticketBuy, 'not enough tickets');
    myEvent.buyers[msg.sender] += ticketBuy;
    myEvent.sales += ticketBuy;
    msg.sender.transfer(surplus); //refund
    emit LogBuyTickets(msg.sender, ticketBuy);

}
    /*
        Define a function called getRefund().
        This function allows someone to get a refund for tickets for the account they purchased from.
        TODO:
            - Check that the requester has purchased tickets.
            - Make sure the refunded tickets go back into the pool of avialable tickets.
            - Transfer the appropriate amount to the refund requester.
            - Emit the appropriate event.
    */
function getRefund() public payable {
    uint refundAmount = (myEvent.buyers[msg.sender] * TICKET_PRICE);
    uint bought = myEvent.buyers[msg.sender];
    require(myEvent.buyers[msg.sender] > 0,'you have not purchased tickets');
    // myEvent.buyers[msg.sender] -= ticketRefund;
    myEvent.sales -= myEvent.buyers[msg.sender];
    msg.sender.transfer(refundAmount);
    emit LogGetRefund(msg.sender, bought);
}
    /*
        Define a function called endSale().
        This function will close the ticket sales.
        This function can only be called by the contract owner.
        TODO:
            - close the event
            - transfer the contract balance to the owner
            - emit the appropriate event
    */
function endSale() public
    isOwner(msg.sender)
    eventIsOpen() {
    myEvent.isOpen = false;
    owner.transfer(address(this).balance);
}
}
