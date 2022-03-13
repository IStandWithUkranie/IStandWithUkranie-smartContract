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
    //and people will receive the 3 nfts no matter how much they have donated

    // ? time limit 2-weeks 10dayes

    // max supply

    // limited amount for each nft

    // mint function onlyOwner

    // limited separated collections
    // create an arr to set the ids minteable at a time

    address multisigWallet;
    // ? set this values in the contructor ?
    uint256 tier1Price = 0.049 ether;
    uint256 tier2Price = 0.05 ether;
    uint256 tier3Price = 1 ether;
    uint256 public totalraised = 0 ether;
    string baseExtension = ".json";
    // using uint at 1 bc of gas savings
    uint256 paused = 1;

    // @dev: event emited when someone donates
    event donated(address indexed from, uint256 amount, uint256 timestamp);

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
        //? mint some nfts to the multisig for promotion porpuses
    }

    function donate() public payable {
        require(paused == 1);
        require(msg.value >= 0.01 ether);
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
        //unchecked ++i for about 12k gas savings per iteration
        for (uint256 i = 1; i <= tier; ) {
            _mint(msg.sender, i, 1, "");
            unchecked {
                ++i;
            }
        }

        totalraised += amountDonated;
        emit donated(msg.sender, amountDonated, block.timestamp);
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
