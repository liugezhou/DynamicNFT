## 需求
Free Mint NFT的智能合约721智能合约的实现，能够通过前端来调用Free Mint NFT的合约api，能够在以太坊或者polygon公链上做NFT Mint。 
业务场景为：
我们希望发售一批创始NFT的Mint，允许用户在我们的页面里面申请Mint，由用户自己支付gas费用，Mint成功后，用户可以在自己的钱包地址里面看到这个NFT。

## 梳理
**Free Mint NFT是什么**:

## NFT 智能合约教程：白名单，随机铸造，动态更新 -- B站视频学习记录

这个教程的内容是实现一个 动态NFT，NFT已有技术概念演变艺术概念，成为一种社区互动方式。 
合约教程的主要内容是：
- 实现一个ERC721标准合约
- NFT随机铸造
- 动态更新NFT
- 合约自动化 

### 基础 NFT 合约（ERC721标准）
1. 智能合约IDE remix：https://remix.ethereum.org/
2. 新建blank、新建Dogs.sol
3. [openzeppelin](https://www.openzeppelin.com/) 维护了大量标准和安全相关的库 
    通过 [openzeppelin文档的wizard](https://docs.openzeppelin.com/contracts/4.x/wizard) 生成721标准代码、合约
4. 以[这个](https://looksrare.org/zh-Hans/collections/0xBC4CA0EdA7647A8aB7C2061c2E118A18a936f13D?queryID=7dc8e7b9a18b650b284e2e13322286c7) 为例 查看参数，设置代码。
  - items 10K:表示总共发行1万个，我们的代码暂时发行3个
5. 代码编写、添加注释、关键概念是  mint 和 preMint
6. 使用MetaMask插件。
7. 部署到测试链上地址：https://goerli.etherscan.io/tx/0x0ce38b2967e8f43b25a63384f3fa78182d5ab6fa45482f564ae8960b39407a01，看到success 部署成功
8. 然后在购买的过程中由于余额不足，没有购买成功。
9. 接着去 [open testnet](https://testnets.opensea.io/zh-CN/account/collected) 链接MetaMask,查看我的已创建。

PS: 学习第一章过程中遇到的主要问题  
deploy Injected Provider-MetaMask的时候 显示资金不足，不能确认。  

解决思路就是找资金：
- 挖矿地址：https://goerli-faucet.pk910.de/
这是一个挖矿型的网页，把钱包地址输入进去，无需链接钱包，即可在线挖矿，只要页面不关闭就可以了。  
挖矿速度时快时慢，快的时候 2 分钟就能挖出零点几个测试 ETH，慢的时候可能 10 多分才能挖出零点零几测试 ETH
- Alchemy 水龙头：https://goerlifaucet.com/，这个领的多
- 水龙头赠送：https://faucets.chain.link/
- 群里咨询、从别处借币。

### NFT 的 metadata 以及随机性
1. 通过前面的学习我们看到图片显示不出来，这是由于我们没有设置 metadata,。  
  - 通过[metadata](https://docs.opensea.io/docs/metadata-standards)看到的图，可以看到 metadata 相关元素，
  - metadata的数据通过 tokenURI() 方法获取 。
  - metadata 本质就是一个json文件，可以存储在mysql、sqlServer等中心化数据库中，或者IPFS存储。
  - 保证 token在 mint 时候的随机性，随机数的获得需要引入一个叫做 ChainLink 预言机的服务。

2. IPFS的使用：
  - 先下载几个壁纸 
  - [filebase](https://console.filebase.com/)上创建 Buckets,上传image图片，在代码中定义地址。 
  - 这里特别需要注意的一点是：在filebase上传文件的时候，上传完图片要再次上传json文件，定义的url为json地址，json文件中包含图片地址。 
3. 打开[chain link doc](https://docs.chain.link/),找到 VRF v2：可验证随机函数，找到get Random Number复制代码。
4. 代码修改完毕后编译、部署。 
5. 部署：
  - 通过 [这个网址](https://vrf.chain.link),绑定钱包、create subscription、充值20个link
  - link没有的话，通过
