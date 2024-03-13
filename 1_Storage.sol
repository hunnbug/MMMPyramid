// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.7.0 <0.9.0;

contract EstateAgency{

    address payable public owner;
    constructor(){ owner = payable(msg.sender); }

    enum EstateType {House, Flat, Loft} //перечисление типа недвижимости
    enum AdvertisementStatus {Opend, Closed} //перечесление для статуса обьявления
    
    struct Estate{  //структура для недвижимости
        uint estateId;
        uint size;
        string photo;
        bool isActive;
        address owner;
        uint rooms;
        EstateType esType;
    }

    struct Advertisement{ //структура для обьявления
        address owner;
        address buyer;
        uint price;
        uint dateTime;
        bool isActive;
        AdvertisementStatus adStatus;
        uint estateId;
    }

    Estate[] public estates;
    Advertisement[] public ads;

    event EstateCreated(uint ID, address owner);
    event AdCreated(uint adId, uint estateId, address owner);
    event EstateStatusUpdated(uint estateId, bool isActive);
    event AdStatusUpdated(uint adId, AdvertisementStatus adStatus);
    event EstatePurchased(uint adId, address buyer, uint price);
    event FundsWithdrawn(address receiver, uint amount);

    modifier enoughValue(uint value, uint price){
        require(value >= price, unicode"У вас недостаточно средств");
        _;
    }

    modifier onlyEstateOwner(uint estateId){
        require(estates[estateId].owner == owner, unicode"Вы не владелец недвижимоси");
        _;
    }

    modifier isActiveEstate(uint estateId){
        require(estates[estateId].isActive, unicode"Недвижимость недоступна");
        _;
    }

    modifier isAdClosed(uint adId){
        require(ads[adId].adStatus != AdvertisementStatus.Closed, unicode"Данное объявление закрыто");
        _;
    }

    modifier notOwner(uint adId){
        require(ads[adId].owner != owner, unicode"Владелец не может купить свою недвижимость");
        _;
    }


// нельзя создать дважды одно и тоже
    function createEstate(uint size, string memory photo, uint rooms, EstateType esType) public{
        require(size > 0, unicode"Площадь должна быть больше 0");
        estates.push(Estate(estates.length + 1, size, photo, true, owner, rooms, esType));
        emit EstateCreated(estates.length, owner);
    }

//создание объявления на наличие недвижимости, 
//недвижимость должна быть активной, 
//объявление может создать только владелец недвижимости, 
//мы не можем создать несколько объявлений по одной и той же недвижимости
    function createAd(uint ID, uint cena) public onlyEstateOwner(ID) isActiveEstate(ID){
        address b = address(0);
        ads.push(Advertisement(owner, b, cena, block.timestamp, true, AdvertisementStatus.Opend, ID));
    }

//это может делать только владелец недвижимости. 
//и если мы меняем статус на false, то объявление (если оно есть) закрывается
    function updateEstateStatus(uint ID) public onlyEstateOwner(ID){
        require(ads[ID].owner == owner, "you are not an owner");
        
        if(estates[ID].isActive == true)
        {
            estates[ID].isActive = false;
        }
        else
        {
            estates[ID].isActive = true;
        }
    }

//только владелец объявления, если статус closed, то мы не может открыть это объявдение заново
    function updateAdStatus(uint ID) public {
        require(ads[ID].owner == owner, "you are not an owner");

        if(ads[ID].adStatus == AdvertisementStatus.Closed)
        {
            ads[ID].adStatus = AdvertisementStatus.Opend;
        }
        else 
        {
            ads[ID].adStatus = AdvertisementStatus.Closed;
        }
    }

//проверка на не владельца, проверка на достаточное количество средств, проверка на статус объявления (не closed)
    function buyEstate(uint ID) public payable isActiveEstate(ID) isAdClosed(ID){
        address payable poluchatel = payable(ads[ID].owner);
        require(ads[ID].owner != owner, "you can not buy yours nedvizh");
        estates[ID].isActive = false;
        for(uint i = 0; i < ads.length; i++)
        {
            if(ads[i].estateId == ID)
            {
                delete ads[i];
            }
        }
        poluchatel.transfer(ads[ID].price);
    }

//мы не можем снять больше чем у нас есть
    function withDraw(uint amount) public {
        require(amount <= address(this).balance, "you don't have enough money for this operation");
        owner.transfer(amount);
    }

    function getBalance() public view returns(uint){
        return address(this).balance;
    }

    function getEstates() public view returns(Estate[] memory){
        return estates;
    }

    function getAds() public view returns(Advertisement[] memory){
        return ads;
    }


}