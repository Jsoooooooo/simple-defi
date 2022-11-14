const {developmentChains, BLOCK_CONFIRMATION} = require("../helper-hardhat-config");
const {network} = require("hardhat");
const {verify} = require("../utils/verify");

module.exports = async function({getNamedAccounts,deployments}){
    const { deployer } = await getNamedAccounts()
    const { log,deploy } = deployments

    const waitBlockConfirmations = developmentChains.includes(network.name)
        ? 1
        : BLOCK_CONFIRMATION

    let name= "JC_TOKEN"
    let symbol = "JC"
    let initialSupply = 100000
    let args= [name,symbol,initialSupply]

    const token = await deploy("Token",{
        from: deployer,
        args: args,
        log: true,
        blockConfirmations: waitBlockConfirmations
    })
    // Verify the deployment
    if (!developmentChains.includes(network.name) && process.env.ETHERSCAN_API_KEY) {
        log("Verifying...")
        await verify(token.address, arguments)
    }
}

module.exports.tags = ['all','token']