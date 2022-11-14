// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
import "../error/ErrorReporter.sol";
contract HelpTransfer {

    function safeApprove(address token, address to, uint value) internal {
        // 0x095ea7b3 为 approve function对应的签名编码
        (bool success,bytes memory data ) = token.call(abi.encodeWithSelector(0x095ea7b3,to,value));
        if (!success && (data.length != 0 || !abi.decode(data, (bool)))){
            revert ErrorReporter.APPROVE_FAILED();
        }
    }

    function safeTransfer(address token,address to, uint value) internal {
        // bytes4(keccak256(bytes('transferFrom(address,address,uint256)'))); equals the following method
        // bytes memory data is the output by calling the function
        (bool success, bytes memory data) = token.call(abi.encodeWithSelector(0xa9059cbb,to,value));
        if (!success && (data.length != 0 || !abi.decode(data, (bool)))){
            revert ErrorReporter.TRANSFER_FAILED();
        }
    }

    function saferTransferFrom(address token, address from, address to, uint value) internal {
        (bool success, bytes memory data) = token.call(abi.encodeWithSelector(0x23b872dd,from,to,value));
        if (!success && (data.length != 0 || !abi.decode(data, (bool)))){
            revert ErrorReporter.TRANSFER_FROM_FAILED();
        }
    }

    function safeTransferETH(address to, uint amount) internal {
        (bool success,) = to.call{value:amount}("");
        if (!success){
            revert ErrorReporter.ETH_TRANSFER_FAILED();
        }
    }
}

//transfer(address,uint256)： 0xa9059cbb
//balanceOf(address)：0x70a08231
//decimals()：0x313ce567
//allowance(address,address)： 0xdd62ed3e
//symbol()：0x95d89b41
//totalSupply()：0x18160ddd
//name()：0x06fdde03
//approve(address,uint256)：0x095ea7b3
//transferFrom(address,address,uint256)： 0x23b872dd
