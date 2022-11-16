//SPDX-License-Identifier: MIT
pragma solidity ^0.8.12;

import "@openzeppelin/contracts/interfaces/IERC1271.sol";
import "@openzeppelin/contracts/utils/Address.sol";
import "@openzeppelin/contracts/utils/Strings.sol";
import "@openzeppelin/contracts/utils/cryptography/ECDSA.sol";
import "@openzeppelin/contracts/utils/cryptography/SignatureChecker.sol";
import "@openzeppelin/contracts/utils/cryptography/draft-EIP712.sol";
import "@openzeppelin/contracts/utils/Context.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "./ERC721A.sol";

contract MusicHead is ERC721A, EIP712, Ownable {
    using ECDSA for bytes32;
    using Strings for uint256;

    address WHITELIST_SIGNER = 0xF50Ca4d17Eb4819Ca1590c97eefaC8bd4B08Fe70;
    address FREE_MINT_SIGNER = 0xe3edDD1647C23d6158ea4051c2C4562F8F9336a8;

    string public baseUri;

    uint256 public mintFee = 0.0000000099 ether;
    uint256 public whitelistMintFee = 0.000000099 ether;

    bool public saleIsActive = false;

    uint256 public MAX_SUPPLY = 10000;

    //claimed bitmask
    mapping(uint256 => uint256) private freeMintClaimBitMask;
    mapping(uint256 => uint256) private whitelistClaimBitMask;

    mapping(address => bool) public addressToFreeMinted;
    mapping(address => uint256) public mintedAmount;

    constructor(string memory _baseUri)
        ERC721A("Music Head", "MusicHead")
        EIP712("MusicHead", "1.0.0")
    {
        baseUri = _baseUri;
    }

    modifier mintCompliance() {
        require(saleIsActive, "Sale is not active yet.");
        require(totalSupply() < MAX_SUPPLY, "Sold out");
        require(tx.origin == msg.sender, "Caller cannot be a contract.");
        _;
    }

    function freeMint(bytes calldata _signature, uint256 _nftIndex)
        external
        payable
        mintCompliance
    {
        require(!isClaimed(_nftIndex, false), "NFT: Token already claimed!");
        require(
            _verify(_hash(msg.sender, _nftIndex, 1), _signature, false),
            "Team NFT: Invalid Claiming!"
        );
        _setClaimed(_nftIndex, false);
        _mint(msg.sender, 1);
    }

    function publicMint(uint256 _quantity) external payable mintCompliance {
        require(
            msg.value >= mintFee * _quantity,
            "You do not have enough ETH to pay for this"
        );
        _mint(msg.sender, _quantity);
    }

    function whitelistMint(bytes calldata _signature, uint256 _nftIndex)
        external
        payable
        mintCompliance
    {
        require(!isClaimed(_nftIndex, true), "NFT: Token already claimed!");
        require(
            _verify(_whitelistHash(msg.sender, _nftIndex), _signature, true),
            "NFT WL: Invalid Claiming!"
        );

        require(msg.value >= whitelistMintFee, "Already got your free mint");
        _mint(msg.sender, 1);
    }

    function isClaimed(uint256 _nftIndex, bool isWhiteListSale)
        public
        view
        returns (bool)
    {
        uint256 wordIndex = _nftIndex / 256;
        uint256 bitIndex = _nftIndex % 256;
        uint256 mask = 1 << bitIndex;
        if (isWhiteListSale) {
            return whitelistClaimBitMask[wordIndex] & mask == mask;
        } else {
            return freeMintClaimBitMask[wordIndex] & mask == mask;
        }
    }

    function _setClaimed(uint256 _nftIndex, bool isWhiteListSale) internal {
        uint256 wordIndex = _nftIndex / 256;
        uint256 bitIndex = _nftIndex % 256;
        uint256 mask = 1 << bitIndex;
        if (isWhiteListSale) {
            whitelistClaimBitMask[wordIndex] |= mask;
        } else {
            freeMintClaimBitMask[wordIndex] |= mask;
        }
    }

    function _hash(
        address _account,
        uint256 _nftIndex,
        uint256 _quantity
    ) internal view returns (bytes32) {
        return
            _hashTypedDataV4(
                keccak256(
                    abi.encode(
                        keccak256(
                            "NFT(address _account,uint256 _nftIndex,uint256 _quantity)"
                        ),
                        _account,
                        _nftIndex,
                        _quantity
                    )
                )
            );
    }

    function _whitelistHash(address _account, uint256 _nftIndex)
        internal
        view
        returns (bytes32)
    {
        return
            _hashTypedDataV4(
                keccak256(
                    abi.encode(
                        keccak256("NFT(address _account,uint256 _nftIndex)"),
                        _account,
                        _nftIndex
                    )
                )
            );
    }

    function _verify(
        bytes32 digest,
        bytes memory signature,
        bool isWhitelist
    ) internal view returns (bool) {
        if (isWhitelist)
            return
                SignatureChecker.isValidSignatureNow(
                    WHITELIST_SIGNER,
                    digest,
                    signature
                );
        else
            return
                SignatureChecker.isValidSignatureNow(
                    FREE_MINT_SIGNER,
                    digest,
                    signature
                );
    }

    function _baseURI() internal view virtual override returns (string memory) {
        return baseUri;
    }

    function tokenURI(uint256 _tokenId)
        public
        view
        virtual
        override
        returns (string memory)
    {
        require(_exists(_tokenId), "NFT: URI query for nonexistent token");
        return
            bytes(baseUri).length > 0
                ? string(
                    abi.encodePacked(baseUri, _tokenId.toString(), ".json")
                )
                : "";
    }

    function setbaseUri(string memory newBaseURI) external onlyOwner {
        baseUri = newBaseURI;
    }

    function withdraw() public payable onlyOwner {
        (bool os, ) = payable(owner()).call{value: address(this).balance}("");
        require(os);
    }

    function ActivateSale() public onlyOwner {
        saleIsActive = !saleIsActive;
    }
}
