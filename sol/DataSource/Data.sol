pragma solidity ^0.6.6;
pragma experimental ABIEncoderV2;

import "../util/DataMap.sol";
import "../util/InformationChecker.sol";

contract Data is DataChecker{
    using DataMap for DataMap.Map;
    mapping(bytes32 => DataMap.Map)  tracement;//product id matches product information which contains an array is every sensors to its information
    mapping(int => mapping(int => int)) public i;
    mapping(address => bool) public admin;
    mapping(bytes32 => bool) public products;
    mapping(uint256 => uint256) public count;
    mapping(uint256 => uint256) public maxCount;
    
    
    event addService(address);
    event deleteService(address);
    
    
    constructor() public {
        Owner = msg.sender;
    }
    
    //Add tracement data to a product
    function addData(bytes32 id, string memory information) isService public  {
        DataMap.Map storage map = tracement[id];
        require(map.set(tx.origin,information),"Data: You have already upload data.");
    }
    
    //Get the data from a product
    function watchData(bytes32 id) view public returns(DataMap.MapEntry[] memory) {
        DataMap.Map memory map = tracement[id];
        return map._entries;
    }
    
    //Add a new product.
    function addProduct(bytes32 productId) isService public returns(bool) {
        if(products[productId]) {
            return false;
        }
        products[productId] = true;
        return true;
    }
    
    //Increase products number by one
    function addAreaYield(uint256 areaid) isService public {
        count[areaid]++;
    }
    
    
    function getAreaYield(uint256 areaId) view public returns(uint256) {
        return count[areaId];
    }
    
    //Get the maximum yield of crops in an area
    function getMaxAreaYield(uint256 areaId) view public returns(uint256) {
        return maxCount[areaId];
    }
    
    //Set the maximum yield of crops in an area
    function setMaxAreaYield(uint256 areaId,uint256 newYield) isService public{
        maxCount[areaId] = newYield;
    }
    
    function setAreaYielToZero(uint256 areaId) isService public {
        count[areaId] = 0;
    }
    
}
