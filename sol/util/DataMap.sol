pragma solidity 0.6;

library DataMap{
    //entry of the map
    struct MapEntry {
        address _key;
        string _value;
    }

    struct Map {
        // Storage of map keys and values
        MapEntry[] _entries;

        // Position of the entry defined by a key in the `entries` array, plus 1
        // because index 0 means a key is not in the map.
        mapping (address => uint256) _indexes;
    }
    
    function _set(Map storage map, address k, string memory v)  private returns(bool){
        uint256 index = map._indexes[k];
        //if there is no entry match
        if(index == 0) {
            MapEntry memory entry = MapEntry(k,v);
            map._entries.push(entry);
            map._indexes[k] = map._entries.length;
            return true;
        } else {
            return false;
        }
    }
    
    function _get(Map storage map, uint256 index) view private returns(string memory) {
        require(index < map._entries.length,"DataMap:This index is overflow");
        return map._entries[index]._value;
    }
    
    function _get(Map storage map, address k) view private returns(string memory){
        uint256 index = map._indexes[k];
        if(index == 0) {
            return "";
        }
        return map._entries[index - 1]._value;
    }
    
    function set(Map storage map, address k, string memory v) internal returns(bool) {
        return _set(map,k,v);
    }
    
    function get(Map storage map, address k) view internal returns(string memory){
        return _get(map,k);
    }
    function getByIndex(Map storage map, uint256 i) view internal returns(string memory){
        return _get(map,i);
    }
}


