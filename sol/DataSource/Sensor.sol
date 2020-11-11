pragma solidity ^0.6.6;

import "../util/InformationChecker.sol";

contract Sensor is DataChecker{
    mapping(address => bool) sensors;
    mapping(address => uint256) area;//The sensor's area
    
    event NewSensor(address sensorId, uint256 areaId);
    event DeletSensor(address sensorId);
    
    constructor() public {
        Owner = msg.sender;
    }
    
    function isSensor(address id) view public returns(bool) {
        return sensors[id];
    }
    
    //Add a sensor
    function addSensor(address id,uint256 areaId) public isService {
        require(isSensor(id)==false,"Sensor:You have already be sensor");
        sensors[id] = true;
        area[id] = areaId;
        emit NewSensor(id,areaId);
    }
    
    //Delete sensor
    function dropSeneor(address id) public isService {
        require(isSensor(id) == true,"Sensor:You are not sensor yet");
        sensors[id] = false;
        emit DeletSensor(id);
    }
    
    //Get the area match to the sensor address
    function getSensorArea(address id) public view returns(uint256) {
        require(isSensor(id) == true,"Sensor:This address is not Sensor");
        return area[id];
    }
}

