// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.7.0 <0.9.0;

/**
 * @title charity nft erc1155 smart contract
 * @dev Allow a charity organization give non transferable nfts to contributors
 * @author Alex encinas
 */
import "./Abstract1155Factory.sol";
import "@openzeppelin/contracts/utils/Strings.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import "@openzeppelin/contracts/token/ERC1155/IERC1155.sol";
import "@openzeppelin/contracts/utils/Strings.sol";

contract UkranieCharity is Abstract1155Factory {
    // ? maybe we need to implement a merkle root based whitelist
    // 0.01 - 0.49 | 0.5 - 1 | >1

    address multisigWallet;
    // ? set this values in the contructor ?
    uint256 tier1Price = 0.02 ether;
    uint256 tier2Price = 0.1 ether;
    uint256 tier3Price = 0.5 ether;
    uint256 public totalraised = 0 ether;
    string baseExtension = ".json";

    // @dev: event emited when someone donates
    event donated(address indexed from, uint256 amount);

    // @dev: event that fires when funds are withdrawn
    event withdrawn(address to, uint256 value);

    constructor(
        string memory _name,
        string memory _symbol,
        string memory _uri,
        address _multisigWallet
    ) ERC1155(_uri) {
        name_ = _name;
        symbol_ = _symbol;
        multisigWallet = _multisigWallet;
        _setURI(_uri);
    }

    function donate() public payable {
        uint256 amountDonated = msg.value;
        uint256 tier = 1;

        // set the donation tier depending on the value sent
        if (amountDonated < tier1Price) {
            tier = 1;
        } else if (amountDonated >= tier1Price && amountDonated < tier2Price) {
            tier = 2;
        } else {
            tier = 3;
        }

        //mint the corresponding nfts depending of the tier setted.
        for (uint256 i = 1; i <= tier; ++i) {
            _mint(msg.sender, i, 1, "");
        }

        totalraised += amountDonated;
        emit donated(msg.sender, amountDonated);
    }

    function withdrawAll() public payable onlyOwner {
        (bool succ, ) = multisigWallet.call{value: address(this).balance}("");
        require(succ, "transaction failed");
        emit withdrawn(multisigWallet, address(this).balance);
    }

    function uri(uint256 _id) public view override returns (string memory) {
        require(exists(_id), "URI: nonexistent token");
        return
            string(
                abi.encodePacked(
                    super.uri(_id),
                    Strings.toString(_id),
                    baseExtension
                )
            );
    }
}
