// SPDX-License-Identifier: MIT

pragma solidity^0.8.9;

import  "@openzeppelin/contracts/access/Ownable.sol";

contract Item{

    uint public  PriceInwei;
    bool public paid;
    uint public index;
    ItemManager parentContract;

    constructor(ItemManager _parentContract, uint _price, uint _index){
        parentContract= _parentContract;
        PriceInwei=_price;
        index= _index;
    }

    receive() external payable{
    require (!paid,"the Item is already beign sold");
    require(msg.value== PriceInwei, "Sorry, you dont have enough balance" );
        paid=true;
        (bool success,) = address(parentContract).call{value:msg.value}(abi.encodeWithSignature("payItem(uint256)", index));
        require(success,"your transaction is not sucessful");
    }
}

contract ItemManager is Ownable{

    enum ItemState{ created,paid,delivered}
    struct ItemInfo{
        Item _item;
        ItemState state;
        string identifer;
        uint price;
    }
    mapping (uint => ItemInfo) public items;
    mapping (uint => address) public Payments;

    uint public ItemIndex;


    event Itemcreation (uint _index,string _name, uint _price, uint  _state , address _address );
    event ItemPayment (uint _index, uint  _state , address _address );
    event ItemDelivery (uint _index, uint  _state, address _address  );

    function createItem(string memory _name, uint _price) public onlyOwner{
    Item _item= new Item(this, _price, ItemIndex);
    items[ItemIndex]._item=_item;
    items[ItemIndex].identifer =_name;
    items[ItemIndex].price = _price;
    items[ItemIndex].state= ItemState.created;
    Payments[ItemIndex]= msg.sender;
    emit Itemcreation (ItemIndex,_name , _price , uint (ItemState.created), address( _item) );
    ItemIndex++;

       }

    function payItem(uint _index) public payable {
        require(items[_index].state == ItemState.created,"sorry item is not on inventory");
        require(msg.value==items[_index].price, "Sorry, you dont have enough balance" );
        items[_index].state = ItemState.paid;
        emit ItemPayment(_index, uint8(items[_index].state),  address(items[_index]._item));

    }

    function deliverItem(uint _index) public onlyOwner {
        require(items[_index].state == ItemState.paid,"sorry item is not on inventory");
       items[ItemIndex].state == ItemState.delivered;
        emit ItemDelivery(_index, uint(items[_index].state) ,  address(items[_index]._item) );
    }


}