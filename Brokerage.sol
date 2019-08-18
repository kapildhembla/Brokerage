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
        //uint brokerageAmount;
    }
    
    struct BrokerageTrade {
        Trade trade;
        bool hasBrokeragePaid;
        string paymentReference;
        address brokerId;
        address senderId;
        SettlementStatus status;
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
    mapping(address => User) brokerAddressMapping;
    mapping(address => User) customerMapping;
    mapping (address => Trade[]) brokerTrades;
    mapping (address => mapping(string => BrokerageTrade)) brokerageTrades1;
    mapping (address => BrokerageTrade[]) brokerageTrades;
    
    
    modifier onlyBroker() {
        require(isBroker());
        _;
    }
    
    modifier onlyCustomer() {
        require(isCustomer());
        _;
    }

    
    /**
     * @return true if `msg.sender` is custoemr.
     */
    function isCustomer() public view returns (bool) {
        User memory customer = customerMapping[msg.sender];
        return customer.isEnabled;
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
        require (brokerMapping[_brokerCode].isEnabled, "Broker already registered");
        User memory broker = User(msg.sender, UserType.Broker,_brokerName, _brokerCode, true);
        brokerMapping[_brokerCode] = broker;
        brokerAddressMapping[msg.sender] = broker;
    }
    
     function registerClient(string memory _clientCode, string memory _clientName) public {
        require (customerMapping[msg.sender].isEnabled, "Client already registered");
        User memory client = User(msg.sender, UserType.Client,_clientName, _clientCode, true);
        customerMapping[msg.sender] = client;
    }
    
    function submitTrade  (string memory _markitWireId, string memory _tradeDate, string memory _currency, string memory _settlementDate, bool  _isClearingEligible, string memory _clientCode,string memory _brokerCode) public onlyCustomer{
        require(brokerMapping[_brokerCode].isEnabled,"Unknown broker");
        Trade memory trade = Trade(_markitWireId, _tradeDate, _currency, _settlementDate, _isClearingEligible, _clientCode, _brokerCode);
        BrokerageTrade memory brokerageTrade = BrokerageTrade(trade, false, "",msg.sender, brokerMapping[_brokerCode].accountId, SettlementStatus.UnSettled);
        //brokerTrades[brokerMapping[_brokerCode].accountId].push(trade);
        brokerageTrades[brokerMapping[_brokerCode].accountId].push(brokerageTrade);
        
        mapping (string => BrokerageTrade) storage mappings = brokerageTrades1[brokerMapping[_brokerCode].accountId];
        mappings[_markitWireId] = brokerageTrade;
        
        
        //emit notification to broker
    }
    
    function getBrokerTrades() view public onlyBroker returns (BrokerageTrade[] memory _brokerageTrades) {
        require(brokerAddressMapping[msg.sender].isEnabled, "Not a valid broker");
        require(brokerTrades[msg.sender].length > 0, "No trades available");
        
        _brokerageTrades = brokerageTrades[msg.sender];
    }
    
    function confirmBrokerageAmount (string memory _tradeId) public onlyBroker{
        BrokerageTrade memory brokerageTrade = brokerageTrades1[msg.sender][_tradeId];
        require(brokerageTrade.status != SettlementStatus.UnSettled, "Trade already settled.");
        brokerageTrade.status = SettlementStatus.Settled;
    }
}
