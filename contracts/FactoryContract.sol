// SPDX-License-Identifier: MIT
pragma solidity >=0.8.10;

import "@openzeppelin/contracts/utils/Counters.sol";
import "./ShareToken.sol";

contract ShareTokenFactory {
    event Created(address shareToken);
    mapping (uint256 => address) public shareTokens;
    using Counters for Counters.Counter;
    Counters.Counter private _tokenIds;

    function create(
        address _asset,
        string memory _name,
        string memory _symbol,
        uint256 _totalSupply,
        string memory _about,
        string memory _avatar
    ) public {
        ERC20 shareToken = new ShareToken(_asset, _name, _symbol, _totalSupply, msg.sender, _about, _avatar);
        _tokenIds.increment();
        uint256 newTokenId = _tokenIds.current();
        shareTokens[newTokenId] = address(shareToken);
        emit Created(address(shareToken));
    }
}