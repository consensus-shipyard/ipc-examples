// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.19;

import { InterchainTokenExecutable } from '@axelar-network/interchain-token-service/executable/InterchainTokenExecutable.sol';
import { IERC20Named } from '@axelar-network/interchain-token-service/interfaces/IERC20Named.sol';
import { FundSubnetParams, TokenFundedGateway, convertAddress, FvmAddress } from "./Types.sol";

contract IpcTokenHandler is InterchainTokenExecutable {
    TokenFundedGateway public ipcGateway;

    struct ConstructorParams {
        address axelarIts;
        address ipcGateway;
    }

    constructor(ConstructorParams memory params) InterchainTokenExecutable(params.axelarIts) {
        ipcGateway = TokenFundedGateway(params.ipcGateway);
    }

    function _executeWithInterchainToken(
        bytes32,
        string calldata,
        bytes calldata,
        bytes calldata data,
        bytes32,
        address tokenAddr,
        uint256 amount
    ) internal override {
        FundSubnetParams memory params = abi.decode(data, (FundSubnetParams));
        FvmAddress memory recipient = convertAddress(params.beneficiary);

        IERC20Named token = IERC20Named(tokenAddr);
        require(token.balanceOf(address(this)) >= amount, "insufficient balance");

        token.transfer(address(ipcGateway), amount);
        token.approve(address(ipcGateway), amount);
        ipcGateway.fundWithToken(params.subnet, recipient, amount);
    }
}