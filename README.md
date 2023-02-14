## 需求

Free Mint NFT 的智能合约 721 智能合约的实现，能够通过前端来调用 Free Mint NFT 的合约 api，能够在以太坊或者 polygon 公链上做 NFT Mint。
业务场景为：
我们希望发售一批创始 NFT 的 Mint，允许用户在我们的页面里面申请 Mint，由用户自己支付 gas 费用，Mint 成功后，用户可以在自己的钱包地址里面看到这个 NFT。

---

## 梳理

**NFT**  
NFT 是 Non-FungibleTokens 的缩写。
NFT 是指不可互换的代币，也称为非同质代币，像是艺术品，每件都不一样。它们之间无法相互替换。  
BTC、ETH 这些代币是同质代币。

**Free Mint NFT 是什么**:

**[常见的 NFT 用语解释](https://www.playbtc.cn/rumen/53990.html)**：

- Floor Price(地板价)：某一系列 NFT 在交易市场中的最低入手价格，Floor Price 越高，代表整个系列的 NFT 都越来越高价。
- OpenSea：最大最有代表性的一个非同质化代币在线交易市场、买卖 NFT。
- PFP：ProfilePicture，个人资料图片，不少的「10k Project」其实就是 PFP Project。
- Gas：购买 NFT 时都需用向矿工支付费用，这个费用就是 Gas，简单理解为就是买卖的手续费。
- Mint：铸造。每笔交易都无法窜改，且可以认证。当你要买下一幅新的 NFT 作品之时，那幅作品先要通过过平台加入区块链技术，可能要花费上数天的「铸造时间」，才可以真正 Mint「铸造」成 NFT！
- Burn：销毁。NFT 可以 Mint「铸造」，就当然可以 Burn「销毁」，以区块链技术将内容销毁，最后只留下铸造和烧毁日期。
- 空投：免费收到一些加密货币或新的 NFT，通常是一种奖励或者赠送给一些早期参与者。

---

## NFT 智能合约教程：白名单，随机铸造，动态更新 -- [B 站视频](https://www.bilibili.com/video/BV1T24y167KT?p=1&vd_source=a3f9b7b9a17d4e2ff6b5b273f2926f4c)学习记录

这个教程的内容是实现一个 动态 NFT，NFT 已有技术概念演变艺术概念，成为一种社区互动方式。
合约教程的主要内容是：

- 实现一个 ERC721 标准合约
- NFT 随机铸造
- 动态更新 NFT
- 合约自动化

### 第一章：基础 NFT 合约（ERC721 标准）

1. 智能合约 IDE remix：https://remix.ethereum.org/
2. 新建 blank、新建 Dogs.sol
3. [openzeppelin](https://www.openzeppelin.com/) 维护了大量标准和安全相关的库
   通过 [openzeppelin 文档的 wizard](https://docs.openzeppelin.com/contracts/4.x/wizard) 生成 721 标准代码、合约
4. 以[这个](https://looksrare.org/zh-Hans/collections/0xBC4CA0EdA7647A8aB7C2061c2E118A18a936f13D?queryID=7dc8e7b9a18b650b284e2e13322286c7) 为例 查看参数，设置代码。

- items 10K:表示总共发行 1 万个，我们的代码暂时发行 3 个

5. 代码编写、添加注释、关键概念是 mint 和 preMint
6. 使用 MetaMask 插件。
7. 部署到测试链上地址：https://goerli.etherscan.io/tx/0x0ce38b2967e8f43b25a63384f3fa78182d5ab6fa45482f564ae8960b39407a01，看到success 部署成功
8. 然后在购买的过程中由于余额不足，没有购买成功。
9. 接着去 [open testnet](https://testnets.opensea.io/zh-CN/account/collected) 链接 MetaMask,查看我的已创建。

PS: 学习第一章过程中遇到的主要问题  
deploy Injected Provider-MetaMask 的时候 显示资金不足，不能确认。

解决思路就是找资金：

- 挖矿地址：https://goerli-faucet.pk910.de/
  这是一个挖矿型的网页，把钱包地址输入进去，无需链接钱包，即可在线挖矿，只要页面不关闭就可以了。  
  挖矿速度时快时慢，快的时候 2 分钟就能挖出零点几个测试 ETH，慢的时候可能 10 多分才能挖出零点零几测试 ETH
- Alchemy 水龙头：https://goerlifaucet.com/，这个领的多
- 水龙头赠送：https://faucets.chain.link/
- 群里咨询、从别处借币。

### 第二章：NFT metadata & 随机铸造

1. 通过前面的学习我们看到图片显示不出来，这是由于我们没有设置 metadata,。

- 通过[metadata](https://docs.opensea.io/docs/metadata-standards)看到的图，可以看到 metadata 相关元素，
- metadata 的数据通过 tokenURI() 方法获取 。
- metadata 本质就是一个 json 文件，可以存储在 mysql、sqlServer 等中心化数据库中，或者 IPFS 存储。
- 保证 token 在 mint 时候的随机性，随机数的获得需要引入一个叫做 ChainLink 预言机的服务。

2. IPFS 的使用：

- 先下载几个壁纸
- [filebase](https://console.filebase.com/)上创建 Buckets,上传 image 图片，在代码中定义地址。
- 这里特别需要注意的一点是：在 filebase 上传文件的时候，上传完图片要再次上传 json 文件，定义的 url 为 json 地址，json 文件中包含图片地址。

3. 打开[chain link doc](https://docs.chain.link/),找到 VRF v2：可验证随机函数，找到 get Random Number 复制代码。
4. 代码修改完毕后编译、部署。
5. 部署：

- 通过 [vrf.chain](https://vrf.chain.link),绑定钱包、create subscription、充值 20 个 link
- link 没有的话，通过提示充值即可。

6. 回到 remix 编辑器下，将在 [vrf.chain](https://vrf.chain.link) 刚生成的 ID 值填入到 Deploy 旁边，然后点击 Deploy
7. deploy 成功后，复制 Deployed Contracts 值 在[vrf.chain](https://vrf.chain.link) 中 Add consumer 中填入。
8. 然后设置 window、白名单，填入 value 值，preMint、mint 即可。
9. preMint 或者 mint 成功后，在 [testnets](https://testnets.opensea.io/zh-CN)绑定钱包，查看即可。

### 第三章：动态更新 NFT metadata

动态变化的场景：用户持有的 NFT 随着外参数变化而动态变化。
暂未学习

### 第四章：合约自动化
暂未学习

## Web3.js 相关

- 获取 web3 对象

```
let Web3 = require('web3');
const {log} =console
const provider = new Web3.providers.HttpProvider(
  "http://127.0.0.1:9545"
);
const provider2 = new Web3.providers.HttpProvider(
  "http://127.0.0.1:9999"
);
let web3 = new Web3(provider);
log("No web3 instance injected, using Local web3.");
log(web3.modules);
log(web3.version);

web3.eth.getNodeInfo().then(log) // 查看web3连接的节点信息
web3.eth.net.isListening().then(log)  //返回所连接节点的网络和检讨状态格式
web3.eth.net.getId().then(log) //获取 netWork id 网络号
web3.eth.getProtocolVersion().then(log) //获取以太坊协议版本

log(web3.providers) //web3可用的Providers
log(web3.currentProvider) //web3当前正在使用的Providers
log(web3.givenProvider) //查看浏览器环境设置的 web3 provider
web3.setProvider(provider2)
log(web3.setProvider) //设置 web3使用的 provider
```
- 批处理请求
将几个请求打包在一起提交提交、串联执行(一个个按顺序执行，速度不快，可保证代码执行顺序)  
BatchRequest实现批处理    
`new web3.BatchRequest()`   
`add(request)`：将请求对象添加到批调用中        
`execute()`:执行批处理请求