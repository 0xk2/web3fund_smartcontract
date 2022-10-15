// SPDX-License-Identifier: MIT
pragma solidity >=0.8.10;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/ERC20Burnable.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";

error NO_ASSET();
error UNCHANGEABLE();

contract ShareToken is ERC20, ERC20Burnable {
    using SafeERC20 for ERC20;
    string public about;
    string public avatar;
    address public owner;

    event Redeemed(address indexed to, uint256 amount, uint256 assets);

    ERC20 public asset;

    constructor(
        address _asset,
        string memory _name,
        string memory _symbol,
        uint256 _totalSupply,
        address _owner,
        string memory _about,
        string memory _avatar
    ) ERC20(_name, _symbol) {
        require(_asset != address(0), "Null address asset");
        asset = ERC20(_asset);
        about = _about;
        avatar = _avatar;
        owner = _owner;
        _mint(_owner, _totalSupply);
    }

    function _hasAsset() internal view {
        if (totalAssets() == 0) revert NO_ASSET();
    }

    modifier hasAsset() {
        _hasAsset();
        _;
    }

    function convertToAsset(uint256 _amount) public view returns (uint256) {
        return (_amount * totalAssets()) / totalSupply();
    }

    function redeem(uint256 _amount) public hasAsset {
        uint256 assets = convertToAsset(_amount);
        _burn(msg.sender, _amount);
        asset.safeTransfer(msg.sender, assets);
        emit Redeemed(msg.sender, _amount, assets);
    }

    function totalAssets() public view returns (uint256) {
        return asset.balanceOf(address(this));
    }
}