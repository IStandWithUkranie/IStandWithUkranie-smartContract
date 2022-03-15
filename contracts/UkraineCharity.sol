// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.8.0 <0.9.0;

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
    // lower the prices to below 1 eth
    // ? time limit 2-weeks 10dayes
    // max supply
    // limited amount for each nft !!!
    // mint function onlyOwner
    // limited separated collections
    // create an arr to set the ids minteable at a time

    string baseExtension = ".json";
    address public multisigWallet;
    uint256 public totalraised = 0 ether;
    // 1 = paused - 2 = active
    uint256 paused = 2; // -> timestamps
    uint256[3] nftsMaxSuplly = [5000, 130, 75];

    mapping(address => bool) public whitelist;
    mapping(address => bool) whitelistUsed;

    // @notice event emited when someone donates
    event Donation(address indexed _from, uint256 time, uint256 _value);

    // @notice event that fires when funds are withdrawn
    // @param to address that receives the contract balance
    // @param value value sent to the address
    event Withdrawn(address to, uint256 value);

    constructor(
        string memory _name,
        string memory _symbol,
        string memory _uri,
        address _multisigWallet
    ) ERC1155(_uri) {
        name_ = _name;
        symbol_ = _symbol;
        multisigWallet = _multisigWallet;
    }

    // @notice mint NFTs corresponding to the value sent
    function donate() public payable {
        uint256 amountDonated = msg.value;
        uint256 tier = 1;

        if (amountDonated < 0.21 ether) {
            tier = 1;
        } else if (amountDonated < 0.51 ether) {
            tier = 2;
        } else {
            tier = 3;
        }
        mint(tier);
    }

    // @notice mint all the nfts to the msg.sender
    function whitelistDonation() external payable {
        require(
            !whitelistUsed[msg.sender],
            "you have already claimed your whitelist gift"
        );
        require(whitelist[msg.sender], "You must be in the whitelist");
        whitelistUsed[msg.sender] = true;
        mint(3);
    }

    function mint(uint256 _tier) private {
        require(paused != 1, "Contract is paused");
        require(msg.value >= 0.01 ether, "You must donate at least 0.01 ether");

        for (uint256 i = 0; i < 3; ++i)
            require(totalSupply(i + 1) + 1 <= nftsMaxSuplly[i], "one");

        for (uint256 i = 0; i < _tier; ) {
            _mint(msg.sender, (i + 1), 1, "");
            unchecked {
                ++i;
            }
        }
        totalraised += msg.value;
        emit Donation(msg.sender, block.timestamp, msg.value);
    }

    // @notice giveaway nft of the selected tier to receiver
    // @param nftTier set the nft to be minted
    // @param receiver address to receive the NFT
    function giveAway(uint256 nftTier, address receiver) public onlyOwner {
        _mint(receiver, nftTier, 1, "");
    }

    function addToWhitelist(address _add) external onlyOwner {
        whitelist[_add] = true;
    }

    function flipPause() external onlyOwner {
        if (paused == 1) paused = 2;
        if (paused == 2) paused = 1;
    }

    // @notice withdraw all the funds to the multisig wallet
    function withdrawAll() public payable onlyOwner {
        (bool succ, ) = multisigWallet.call{value: address(this).balance}("");
        require(succ, "transaction failed");
        emit Withdrawn(multisigWallet, address(this).balance);
    }

    // @notice change the supply of the selected tier
    // @param _tier tier maxSupply to be cahnged
    // @param _newMaxAmount Max supply to be assigned to the nft
    function setMaxSupplly(uint256 _tier, uint256 _newMaxAmount)
        external
        onlyOwner
    {
        nftsMaxSuplly[_tier] = _newMaxAmount;
    }

    // @notice change all NFTs maxSupply
    // @param array of new Supplys [tier1, tier2, tier3]
    function batchSetMaxSupply(uint256[3] memory _newSupplys)
        external
        onlyOwner
    {
        for (uint256 i = 0; i < _newSupplys.length; ++i)
            nftsMaxSuplly[i] = _newSupplys[i];
    }

    // @notice returns the  uri for the selected NFT
    // @param _id NFT id
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
