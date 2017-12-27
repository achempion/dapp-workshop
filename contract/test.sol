pragma solidity ^0.4.16;

contract Test {
    uint public id = 0;

    function getId() public view returns (uint id_counter) {
        return id;
    }

    function nextId() public {
        id++;
    }
}