// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "@openzeppelin/contracts/token/ERC1155/ERC1155.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/security/Pausable.sol";
import "@openzeppelin/contracts/token/ERC1155/extensions/ERC1155Supply.sol";
import "@openzeppelin/contracts/utils/Strings.sol";
import "@openzeppelin/contracts/finance/PaymentSplitter.sol";

contract MyERC1155 is
    ERC1155,
    Ownable,
    Pausable,
    ERC1155Supply,
    PaymentSplitter
{
    uint256 public generalPublicMintPrice = 0.01 ether;
    uint256 public vipMintPrice = 0.001 ether;
    uint256 public totalMaxSupply = 20;
    uint256 maxPerWallet = 2;

    bool public generalPublicMintOpen = false;
    bool public vipMintOpen = false;

    //vipList
    mapping(address => bool) vipList;
    mapping(address => uint256) mintedPerWallet;

    //0994845djbd563:true means this is vip

    constructor(address[] memory _payees, uint256[] memory _shares)
        ERC1155("ipfs://Qmaa6TuP2s9pSKczHF4rwWhTKUdygrrDs8RmYYqCjP3Hye/")
        PaymentSplitter(_payees, _shares)
    {}

    //function to edit mint opan and close
    function editOpenCloseMintStatus(
        bool _generalPublicMintStatus,
        bool _vipMintStatus
    ) external onlyOwner {
        generalPublicMintOpen = _generalPublicMintStatus;
        vipMintOpen = _vipMintStatus;
    }

    function addVip(address[] calldata vipAddresses) external onlyOwner {
        for (uint256 i = 0; i < vipAddresses.length; i++) {
            vipList[vipAddresses[i]] = true;
        }
    }

    function setURI(string memory newuri) public onlyOwner {
        _setURI(newuri);
    }

    function pause() public onlyOwner {
        _pause();
    }

    function unpause() public onlyOwner {
        _unpause();
    }

    function repetativeTaskFunction(uint256 id, uint256 amount) internal {
        require(
            mintedPerWallet[msg.sender] + amount <= maxPerWallet,
            "Wallet limit has been reached !!!"
        );
        //we can only mint certain id 0 and 1 like addidas NFT
        require(id < 2, "You can only min 0 & 1 id !!! ");
        //totalSupply is the total amount of tokens in with a given id.
        require(
            totalSupply(id) + amount <= totalMaxSupply,
            "Maxsupply limit has been reached !!!"
        );

        _mint(msg.sender, id, amount, "");

        //only 2 NFT a single wallet/user can mint
        mintedPerWallet[msg.sender] += amount;
    }

    function generalPublicMint(uint256 id, uint256 amount) public payable {
        require(generalPublicMintOpen, "Right now generalPublucMint is closed");
        //id=NFT Id and amount=no of NFT
        require(
            msg.value == amount * generalPublicMintPrice,
            "Payment should be exact 0.01 ether !!!"
        );
        repetativeTaskFunction(id, amount);
    }

    function vipMint(uint256 id, uint256 amount) public payable {
        require(vipMintOpen, "Right now vipMint is closed");
        require(vipList[msg.sender], "You are not the vip");
        require(
            msg.value == amount * vipMintPrice,
            "Payment should be 0.01 ether per NFT"
        );
        repetativeTaskFunction(id, amount);
    }

    //To show the NFT we need the complete uri with NFT id
    // Clients calling this function must replace the `\{id\}` substring with the * actual token type ID.
    //overwriting the uri
    function uri(uint256 id)
        public
        view
        virtual
        override
        returns (string memory)
    {
        require(exists(id), "URI:nonexistent token");

        return
            //initial ipfs uri +current id of NFT +json
            string(
                abi.encodePacked(super.uri(id), Strings.toString(id), ".json")
            );
        //this is how we get the abi now string: ipfs://Qmaa6TuP2s9pSKczHF4rwWhTKUdygrrDs8RmYYqCjP3Hye/1.json
        //actual json for the NFT
        //To access from the browser https://ipfs.io/ipfs/Qmaa6TuP2s9pSKczHF4rwWhTKUdygrrDs8RmYYqCjP3Hye/1.json
    }

    //withdrarw smart contract balance
    function withdraw(address addr) external onlyOwner {
        uint256 balance = address(this).balance; //get balance od contract
        payable(addr).transfer(balance); //transfer to addr
    }

    function mintBatch(
        address to,
        uint256[] memory ids,
        uint256[] memory amounts,
        bytes memory data
    ) public onlyOwner {
        _mintBatch(to, ids, amounts, data);
    }

    function _beforeTokenTransfer(
        address operator,
        address from,
        address to,
        uint256[] memory ids,
        uint256[] memory amounts,
        bytes memory data
    ) internal override(ERC1155, ERC1155Supply) whenNotPaused {
        super._beforeTokenTransfer(operator, from, to, ids, amounts, data);
    }
}

// ERC721->one owner fep NFT/Token
// ERC1155->one NFT/Token can have multiple owner
