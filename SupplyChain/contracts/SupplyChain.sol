pragma solidity ^0.4.23;

contract SupplyChain {

  /* set owner */
    address owner;

    uint skuCount;

    mapping (uint => Item) items;

    enum State { ForSale, Sold, Shipped, Received }

  /* Create a struct named Item.
    Here, add a name, sku, price, state, seller, and buyer
    We've left you to figure out what the appropriate types are,
    if you need help you can ask around :)
  */
    struct Item {
        string name;
        uint sku;
        uint price;
        State state;
        address seller;
        address buyer;
    }

    event ForSale(uint sku);
    event Sold(uint sku);
    event Shipped(uint sku);
    event Received(uint sku);

    modifier isContractOwner(address _owner) {
        require (_owner == msg.sender);
        _;
    }

    modifier verifyCaller (address _address) { require (msg.sender == _address); _;}

    modifier paidEnough(uint _price) { require(msg.value >= _price); _;}
    modifier checkValue(uint _sku) {
        //refund them after pay for item (why it is before, _ checks for logic before func)
        _;
        uint _price = items[_sku].price;
        uint amountToRefund = msg.value - _price;
        items[_sku].buyer.transfer(amountToRefund);
    }

  /* For each of the following modifiers, use what you learned about modifiers
   to give them functionality. For example, the forSale modifier should require
   that the item with the given sku has the state ForSale. */
    modifier forSale(uint _sku) { require (items[_sku].state == State.ForSale); _; }
    modifier sold(uint _sku) { require (items[_sku].state == State.Sold); _; }
    modifier shipped(uint _sku) { require (items[_sku].state == State.Shipped); _; }
    modifier received(uint _sku) { require (items[_sku].state == State.Received); _; }


    constructor() public {
        owner = msg.sender;
        skuCount = 0;
    }

    function addItem(string _name, uint _price) public {
        emit ForSale(skuCount);
        items[skuCount] = Item({name: _name, sku: skuCount, price: _price, state: State.ForSale, seller: msg.sender, buyer: 0});
        skuCount = skuCount + 1;
    }

  /* Add a keyword so the function can be paid. This function should transfer money
    to the seller, set the buyer as the person who called this transaction, and set the state
    to Sold. Be careful, this function should use 3 modifiers to check if the item is for sale,
    if the buyer paid enough, and check the value after the function is called to make sure the buyer is
    refunded any excess ether sent. Remember to call the event associated with this function!*/

    function buyItem (uint sku) public payable
    forSale(sku)
    paidEnough(items[sku].price)
    checkValue(sku)
    {
        uint itemPrice = items[sku].price;
        address itemSeller = items[sku].seller;
        itemSeller.transfer(itemPrice);
        items[sku].state = State.Sold;
        items[sku].buyer = msg.sender;
        emit Sold(sku);
    }

  /* Add 2 modifiers to check if the item is sold already, and that the person calling this function
  is the seller. Change the state of the item to shipped. Remember to call the event associated with this function!*/
    function shipItem(uint sku) public
    sold(sku)
    verifyCaller(items[sku].seller)
    {
        items[sku].state = State.Shipped;
        emit Shipped(sku);
    }

  /* Add 2 modifiers to check if the item is shipped already, and that the person calling this function
  is the buyer. Change the state of the item to received. Remember to call the event associated with this function!*/
    function receiveItem(uint sku)
    public
    shipped(sku)
    verifyCaller(items[sku].buyer)
    {
        items[sku].state = State.Received;
        emit Received(sku);
    }

  /* We have these functions completed so we can run tests, just ignore it :) */
    function fetchItem(uint _sku) public view returns (string name, uint sku, uint price, uint state, address seller, address buyer) {
    name = items[_sku].name;
    sku = items[_sku].sku;
    price = items[_sku].price;
    state = uint(items[_sku].state);
    seller = items[_sku].seller;
    buyer = items[_sku].buyer;
    return (name, sku, price, state, seller, buyer);
    }

}
