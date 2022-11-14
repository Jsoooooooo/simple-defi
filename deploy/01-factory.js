const {developmentChains, BLOCK_CONFIRMATION} = require("../helper-hardhat-config");
const {network} = require("hardhat");
const {verify} = require("../utils/verify");

module.exports = async function({getNamedAccounts,deployments}){
    const { deployer } = await getNamedAccounts()
    const {log,deploy} = deployments

    const waitBlockConfirmations = developmentChains.includes(network.name)
        ? 1
        : BLOCK_CONFIRMATION

    const factory = await deploy("Factory",{
        from: deployer,
        log: true,
        args:[],
        waitConfirmations:waitBlockConfirmations,
    })
    // Verify the deployment
    if (!developmentChains.includes(network.name) && process.env.ETHERSCAN_API_KEY) {
        log("Verifying...")
        await verify(factory.address, arguments)
    }
}