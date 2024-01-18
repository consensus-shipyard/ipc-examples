// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.19;

import { AxelarExecutable } from '@axelar-gmp-sdk-solidity/contracts/executable/AxelarExecutable.sol';
import { IAxelarGateway } from '@axelar-gmp-sdk-solidity/contracts/interfaces/IAxelarGateway.sol';
import { IERC20 } from '@axelar-gmp-sdk-solidity/contracts/interfaces/IERC20.sol';
import { FundSubnetParams, TokenFundedGateway, convertAddress, FvmAddress } from "./Types.sol";

contract IpcTokenHandler is AxelarExecutable {
    TokenFundedGateway public ipcGateway;

    struct ConstructorParams {
        address axelarGateway;
        address ipcGateway;
    }

    constructor(ConstructorParams memory params) AxelarExecutable(params.axelarGateway) {
        ipcGateway = TokenFundedGateway(params.ipcGateway);
    }

    function _executeWithToken(
        string calldata,
        string calldata,
        bytes calldata payload,
        string calldata tokenSymbol,
        uint256 amount
    ) internal override {
        require(msg.sender == address(gateway), "sender must be the Axelar gateway");

        FundSubnetParams memory params = abi.decode(payload, (FundSubnetParams));
        FvmAddress memory recipient = convertAddress(params.beneficiary);

        address tokenAddress = gateway.tokenAddresses(tokenSymbol);
        IERC20(tokenAddress).transfer(address(ipcGateway), amount);

        ipcGateway.fundWithToken(params.subnet, recipient, amount);
    }
}