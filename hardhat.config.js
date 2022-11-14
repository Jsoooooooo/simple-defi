require("@nomicfoundation/hardhat-chai-matchers")
require("@nomiclabs/hardhat-ethers")
require('dotenv').config() // 引入环境变量
require("@nomiclabs/hardhat-etherscan"); //与etherscan连接
require('hardhat-gas-reporter') //npm install hardhat-gas-reporter，查看gas费
require('hardhat-deploy') // 主要用来deploy contract //npm install -D hardhat-deploy 以及npm install --save-dev  @nomiclabs/hardhat-ethers@npm:hardhat-deploy-ethers ethers
require ('hardhat-gas-reporter')
/**
 * @type import('hardhat/config').HardhatUserConfig
 */
// process.env使用前需下载 dotenv npm install --dev dotenv
const RINKEBY_URL = process.env.RINKEBY_RPC_URL || ''
const PRIVATE_KEY = process.env.RINKEBY_PRIVATE_KEY  || ''// 从metamask导出私钥
const ETHERSCAN_API_KEY = process.env.ETHERSCAN_API_KEY || ''
const CoinBaseMarket_API_KEY = process.env.COINMARKETCAP_API_KEY || ''
const RINKEBY_GEORLI_URL = process.env.RINEKBY_GEORLI_RPC || ''
const RINKEBY_GEORLI_PRIVATE = process.env.RINEKBY_GEORLI_PRIVATE_KEY || ''

module.exports = {
  solidity: {
    compilers:[
      {version:"0.8.4"},
      {version:"0.8.0"},
    ]
  },
  defaultNetwork:'hardhat',
  networks: {
    hardhat:{
      chainId: 31337, // 本地的编号
      blockConfirmations:1,
    },
    rinkeby:{
      url:RINKEBY_URL,
      account:[PRIVATE_KEY],
      chainId:4,
      blockConfirmations:4,
    },
    goerli:{
      url : RINKEBY_GEORLI_URL,
      accounts: [`0x${RINKEBY_GEORLI_PRIVATE}`],
      chainId:5,
      blockConfirmations:2,
    }
  },
  etherscan:{
    apiKey: ETHERSCAN_API_KEY || '',
  },
  // 在本地启动一个可以本地的以太坊测试网
  localhost:{
    url:" http://127.0.0.1:8545/",
    chanId: 31377,
  },
  // 设置gasReporter,可以模拟部署合约花费的gas费
  gasReporter: {
    enabled : true,
    outputFile:'gas-reporter.txt', // 在gitignore中添加
    noColors: true,
    currency: 'USD',
    coinMarketCap: CoinBaseMarket_API_KEY,
    token:'MARIC',  // 这里设置部署在哪个区块链上，比如Ethereum，Polygen等
  },
  //设置默认的account，deploy时候会用
  namedAccounts: {
    deployer: {
      default: 0, // here this will by default take the first account as deployer
      1: 0, // similarly on mainnet it will take the first account as deployer. Note though that depending on how hardhat network are configured, the account 0 on one network can be different than on another
    },
    player: {
      default: 1,
    },
  },
};
// 通过rinkeby获取API和key，连接rinkeby测试网
// 通过etherscan API verify contract
// npm install dotenv,配置.env的环境
// npm hardhat-gas-reporter，测试合约部署所需要的gas费，需要再gitignore里面添加files
// 通过coinMarketCap 设置coinMarketCap的货币单位 网址：coinMarketCap/api
// 通过 solidity-coverage 查看哪些代码被测试
// 通过 hardhat-deploye 解决deploy contract较多时