// SPDX-License-Identifier: MIT
pragma solidity >=0.8.10;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/ERC20Burnable.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "@openzeppelin/contracts/utils/Counters.sol";

contract Sale {
    event Listed(uint256 indexed index, address indexed assetToken, address priceToken);
    event Bought(uint256 indexed index, address buyer, uint256 amount);
    event Stopped(uint256 indexed index);

    using SafeERC20 for ERC20;
    using Counters for Counters.Counter;
    struct Listing {
        address assetToken;
        address priceToken;
        uint256 startAt;
        uint256 endAt;
        uint256 price;
        uint256 assetTokenAmount;
        uint256 priceTokenAmount;
        bool stopped;
        address owner;
    }

    mapping (uint256 => Listing) public listings;
    Counters.Counter private _listingIds;
    
    function list(
        address _assetToken, address _priceToken,
        uint256 _startAt, uint256 _endAt,
        uint256 _price, uint256 _assetTokenAmount) public
    {
        //require(ERC20(_assetToken).allowance(msg.sender, address(this)) >= _assetTokenAmount);
        require(ERC20(_assetToken).balanceOf(msg.sender) >= _assetTokenAmount);
        ERC20(_assetToken).safeTransfer(address(this), _assetTokenAmount);
        _listingIds.increment();
        uint256 newListingId = _listingIds.current();
        listings[newListingId] = Listing(
            _assetToken,
            _priceToken,
            _startAt,
            _endAt,
            _price,
            _assetTokenAmount,
            0,
            false,
            msg.sender
        );
        emit Listed(newListingId, _assetToken, _priceToken);
    }

    function buy(uint256 index, uint256 assetAmountToBuy) public {
        uint256 priceAmountToPay = assetAmountToBuy * listings[index].price;
        ERC20 priceToken = ERC20(listings[index].priceToken);
        ERC20 assetToken = ERC20(listings[index].assetToken);

        // should sale event happenning?
        require(block.timestamp >= listings[index].startAt, "Not started yet");
        require(block.timestamp <= listings[index].endAt, "Sale is over");
        require(listings[index].stopped == false, "Sale is stopped");

        // enough amount to sell?
        require(listings[index].assetTokenAmount >= assetAmountToBuy, "Not enough token to sell");
        // enough priceToken to buy?
        require(priceToken.allowance(msg.sender, address(this)) >= priceAmountToPay, "Need to approve before payment");
        require(priceToken.balanceOf(msg.sender) >= priceAmountToPay, "You dont have enough token");
        // let's transact
        priceToken.safeTransferFrom(msg.sender, address(this), priceAmountToPay);
        listings[index].priceTokenAmount += priceAmountToPay;
        listings[index].assetTokenAmount -= assetAmountToBuy;
        assetToken.safeTransfer(msg.sender, assetAmountToBuy);

        emit Bought(index, msg.sender, assetAmountToBuy);
    }

    function stop(uint256 index) public{
        require(listings[index].owner == msg.sender, "You dont have permission");
        require(listings[index].stopped == false, "This event already stopped and fund already emptied");

        listings[index].stopped = true;
        uint256 _assetToTransfer = listings[index].assetTokenAmount;
        uint256 _priceToTransfer = listings[index].priceTokenAmount;
        listings[index].assetTokenAmount = 0;
        listings[index].priceTokenAmount = 0;
        
        // transfer Asset to owner
        ERC20(listings[index].assetToken).safeTransfer(msg.sender, _assetToTransfer);
        // transfer Price to owner
        ERC20(listings[index].priceToken).safeTransfer(msg.sender, _priceToTransfer);

        emit Stopped(index);
    }
}