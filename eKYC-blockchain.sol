pragma solidity ^0.8.0;

contract KYC {
    
    struct Customer {
        string name;
        string customerAddress;
        bytes32 identificationHash;
        bool verified;
        uint256 createdAt;
        uint256 updatedAt;
        bytes32[] documents;
    }
    
    struct Bank {
        string name;
        address wallet;
        uint256 createdAt;
        address[] customers;
        address[] employees;
        address bankAddress;
    }
    
    mapping(address => Customer) public customers;
    mapping(address => Bank) public banks;
    
    event CustomerAdded(address indexed customerAddress, string name, string indexed cAddress, bytes32 identificationHash, uint256 createdAt);
    event CustomerVerified(address indexed customerAddress, address indexed bankAddress, uint256 updatedAt);
    
    modifier onlyBankEmployee(address bankAddress) {
        require(isBankEmployee(bankAddress, msg.sender), "Not authorized");
        _;
    }
    
    function addCustomer(string memory name, string memory customerAddress, bytes32 identificationHash) public {
        require(customers[msg.sender].createdAt == 0, "Customer already exists");
        customers[msg.sender] = Customer(name, customerAddress, identificationHash, false, block.timestamp, block.timestamp, new bytes32[](0));
        emit CustomerAdded(msg.sender, name, customerAddress, identificationHash, block.timestamp);
    }
    
    function verifyCustomer(address customerAddress) public onlyBankEmployee(msg.sender) {
        require(customers[customerAddress].verified == false, "Customer already verified");
        customers[customerAddress].verified = true;
        customers[customerAddress].updatedAt = block.timestamp;
        banks[msg.sender].customers.push(customerAddress);
        emit CustomerVerified(customerAddress, msg.sender, block.timestamp);
    }
    
    function addCustomerDocument(bytes32 documentHash) public {
        require(customers[msg.sender].createdAt != 0, "Customer does not exist");
        customers[msg.sender].documents.push(documentHash);
    }
    
    function isBankEmployee(address bankAddress, address employeeAddress) public view returns (bool) {
        for (uint i = 0; i < banks[bankAddress].employees.length; i++) {
            if (banks[bankAddress].employees[i] == employeeAddress) {
                return true;
            }
        }
        return false;
    }
    
    function addBank(string memory name, address wallet, address bankAddress) public {
        require(banks[msg.sender].createdAt == 0, "Bank already exists");
        banks[msg.sender] = Bank(name, wallet, block.timestamp, new address[](0), new address[](0), bankAddress);
    }
    
    function addBankEmployee(address employeeAddress) public {
        require(banks[msg.sender].createdAt != 0, "Bank does not exist");
        banks[msg.sender].employees.push(employeeAddress);
    }
    
}