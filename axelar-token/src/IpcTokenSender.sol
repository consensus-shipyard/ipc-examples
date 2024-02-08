// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.19;

import { IInterchainTokenService } from "@axelar-network/interchain-token-service/interfaces/IInterchainTokenService.sol";
import { IERC20Named } from '@axelar-network/interchain-token-service/interfaces/IERC20Named.sol';
import { FundSubnetParams } from "./Types.sol";

contract IpcTokenSender {
    IInterchainTokenService public immutable axelarIts;
    string public destinationChain;
    address public tokenHandlerAddress;

    struct ConstructorParams {
        address axelarIts;
        string destinationChain;
        address tokenHandlerAddress;
    }

    constructor(ConstructorParams memory params) {
        axelarIts = IInterchainTokenService(params.axelarIts);
        destinationChain = params.destinationChain;
        tokenHandlerAddress = params.tokenHandlerAddress;
    }

    function fundSubnet(FundSubnetParams calldata params) external payable {
        require(msg.value > 0, 'Gas payment is required');

        address tokenAddress = axelarIts.validTokenAddress(params.tokenId);
        require(tokenAddress != address(0), "could not resolve token address");

        IERC20Named token = IERC20Named(tokenAddress);

        require(token.balanceOf(msg.sender) >= params.amount, "insufficient token balance");
        require(token.allowance(msg.sender, address(this)) >= params.amount, "insufficient token allowance");

        token.transferFrom(msg.sender, address(this), params.amount);
        token.approve(address(axelarIts), params.amount);
        bytes memory payload = abi.encode(params);
        axelarIts.callContractWithInterchainToken{ value: msg.value }(
            params.tokenId,
            destinationChain,
            abi.encodePacked(tokenHandlerAddress),
            params.amount,
            payload,
            msg.value
        );
    }
}