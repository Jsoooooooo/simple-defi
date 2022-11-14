const {developmentChains} = require("../../helper-hardhat-config");
const {network, ethers, deployments} = require("hardhat");
const { expect } = require("chai")
const assert = require("assert");

const tokenName = 'JC_TOKEN'
const tokenSymbol = 'JC'
const initialSupply = 100000
!developmentChains.includes(network.name) ? describe.skip
    : describe("Token Test",()=>{
        let deployer,ourToken
        beforeEach(async function(){
            const accounts = await ethers.getSigners()
            deployer = accounts[0]
            await deployments.fixture(['all'])
            ourToken = await ethers.getContract("Token")
        })

        it("sets name and symbol",async ()=>{
            const name = (await ourToken.name()).toString()
            const symbol = (await ourToken.symbol()).toString()
            assert.equal(name,tokenName)
            assert.equal(symbol,tokenSymbol)
        })

        it("mints token to msg.sender",async ()=>{
            const supply = (await ourToken.totalSupply()).toString()
            assert.equal(supply,initialSupply)
        })
    })