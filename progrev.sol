// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.7.0 <0.9.0;

contract Progrev
{
    struct Goi
    {
        address userAdress;
        uint256 balance;
    }

    event platezh(address _sender, uint _balance);

    mapping(address => uint) result;


    function ShowLohInfo(address progretiy) public view returns(uint)
    {
        return progretiy.balance;
    }
}

