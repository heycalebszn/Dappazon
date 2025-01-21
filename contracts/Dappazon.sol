// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.9;

contract Dappazon {
    address public owner;

    struct Item {
        uint256 id;
        string name;
        string image;
        string category;
        uint256 cost;
        uint256 rating;
        uint256 stock;
    }

    struct Order {
        uint256 timestamp;
        uint256 itemId;
    }

    mapping(uint256 => Item) public items;
    mapping(address => uint256) public orderCount;
    mapping(address => mapping(uint256 => Order)) public orders;

    event ItemListed(uint256 id, string name, uint256 cost, uint256 stock);
    event ItemBought(address buyer, uint256 orderId, uint256 itemId);

    modifier onlyOwner() {
        require(msg.sender == owner, "Only owner can perform this action");
        _;
    }

    constructor() {
        owner = msg.sender;
    }

    function listProduct(
        uint256 _id,
        string memory _name,
        string memory _image,
        string memory _category,
        uint256 _cost,
        uint256 _rating,
        uint256 _stock
    ) public onlyOwner {
        require(_stock > 0, "Stock must be greater than zero");
        require(bytes(_name).length > 0, "Name cannot be empty");

        items[_id] = Item({
            id: _id,
            name: _name,
            image: _image,
            category: _category,
            cost: _cost,
            rating: _rating,
            stock: _stock
        });

        emit ItemListed(_id, _name, _cost, _stock);
    }

    function buy(uint256 _id) public payable {
        Item storage item = items[_id];

        require(item.cost > 0, "Item does not exist");
        require(msg.value >= item.cost, "Insufficient funds to buy item");
        require(item.stock > 0, "Item is out of stock");

        item.stock--;

        uint256 currentOrderId = ++orderCount[msg.sender];
        orders[msg.sender][currentOrderId] = Order({
            timestamp: block.timestamp,
            itemId: _id
        });

        emit ItemBought(msg.sender, currentOrderId, _id);
    }

    function withdraw() public onlyOwner {
        uint256 balance = address(this).balance;
        require(balance > 0, "No funds to withdraw");

        (bool success, ) = owner.call{value: balance}("");
        require(success, "Withdrawal failed");
    }

    receive() external payable {}

    fallback() external payable {}
}
