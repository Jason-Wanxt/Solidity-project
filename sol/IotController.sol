pragma solidity ^0.6.6;
pragma experimental ABIEncoderV2;

import "./util/DataMap.sol";
import "./DataSource/DataInformation.sol";
import "./DataSource/SensorInformation.sol";
import "./DataSource/Area.sol";

contract IOTService {
    // Data source contract
    Data public dataContract;
    Sensor public sensorContract;
    Area public areaContract;
    
    mapping(address => bool) public admin;
    address public Owner;
    
    event modifyYeild(uint256 areaId, uint256 newYield);
    event newProduct(uint256 areaId, bytes32 productId);
    event changeSource(address oldAddress,address newAddress,string typeName);
    event newTracement();
    event AddAdmin(address newAdmin);
    event DeleteAdmin(address newAdmin);
    
    modifier onlyOwner {
        require(Owner == msg.sender,"Service:Only Owner can do this");
        _;
    }
    
    modifier onlyAdmin {
        require(admin[msg.sender] == true || Owner == msg.sender,"Service:Only admin can do this");
        _;
    }
    
    modifier onlySensor {
        require(sensorContract.isSensor(msg.sender) == true,"Service:Only sensor can do this");
        _;
    }
    
    function grantAdmin(address to) public onlyOwner {
        require(admin[to] != true,"Service:This address has already be admin");
        admin[to] = true;
        emit AddAdmin(to);
    }
    
     function dropAdmin(address to) public onlyOwner {
        require(admin[to] == true,"Service:This address should not be admin");
        admin[to] = false;
        emit DeleteAdmin(to);
    }
    
    //tansfer owner to target address
    function transOwner(address target) public onlyOwner {
        Owner = target;
    }
    
    function grantSensor(address to,uint256 areaId) public onlyAdmin {
        require(areaContract.isAreaExist(areaId),"Service:This area does not exist");
        sensorContract.addSensor(to,areaId);
    }
    
    function dropSensor(address to) public onlyAdmin {
        sensorContract.dropSeneor(to);
    }
    
    //Change Data source's address
    function changeDataContract(address newAddress) public onlyOwner {
        address oldAddress = address(dataContract);
        dataContract = Data(newAddress);
        emit changeSource(oldAddress,newAddress,"data");
    }
    
    //Change Sensor source's address
    function changeSensorContract(address newAddress) public onlyOwner {
        address oldAddress = address(dataContract);
        sensorContract = Sensor(newAddress);
        emit changeSource(oldAddress,newAddress,"data");
    }
    
    //Change Area source's address
    function changeAreaContract(address newAddress) public onlyOwner {
        address oldAddress = address(dataContract);
        areaContract = Area(newAddress);
        emit changeSource(oldAddress,newAddress,"data");
    }
    
    constructor(address dataAddress,address sensorAddress,address areaAddress) public {
        dataContract = Data(dataAddress);
        sensorContract = Sensor(sensorAddress);
        areaContract = Area(areaAddress);
        Owner = msg.sender;
    }
    
    
    //Upload traceability information,id is product id
    function addInformation(bytes32 productId, string memory information) public onlySensor {
        dataContract.addData(productId,information);
    }
    
    //Obtain traceability information,id is product id
    function getInformation(bytes32 productId) view public returns(DataMap.MapEntry[] memory) {
        return dataContract.watchData(productId);
    }
    
    //Generate a new product id by hashing address of sensor, time, areaId, and current number products of this area,this function does not need
    //to write onlySensor modifier because sensorContract.getSensorArea() will check.
    function generateNewProduct(uint256 areaId,bytes32 productId) public returns(bytes32) {
        require(areaId == sensorContract.getSensorArea(msg.sender),"Service:This sensor can not trace this area's corp");
        uint256 areaYield = dataContract.getAreaYield(areaId);
        uint256 maxAreaYield = dataContract.getMaxAreaYield(areaId);
        require(areaYield < maxAreaYield,"Service:Max than this area's yeild");
        bool res = dataContract.addProduct(productId);
        require(res == true,"Service:PID already exist");
        //increase this area's yeild by one
        dataContract.addAreaYield(areaId);
        emit newProduct(areaId,productId);
        return productId;
    }
    
    //This function is used to update a area's maximum traceability,and set the current traceability to 0.
    function editYield(uint256 areaId,uint256 newYield) public onlyAdmin {
        require(areaContract.isAreaExist(areaId) == true,"Service: This area does not exist");
        dataContract.setMaxAreaYield(areaId,newYield);
        emit modifyYeild(areaId,newYield);
        dataContract.setAreaYielToZero(areaId);
    }
    
    //Register a new area
    function addArea(string memory name) public onlyAdmin {
        areaContract.registerArea(name);
    }
    
    //Remove a exist area
    function dropArea(uint256 id) public onlyAdmin {
        areaContract.cancelYeild(id);
        dataContract.setAreaYielToZero(id);
        dataContract.setMaxAreaYield(id,0);
    }
    
    //Genrate a new product id, to genrate, this function will check if the product id has exist and if this area can genrate a new product id.
    function generatePID(uint256 areaId) public onlySensor view returns(bytes32) {
        uint256 areaYield = dataContract.getAreaYield(areaId);
        return sha256(abi.encode(
            now,
            msg.sender,
            areaYield,
            areaId
        ));
    }
    
    //Get area name from area id.
    function getArea(uint256 id) public view returns(string memory) {
        return areaContract.getArea(id);
    }
    
    //Get area id from area name.
    function getAreaFromName(string memory name) public view returns(uint256) {
        return areaContract.getAreaFromName(name);
    }
     
     //Check sensor exists.
    function isSensor(address id) view public returns(bool) {
        return sensorContract.isSensor(id);
    }
    
    //Get the sensor's area.
    function sensorArea(address sensor) public view returns(uint256) {
        return sensorContract.getSensorArea(sensor);
    }
    
    //Get current yeild of a area which id is ${areaId}
    function areaYield(uint256 areaId) view public returns(uint256) {
        return dataContract.getAreaYield(areaId);
    }
    
    //Get max yeild of a area which id is ${areaId}
    function areaMaxYield(uint256 areaId) view public returns(uint256) {
        return dataContract.getMaxAreaYield(areaId);
    }
}
