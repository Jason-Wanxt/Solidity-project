pragma solidity ^0.6.6;

import "../util/InformationChecker.sol";
import "../util/DataMap.sol";

contract Area is DataChecker {
    mapping(uint256=>string) private area;
    mapping(uint256=>bool) private valid;
    mapping(string=>uint256) private areaFromName;
    using DataMap for DataMap.Map;
    uint256 public areaNumber;
    
    event NewArea(uint256 areaId,string areaName);
    event DeletArea(uint256 areaId);
    
    constructor() public {
        Owner = msg.sender;
    }
    
    //Register a new area
    function registerArea(string memory name) public isService returns(uint256){
        require(areaFromName[name] == 0,"Area:This area has been registered");
        uint256 id = ++areaNumber;
        area[id] = name;
        areaFromName[name] = id;
        valid[id] = true;
        emit NewArea(id,name);
        return id;
    }
    
    function getArea(uint256 id) public view returns(string memory) {
        require(valid[id] == true,"Area:This area is no more valid");
        return area[id];
    }
    
    function getAreaFromName(string memory name) public view returns(uint256) {
        uint256 id = areaFromName[name];
        require(valid[id] == true && id > 0,"Area:This area is no more valid");
        return id;
    }
    
    //Check if the area exists
    function isAreaExist(uint256 id) public view returns(bool) {
        return valid[id];
    }
    
    //Delete this area
    function cancelYeild(uint256 id) public isService {
        require(valid[id] == true,"Yeild:This area is not valid");
        valid[id] = false;
        emit DeletArea(id);
    }
}
