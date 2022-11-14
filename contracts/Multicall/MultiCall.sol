pragma solidity ^0.8.0;

contract MultiCall {
    // to make sure gathering synchronized data from the same block
    // e.g query uniSwap,don't want to have price for one token from x block, and another from y block
    // therefore, multiCall aggregates all queries to different contracts in one call

    struct Call {
        address target; // address of the target contract
        bytes data; // parameters of the target, which is the address of function
    }

    function MultiCallFunc(Call[] memory calls) public returns(bytes[] memory returnData){
        returnData = new bytes[](calls.length);
        for (uint i = 0; i<calls.length; i++){
            // res is any return data called by the function
            (bool success,bytes memory res) = calls[i].target.call(calls[i].data);
            require(success,"call failed");
            returnData[i] = res;
        }
    }
    // abi.encodeWithSelector(this.func1.selector) = abi.encodeWithSignature(func1)

    function getEthBalance(address _address) public view returns (uint256 balance){
        balance = _address.balance;
    }

    function getBlockHash(uint256 blockNumber) public view returns (bytes32 blockHash) {
        blockHash = blockhash(blockNumber);
    }

    function getLastBlockHash() public view returns (bytes32 blockHash) {
        blockHash = blockhash(block.number - 1);
    }

    function getCurrentBlockTimestamp() public view returns (uint256 timestamp) {
        timestamp = block.timestamp;
    }
    function getCurrentBlockDifficulty() public view returns (uint256 difficulty) {
        difficulty = block.difficulty;
    }
    function getCurrentBlockGasLimit() public view returns (uint256 gasLimit) {
        gasLimit = block.gaslimit;
    }
    // block.coinbase returns the miner address who validates the transaction
    function getCurrentBlockCoinbase() public view returns (address coinbase) {
        coinbase = block.coinbase;
    }
}


