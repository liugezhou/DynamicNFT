// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "@chainlink/contracts/src/v0.8/interfaces/VRFCoordinatorV2Interface.sol";
import "@chainlink/contracts/src/v0.8/VRFConsumerBaseV2.sol";

contract Dogs is ERC721, ERC721Enumerable, ERC721URIStorage, Ownable, VRFConsumerBaseV2 {
    using Counters for Counters.Counter;
    uint256 public MAX_AMOUNT = 6; //最多发行个数
    // string uri = "";
    Counters.Counter private _tokenIdCounter;
    mapping(address => bool) public whiteList;
    bool public preMintWindow = false;
    bool public mintWindow = false;
    
    // METADATA
    string constant METADATA_BG1 = "ipfs://QmZ8K5L7BqnvdZ4RbKDNuUqD5s7eDQG8VwtfzJRhMrbtqD";
    string constant METADATA_BG2 = "ipfs://QmNjUEfZYVZa3wPvPaBu2KCp5URVEJVmaRR8xHStrRxV7U";
    string constant METADATA_BG3 = "ipfs://QmXsmaF98Vw2H1fgRCxaEEi4zJRsLzCnpXH1moqZvuNLYy";
    string constant METADATA_BG4 = "ipfs://QmcpFmHvUZML1wqDEWvMZQbk9MiJ4pMqKiWcP9ApGJDgDP";


    // config of chainlink VRF
    VRFCoordinatorV2Interface COORDINATOR;
    uint64 s_subscriptionId; 
    bytes32 keyHash =
        0x79d3d8832d904592c0bf9818b621522c988bb8b0c05cdc3b15aea1b6e8db0c15;
    uint32 callbackGasLimit = 100000;
    uint16 requestConfirmations = 3;
    uint32 numWords = 1; //申请的随机数个数
    mapping(uint256 => uint256) reqIdToTokenId;

    constructor(uint64 subId) ERC721("Dogs", "DG") VRFConsumerBaseV2(0x2Ca8E0C643bDe4C2E08ab1fA0da3401AdAD7734D) {
        s_subscriptionId = subId;
        COORDINATOR = VRFCoordinatorV2Interface(0x2Ca8E0C643bDe4C2E08ab1fA0da3401AdAD7734D);
    }

    // 提前购买的优惠
    function preMint()  public payable{
        require(preMintWindow, "Premint is not open yet!");
        require(msg.value == 0.001 ether, "The price of dog ngt is 0.001 ether"); //获取交易资金
        require(whiteList[msg.sender], "You are not in the white list");
        require(balanceOf(msg.sender) < 1, "Max amount of NFT minted by an address is 1");//限制数量每个人不能超过1
        require(totalSupply() < MAX_AMOUNT, "Dog NFT is sold out!");
        uint256 tokenId = _tokenIdCounter.current();
        _tokenIdCounter.increment();
        _safeMint(msg.sender, tokenId);
        request(tokenId);
    }

   // 每个去mint这个nft的人，得到一个对应的nft，以及它的token id，to指的是mint完发给谁，url是指nft北周的metadata的网址是什么
   // payable 是指调用的时候发送一部分的资金
   // function safeMint(address to, string memory uri) public onlyOwner {
    function Mint() public payable {
        require(mintWindow, "Mint is not open yet!");
        require(msg.value == 0.002 ether, "The price of dog ngt is 0.002 ether"); //获取交易资金
        require(totalSupply() < MAX_AMOUNT, "Dog NFT is sold out!");
        uint256 tokenId = _tokenIdCounter.current();
        _tokenIdCounter.increment();
        _safeMint(msg.sender, tokenId);
        request(tokenId);
    }

    // 提现、权限onluOwner，external表示不会有其它去调用
    function withdraw(address addr) external onlyOwner {
        payable(addr).transfer(address(this).balance);
    }
   
    // 给链上的一个预言机一个请求
     function request(uint256 _tokenId)
        internal
        returns (uint256 requestId)
    {
        // Will revert if subscription is not set and funded.
        requestId = COORDINATOR.requestRandomWords(
            keyHash,
            s_subscriptionId,
            requestConfirmations,
            callbackGasLimit,
            numWords
        );
        reqIdToTokenId[requestId] = _tokenId;
        return requestId;
    }

    // 接收一个结果
    function fulfillRandomWords(
        uint256 _requestId,
        uint256[] memory _randomWords
    ) internal override {
        uint256 randomNumber = _randomWords[0] % 4;
        if (randomNumber == 0) {
            _setTokenURI(reqIdToTokenId[_requestId], METADATA_BG1);
        } else if (randomNumber == 1) {
            _setTokenURI(reqIdToTokenId[_requestId], METADATA_BG2);
        } else if (randomNumber == 2) {
            _setTokenURI(reqIdToTokenId[_requestId], METADATA_BG3);
        } else {
            _setTokenURI(reqIdToTokenId[_requestId], METADATA_BG4);
        }
    }

    // 把一些地址加入到白名单当中
    function addToWhiteList(address[] calldata addrs) public onlyOwner {
        for(uint256 i = 0; i < addrs.length;i ++){
            whiteList[addrs[i]] = true;
        }
    }

    function setWindow(bool _preMintOpen,bool _mintOpen) public {
          preMintWindow = _preMintOpen;
          mintWindow = _mintOpen;
      }
    // The following functions are overrides required by Solidity.

    function _beforeTokenTransfer(address from, address to, uint256 tokenId, uint256 batchSize)
        internal
        override(ERC721, ERC721Enumerable)
    {
        super._beforeTokenTransfer(from, to, tokenId, batchSize);
    }

    function _burn(uint256 tokenId) internal override(ERC721, ERC721URIStorage) {
        super._burn(tokenId);
    }

    function tokenURI(uint256 tokenId)
        public
        view
        override(ERC721, ERC721URIStorage)
        returns (string memory)
    {
        return super.tokenURI(tokenId);
    }

    function supportsInterface(bytes4 interfaceId)
        public
        view
        override(ERC721, ERC721Enumerable)
        returns (bool)
    {
        return super.supportsInterface(interfaceId);
    }
}