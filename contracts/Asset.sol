// SPDX-License-Identifier: MIT
pragma solidity >=0.8.10;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/ERC20Burnable.sol";
import "@openzeppelin/contracts/access/Ownable.sol";


contract Asset is ERC20, ERC20Burnable, Ownable {
    constructor(
        string memory _name,
        string memory _symbol
    ) ERC20(_name, _symbol) {
    }

    function mint(uint256 amount,address to) public {
        _mint(to, amount);
    }

    function selfmint(uint256 amount) public onlyOwner {
        _mint(owner(), amount);
    }
}