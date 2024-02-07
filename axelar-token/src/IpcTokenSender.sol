// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.19;

import { IAxelarGasService } from '@axelar-gmp-sdk-solidity/contracts/interfaces/IAxelarGasService.sol';
import { IAxelarGateway } from '@axelar-gmp-sdk-solidity/contracts/interfaces/IAxelarGateway.sol';
import { IERC20 } from '@axelar-gmp-sdk-solidity/contracts/interfaces/IERC20.sol';
import { FundSubnetParams } from "./Types.sol";

contract IpcTokenSender {
    IAxelarGateway public immutable axelarGateway;
    IAxelarGasService public immutable axelarGasService;
    string public destinationChain;
    string public tokenHandlerAddress;

    struct ConstructorParams {
        address axelarGateway;
        address axelarGasService;
        string destinationChain;
        string tokenHandlerAddress;
    }

    constructor(ConstructorParams memory params) {
        axelarGateway = IAxelarGateway(params.axelarGateway);
        axelarGasService = IAxelarGasService(params.axelarGasService);
        destinationChain = params.destinationChain;
        tokenHandlerAddress = params.tokenHandlerAddress;
    }

    function fundSubnet(FundSubnetParams calldata params) external payable {
        require(msg.value > 0, 'Gas payment is required');

        address tokenAddress = axelarGateway.tokenAddresses(params.symbol);
        require(tokenAddress != address(0), "could not resolve token address");

        IERC20(tokenAddress).transferFrom(msg.sender, address(this), params.amount);
        IERC20(tokenAddress).approve(address(axelarGateway), params.amount);
        bytes memory payload = abi.encode(params);
        axelarGasService.payNativeGasForContractCallWithToken{ value: msg.value }(
            address(this),
            destinationChain,
            tokenHandlerAddress,
            payload,
            params.symbol,
            params.amount,
            msg.sender
        );
        axelarGateway.callContractWithToken(destinationChain, tokenHandlerAddress, payload, params.symbol, params.amount);
    }
}