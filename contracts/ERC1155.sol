// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "@openzeppelin/contracts/token/ERC1155/ERC1155.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/security/Pausable.sol";
import "@openzeppelin/contracts/token/ERC1155/extensions/ERC1155Supply.sol";
import "@openzeppelin/contracts/utils/Strings.sol";

contract MyERC1155 is ERC1155, Ownable, Pausable, ERC1155Supply {
    uint256 public generalPublicMintPrice = 0.01 ether;
    uint256 public vipMintPrice = 0.001 ether;
    uint256 public totalMaxSupply = 2;
    bool public generalPublicMintOpen = false;
    bool public vipMintOpen = false;

    constructor()
        ERC1155("ipfs://Qmaa6TuP2s9pSKczHF4rwWhTKUdygrrDs8RmYYqCjP3Hye/")
    {}

    //function to edit mint opan and close
    function editOpenCloseMintStatus(
        bool _generalPublicMintStatus,
        bool _vipMintStatus
    ) external onlyOwner {
        generalPublicMintOpen = _generalPublicMintStatus;
        vipMintOpen = _vipMintStatus;
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

    function generalPublicMint(uint256 id, uint256 amount) public payable {
        require(generalPublicMintOpen, "Right now generalPublucMint is closed");
        //id=NFT Id and amount=no of NFT
        require(
            msg.value == amount * generalPublicMintPrice,
            "Payment should be exact 0.01 ether !!!"
        );

        //totalSupply is the total amount of tokens in with a given id.
        require(
            totalSupply(id) + amount <= totalMaxSupply,
            "Maxsupply limit has been reached !!!"
        );
        //we only mint certain id 0 and 1 like addidas NFt
        require(id < 2, "You can only min 0 & 1 id !!! ");
        _mint(msg.sender, id, amount, "");
    }

    function vipMint(uint256 id, uint256 amount) public payable {
        require(vipMintOpen, "Right now vipMint is closed");
        require(
            msg.value == amount * vipMintPrice,
            "Payment should be 0.01 ether per NFT"
        );
        //totalSupply is the total amount of tokens in with a given id.
        require(
            totalSupply(id) + amount <= totalMaxSupply,
            "Maxsupply limit has been reached !!!"
        );
        //we only mint certain id 0 and 1 like addidas NFt
        require(id < 2, "You can only min 0 & 1 id !!! ");
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
