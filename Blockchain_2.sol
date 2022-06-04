pragma solidity ^0.6.1;

contract Lottery
{
    struct Person//Δημιουργία δομής για τον παίκτη
    {
        uint personId;
        address addr;
        uint remainingTokens;
    }
    mapping(address=>Person) tokenDetails;//Διεύθυνση του παίκτη
    Person [4] bidders;

    struct Item//Δημιουργία δομής για το αντικείμενο
    {
        uint itemId;
        uint[] itemTokens;
    }

    Item [3] public items;
    
    address [3] public winners;
    address public beneficiary;

    uint bidderCount = 0;//Μετρητής των εγγγραμένων παικτών

    constructor() public payable
    {
        beneficiary = msg.sender;

        uint[] memory emptyArray;
        items[0] = Item({itemId:0, itemTokens:emptyArray});
        items[1] = Item({itemId:1, itemTokens:emptyArray});
        items[2] = Item({itemId:2, itemTokens:emptyArray});
    }

    function register() public payable
    {
        bidders[bidderCount].personId = bidderCount;

        bidders[bidderCount].addr = msg.sender;
        bidders[bidderCount].remainingTokens = 5;
        tokenDetails[msg.sender] = bidders[bidderCount];
        bidderCount++;
    }

    modifier onlyBid(uint _itemId, uint _count)//Modifier για την bid
    {
        //Δύο έλεγχοι
        require(tokenDetails[msg.sender].remainingTokens >= _count);//Έχει επαρκές πλήθος λαχείων?
        require(_itemId == items[0].itemId || _itemId == items[1].itemId || _itemId == items[2].itemId);// Υπάρχει το αντικείμενο? Αρκεί να είναι ίσο με ένα από τα 3
        _;
    }

    function bid(uint _itemId, uint _count) public onlyBid(_itemId, _count)
    {
        //Ενημέρωση του υπολοίπου λαχείων του παίκτη
        uint balance = tokenDetails[msg.sender].remainingTokens - _count;//Ορισμός μεταβλητής balance που δηλώνει το υπόλοιπο λαχείων με αφαίρεση του _count
        tokenDetails[msg.sender].remainingTokens=balance;//Καταχώρηση της μεταβλητής balance, ενημερώνοντας το νέο υπόλοιπο του παίκτη

        //Ενημέρωση της κληρωτίδας του _itemId με εισαγωγή των _count λαχείων που ποντάρει ο παίκτης

    }

    modifier onlyOwner()//Modifier για τον revealWinners
    {
        //Δύο έλεγχοι
        require(msg.sender == beneficiary);//Μόνο από τον ιδιοκτήτη του συμβολαίου
        _;
    }

    function random() private view returns(uint)
    {
        //return uint(keccak256(block.winners));
    }

    function revealWinners() public onlyOwner()
    {
        for (uint i = 0; i < 3; i++)
        {
            Item memory currItem = items[i];
            //if(currItem[i].itemTokens.length != 0)
            {
                uint index = random() % winners.length;
                uint winnerId = currItem.itemTokens[index];
                
                winners[i] = bidders[winnerId].addr;//Ενημέρωση του πίνακα winners με την διεύθυνση του νικητή
            }
        }
    }

    function getPersonDetails(uint id) public view returns(uint, uint, address)
    {
        return (bidders[id].remainingTokens, bidders[id].personId, bidders[id].addr);
    }
}
