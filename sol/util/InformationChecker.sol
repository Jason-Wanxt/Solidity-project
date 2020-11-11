pragma solidity ^0.6.6;

contract DataChecker {
    mapping(address => bool) public  service;
    address public Owner;
    event addService(address);
    event deleteService(address);
    
    modifier isService() {
        require(service[msg.sender] == true,"IOT data: You are not service");
        _;
    }
    
    modifier onlyOwner {
        require(Owner == msg.sender,"IOT data:Only Owner can do this");
        _;
    }
    
    //Grant service to an account
    function grantService(address to) public onlyOwner {
        require(msg.sender == Owner,"Service:Only owner can do this");
        require(service[to] != true,"Service:This address has already be service");
        service[to] = true;
        emit addService(to);
    }
    
    //Drop service from an account
     function dropService(address to) public onlyOwner {
        require(msg.sender == Owner,"Service:Only owner can do this");
        require(service[to] == true,"Service:This address should not be service");
        service[to] = false;
        emit deleteService(to);
    }
    
}
