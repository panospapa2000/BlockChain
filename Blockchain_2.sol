pragma solidity ^0.6.1;

contract Lottery
{
    struct Person
    {
        uint personId;
        address addr;
        uint remainingTokens;
    }
    mapping(address=>Person) tokenDetails;
    Person [4] bidders;

    struct Item
    {
        uint itemId;
        uint itemTokens;
    }

    Item [3] public items;
    
    address [3] public winners;
    address public beneficiary;

    uint bidderCount = 0;

    constructor() public payable
    {
        beneficiary = msg.sender;
        uint[] memory emptyArray;

        items[0] = Item({itemId:0, itemTokens:0});
        items[1] = Item({itemId:1, itemTokens:1});
        items[2] = Item({itemId:2, itemTokens:2});
    }

    function register() public payable
    {
        bidders[bidderCount].personId = bidderCount;

        bidders[bidderCount].addr = msg.sender;
        bidders[bidderCount].remainingTokens = 5;
        tokenDetails[msg.sender] = bidders[bidderCount];
        bidderCount++;
    }

    function bid(uint _itemId, uint _count) public payable
    {
        
    }

    function revealWinners() public onlyOwner
    {

    }

    modifier onlyOwner//Modifier gia ton beneficiary
    {
        require(msg.sender == beneficiary);
        _;
    }

    function getPersonDetails(uint id) public view returns(uint, uint, address)
    {
        return (bidders[id].remainingTokens, bidders[id].personId, bidders[id].addr);
    }
}
