pragma solidity ^0.5.0;
pragma experimental ABIEncoderV2;

contract Brokerage {
    address owner;
    
    enum BrokerageUnit {CPM,Percentage}
    enum SettlementStatus {UnSettled, Disputed, Settled}
    enum UserType {Client,Broker}
    
    struct User {
        address accountId;
        UserType userType;
        string name;
        string code;
        bool isEnabled;
    }
    
    struct Trade {
        string markitWireId;
        string tradeDate;
        string currency;
        string settlementDate;
        bool clearingEligible;
        string clientCode;
        string brokerCode;
        uint brokerageAmount;
    }
    
    struct BrokerageTrade {
        Trade trade;
        bool hasBrokeragePaid;
        string paymentReference;
        address brokerId;
        address senderId;
        SettlementStatus status;
    }
    
    struct BrokerageDispute {
        string tradeId;
        uint updatedAmount;
        string comments;
    }
    
    struct BrokerageRateCard {
        address brokerId;
        ProductBrokerage[] productBrokerage;
    }
    
    struct ProductBrokerage {
        string instrument;
        BrokerageUnit unit;
        uint amount;
    }
    
    mapping(string => User) brokerMapping; 
    mapping(address => User) public brokerAddressMapping;
    mapping(address => User) customerMapping;
    mapping(string => BrokerageTrade) tradesToSettle;
    //mapping (address => Trade[]) brokerTrades;
    mapping (address => mapping(string => BrokerageTrade)) brokerageTrades1;
    mapping (address => BrokerageTrade[]) public brokerageTrades;
    
    mapping(string => BrokerageDispute[]) disputes;
    
    
    //events
    event NewBroker(address broker);
    event NewClient(address client);
    event NewTradeSubmit(BrokerageTrade trade );
    event DisputeOccured(BrokerageTrade trade, BrokerageDispute dispute);
    event BrokerageSettled(BrokerageTrade trade);
    
    
    modifier onlyBroker() {
        require(isBroker(),"Only broker is allowed to perform operation.");
        _;
    }
    
    modifier onlyClient() {
        require(isClient(),"Only client is allowed to perform operation.");
        _;
    }

    
    /**
     * @return true if `msg.sender` is client.
     */
    function isClient() public view returns (bool) {
        User memory client = customerMapping[msg.sender];
        return client.isEnabled;
    }
    
    /**
     * @return true if `msg.sender` is broker.
     */
    function isBroker() public view returns (bool) {
        User memory broker = brokerAddressMapping[msg.sender];
        return broker.isEnabled;
    }
    
    
    constructor() public {
        owner = msg.sender;
    }
    
    function registerBroker(string memory _brokerCode, string memory _brokerName) public {
        require (msg.sender != owner, "Owner can't be broker");
        require (!isBroker(), "Broker already registered");
        User memory broker = User(msg.sender, UserType.Broker,_brokerName, _brokerCode, true);
        brokerMapping[_brokerCode] = broker;
        brokerAddressMapping[msg.sender] = broker;
        emit NewBroker(msg.sender);
    }
    
     function registerClient(string memory _clientCode, string memory _clientName) public {
        require (!isClient(), "Client already registered");
        User memory client = User(msg.sender, UserType.Client,_clientName, _clientCode, true);
        customerMapping[msg.sender] = client;
        emit NewClient(msg.sender);
    }
    
    function submitTrade(string memory _markitWireId, string memory _tradeDate, string memory _currency, string memory _settlementDate, bool  _isClearingEligible, string memory _clientCode,string memory _brokerCode, uint _brokerage) public onlyClient{
        require(brokerMapping[_brokerCode].isEnabled,"Unknown broker");
        Trade memory trade = Trade(_markitWireId, _tradeDate, _currency, _settlementDate, _isClearingEligible, _clientCode, _brokerCode, _brokerage);
        BrokerageTrade memory brokerageTrade = BrokerageTrade(trade, false, "", brokerMapping[_brokerCode].accountId,msg.sender, SettlementStatus.UnSettled);
        //brokerTrades[brokerMapping[_brokerCode].accountId].push(trade);
        brokerageTrades[brokerMapping[_brokerCode].accountId].push(brokerageTrade);
        
        mapping (string => BrokerageTrade) storage mappings = brokerageTrades1[brokerMapping[_brokerCode].accountId];
        mappings[_markitWireId] = brokerageTrade;
        
        
        //emit notification to broker
        emit NewTradeSubmit(brokerageTrade);
    }
   
    
    function confirmBrokerageAmount (string memory _tradeId) public onlyBroker{
        BrokerageTrade storage brokerageTrade = brokerageTrades1[msg.sender][_tradeId];
        require(brokerageTrade.status == SettlementStatus.UnSettled, "Trade already settled.");
        brokerageTrade.status = SettlementStatus.Settled;
        BrokerageTrade[]storage tradeArray= brokerageTrades[msg.sender]; 
        
        for (uint i=0; i<tradeArray.length; i++) 
        {
            if(keccak256(abi.encodePacked((tradeArray[i].trade.markitWireId))) == keccak256(abi.encodePacked((_tradeId))))
            {
            
                tradeArray[i].status=SettlementStatus.Settled;
                
            }
        }
        //emit event to customer that broker has settled trade
        
        emit BrokerageSettled(brokerageTrade);
    }
    
      function disputeBrokerage2 (string memory _tradeId, uint _amount, string memory _comments) public onlyBroker{
        //BrokerageTrade storage brokerageTrade = brokerageTrades1[msg.sender][_tradeId];
        require(brokerageTrades1[msg.sender][_tradeId].status == SettlementStatus.UnSettled, "Trade already settled.");
        
         if(brokerageTrades1[msg.sender][_tradeId].status != SettlementStatus.Disputed)
         {
            brokerageTrades1[msg.sender][_tradeId].status = SettlementStatus.Disputed;
            BrokerageTrade[]storage tradeArray= brokerageTrades[msg.sender]; 
        
            for (uint i=0; i<tradeArray.length; i++) 
            {
                if(keccak256(abi.encodePacked((tradeArray[i].trade.markitWireId))) == keccak256(abi.encodePacked((_tradeId))))
                {
                tradeArray[i].status=SettlementStatus.Disputed;
                }
            }
            BrokerageDispute memory brokerageDispute = BrokerageDispute(_tradeId, _amount, _comments);
            disputes[_tradeId].push(brokerageDispute);
             //emit event to customer that broker has settled trade
            emit DisputeOccured(brokerageTrades1[msg.sender][_tradeId],brokerageDispute);
        }
        
       
    }
    
    function disputeBrokerage(string memory _tradeId, uint _amount, string memory _comments ) public {
        //BrokerageTrade storage brokeredTrade = tradesToSettle[_tradeId];
        require(tradesToSettle[_tradeId].status == SettlementStatus.UnSettled, "Trade is already settled");
        
        BrokerageDispute memory brokerageDispute = BrokerageDispute(_tradeId, _amount, _comments);
        disputes[_tradeId].push(brokerageDispute);
        
        if(tradesToSettle[_tradeId].status != SettlementStatus.Disputed) {
            BrokerageTrade storage brokeredTrade = tradesToSettle[_tradeId];
            brokeredTrade.status=SettlementStatus.Disputed;
        }
        
        //emit event to customer that broker has not settled trade
        emit DisputeOccured(tradesToSettle[_tradeId], brokerageDispute);
    }
    
    function getUserRole() view public returns (string memory _role) {
        if(isBroker())
            _role = "Broker";
        else if(isClient())
            _role = "Client";
        else
            _role = "NONE";
            
        return _role;
    }
    
     function getBrokerTrades() view public onlyBroker returns (BrokerageTrade[] memory _brokerageTrades) {
        require(brokerAddressMapping[msg.sender].isEnabled, "Not a valid broker");
        require(brokerageTrades[msg.sender].length > 0, "No trades available");
        
        _brokerageTrades = brokerageTrades[msg.sender];
    }
    function getBrokerTradeByMarketWireId(string memory _markitWireId) view public onlyBroker returns (BrokerageTrade memory bTrade) {
        require(brokerAddressMapping[msg.sender].isEnabled, "Not a valid broker");
        require(brokerageTrades[msg.sender].length > 0, "No trades available");
         mapping (string => BrokerageTrade) storage mappings = brokerageTrades1[msg.sender];
        bTrade= mappings[_markitWireId];
       
    }
}
