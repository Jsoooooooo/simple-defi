const {developmentChains} = require("../../helper-hardhat-config");
const {network, ethers, deployments} = require("hardhat");
const assert = require("assert");

const poolTokenName = "JCSwap",
    poolTokenSymbol = "JC",
    initialPoolTokenSupply = ethers.utils.parseEther('0')
const name= "JC_TOKEN",
      symbol = "JC",
     initialTokenSupply = ethers.utils.parseEther('1000000')

const initialReserve = ethers.utils.parseEther('0')

!developmentChains.includes(network.name) ? describe.skip
    : describe("Token Exchange",()=>{
        let owner, user, liquidityProvider
        let exchange
        beforeEach(async function (){
            const accounts = await ethers.getSigners()
            owner = accounts[0]
            user = accounts[1]
            liquidityProvider = accounts[2]
            await deployments.fixture(['all'])
            exchange = await ethers.getContract("Exchange")
        })
    })