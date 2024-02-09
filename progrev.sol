// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.7.0 <0.9.0;

contract Progrev
{
    address public owner;

    constructor(){
        owner = msg.sender;
    }

    event platezh(address _address, uint _amount);

    struct Goi
    {
        address userAddress;
        uint256 balance;
    }

    Goi[] private gois;
    Goi private goi;

    function SendDengi(address payable _address) public payable
    {
        require(msg.value <= goi.balance, "you dont have enough money for this operation");
        _address.transfer(msg.value);
        emit platezh(_address, msg.value);
    }

    function snyatDengi() public payable 
    {
        require(msg.value > 0, "input value more than zero!");
        goi.balance += msg.value;
        emit platezh(goi.userAddress, goi.balance);
    }

    function getBalance() public view returns(uint){
        return goi.balance;
    }
}


