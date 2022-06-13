pragma solidity >=0.6.1;

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

    uint public winnerId;
    uint min_eth = 1;//Το ελάχιστο ποσό που πρέπει να μεταφέρει. Επίσης δεν μου το αναγνωρίζει ως δεκαδικό αριθμό το 0.01, γιαυτό έβαλα 1.
    uint bidderCount = 0;//Μετρητής των εγγγραμένων παικτών

    enum Stage{Init, Reg, Bid, Done}
    Stage public stage = Stage.Init;
    uint public timeNow;
    uint startTime;

    uint plithos = 0;//ο αριθμός της λαχειοφόρου

    modifier validStage(Stage reqStage)//Έναν modifier για κάθε Stage σε αντίστοιχη συνάρτηση
    {
        require(stage == reqStage);
        _;
    }

    constructor() public payable
    {
        beneficiary = msg.sender;

        uint[] memory emptyArray;
        for(uint i = 0; i<3; i++)
        {
            items[i] = Item({itemId:i, itemTokens:emptyArray});
        }

        stage = Stage.Init;
        startTime = now;
    }

    function register() public payable onlyRegister() validStage(Stage.Reg)//Υπάρχει χώρος για 2 modifiers
    {
        bidders[bidderCount].personId = bidderCount;

        bidders[bidderCount].addr = msg.sender;
        bidders[bidderCount].remainingTokens = 5;
        tokenDetails[msg.sender] = bidders[bidderCount];
        bidderCount++;

        if (now > (startTime + 30 seconds)) {stage = Stage.Bid; }
    }

    modifier onlyRegister()//Modifier για την register
    {
        require(msg.value > min_eth);
        require(msg.sender != beneficiary);//Δεν επιτρέπεται στον ιδιοκτήτη του συμβολαίου
        _;
    }

    modifier onlyBid(uint _itemId, uint _count)//Modifier για την bid
    {
        //Δύο έλεγχοι
        require(tokenDetails[msg.sender].remainingTokens >= _count);//Έχει επαρκές πλήθος λαχείων?
        require(_itemId == items[0].itemId || _itemId == items[1].itemId || _itemId == items[2].itemId);// Υπάρχει το αντικείμενο? Αρκεί να είναι ίσο με ένα από τα 3
        _;
    }

    function bid(uint _itemId, uint _count) public onlyBid(_itemId, _count) validStage(Stage.Bid)
    {
        //Ενημέρωση του υπολοίπου λαχείων του παίκτη
        uint upoloipo = tokenDetails[msg.sender].remainingTokens - _count;//Ορισμός μεταβλητής upoloipo που δηλώνει το υπόλοιπο λαχείων με αφαίρεση του _count
        tokenDetails[msg.sender].remainingTokens=upoloipo;//Καταχώρηση της μεταβλητής upoloipo, ενημερώνοντας το νέο υπόλοιπο του παίκτη

        //Ενημέρωση της κληρωτίδας του _itemId με εισαγωγή των _count λαχείων που ποντάρει ο παίκτης
        Item storage klirotida = items[_itemId];
        for(uint i=0; i<_count; i++)
        {
            klirotida.itemTokens.push(tokenDetails[msg.sender].personId);
        }
        if (now > (startTime + 30 seconds)) {stage = Stage.Done; }
    }

    modifier onlyOwner()//Modifier για τον revealWinners
    {
        require(msg.sender == beneficiary);//Μόνο από τον ιδιοκτήτη του συμβολαίου
        _;
    }

    function random(uint number) private view returns(uint)
    {
        return uint(keccak256(abi.encodePacked(block.timestamp,block.difficulty,  
        msg.sender))) % number;
    }

    function withdraw(uint256 amount) public onlyOwner
    {
        msg.sender.transfer(amount);//Μεταφορά των ether απο το συμβόλαιο
    }

    event Winner(address winner, uint item, uint lottery);

    function revealWinners() public onlyOwner() validStage(Stage.Done)
    {
        if (stage != Stage.Done) {return;}
        for (uint i = 0; i < 3; i++)
        {
            Item memory currItem = items[i];
            if(currItem.itemTokens.length != 0 && winnerId==0)
            {
                uint index = random(3) % winners.length;
                winnerId = currItem.itemTokens[index];
                
                winners[i] = bidders[winnerId].addr;//Ενημέρωση του πίνακα winners με την διεύθυνση του νικητή
                emit Winner(bidders[winnerId].addr, currItem.itemId, plithos);
            }
        }
    }

    function reset() public onlyOwner 
    {
        stage = Stage.Reg;
        delete bidders;//Διαγραφή του πίνακα των παικτών
        delete winners;//Διαγραφή του πίνακα των νικητών
        plithos++;//Ο αριθμός της λαχειοφόρου αυξάνεται κατά 1
    }

    function advanceState() public
    {
        timeNow = now;
        if (timeNow > (startTime + 30 seconds)) {startTime = timeNow;}
        if (stage == Stage.Init) {stage = Stage.Reg; return;}
        if (stage == Stage.Reg) {stage = Stage.Bid; return;}
        if (stage == Stage.Bid) {stage = Stage.Done; return;}
        return;
    }

    function getPersonDetails(uint id) public view returns(uint, uint, address)
    {
        return (bidders[id].remainingTokens, bidders[id].personId, bidders[id].addr);
    }
}