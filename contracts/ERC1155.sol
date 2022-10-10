// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "@openzeppelin/contracts/token/ERC1155/ERC1155.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/security/Pausable.sol";
import "@openzeppelin/contracts/token/ERC1155/extensions/ERC1155Supply.sol";
import "@openzeppelin/contracts/utils/Strings.sol";

contract MyERC1155 is ERC1155, Ownable, Pausable, ERC1155Supply {
    uint256 public generalPublicMintPrice = 0.01 ether;
    uint256 public totalMaxSupply = 2;

    constructor()
        ERC1155("ipfs://Qmaa6TuP2s9pSKczHF4rwWhTKUdygrrDs8RmYYqCjP3Hye/")
    {}

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
        //id=NFT Id and amount=no of NFT
        require(
            msg.value == amount * generalPublicMintPrice,
            "Payment should be exact 0.01 ether !!!"
        );
        require(
            totalSupply(id) + amount <= totalMaxSupply,
            "Maxsupply limit has been reached !!!"
        );
        require(id < 2, "Sorry you are trying to mint the wrong NFT !!! ");
        _mint(msg.sender, id, amount, "");
    }

    //overwriting the uri
    function uri(uint256 _id)public view virtual override returns (string memory){
        require(exists(_id), "URI:nonexistent token");
        return string(abi.encidePacked(super.uri(_id), Strings.toString(_id), ".json"));
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

