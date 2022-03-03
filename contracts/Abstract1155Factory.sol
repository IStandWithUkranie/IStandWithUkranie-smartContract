// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.7.0 <0.9.0;

/**
 * @title
 * @dev Implements voting process along with vote delegation
 */
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC1155/extensions/ERC1155Supply.sol";

abstract contract Abstract1155Factory is ERC1155Supply, Ownable {
    string name_;
    string symbol_;
    bool public allowsTransfers = false;

    function name() public view returns (string memory) {
        return name_;
    }

    function symbol() public view returns (string memory) {
        return symbol_;
    }

    function setURI(string memory baseURI) external onlyOwner {
        _setURI(baseURI);
    }

    function flipAllowTransfers() public onlyOwner {
        allowsTransfers = true;
    }

    function _beforeTokenTransfer(
        address operator,
        address from,
        address to,
        uint256[] memory ids,
        uint256[] memory amounts,
        bytes memory data
    ) internal virtual override(ERC1155Supply) {
        require(from == address(0) || to == address(0) || allowsTransfers);
        super._beforeTokenTransfer(operator, from, to, ids, amounts, data);
    }
}
