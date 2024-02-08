// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import { Script, console2 as console } from "forge-std/Script.sol";
import { IERC20Named } from '@axelar-network/interchain-token-service/interfaces/IERC20Named.sol';

import "../src/IpcTokenSender.sol";
import "../src/Types.sol";

contract Deposit is Script {
    function setUp() public {}

    function run() public {
        string memory network = vm.envString("ORIGIN_NETWORK");
        uint256 privateKey = vm.envUint(string.concat(network, "__PRIVATE_KEY"));

        string memory path = string.concat(vm.projectRoot(), "/out/addresses.json");
        require(vm.exists(path), "no addresses.json; run the deploy targets");

        string memory json = vm.readFile(path);
        address senderAddr = vm.parseJsonAddress(json, ".src.token_sender");

        console.log("token sender address: %s", senderAddr);

        bytes32 tokenId = vm.envBytes32("TOKEN_ID");
        uint256 amount = vm.envUint("AMOUNT");
        uint256 gasPayment = vm.envUint("GAS_PAYMENT");
        address beneficiary = vm.envAddress("BENEFICIARY");
        address[] memory route = new address[](1);
        route[0] = vm.envAddress("SUBNET_ADDR");
        SubnetID memory subnetId = SubnetID({root: uint64(vm.envUint("SUBNET_ROOT")), route: route});

        vm.startBroadcast(privateKey);
        IERC20Named token = IERC20Named(vm.envAddress(string.concat(network, "__ORIGIN_TOKEN_ADDRESS")));
        console.log("approving amount in origin token @ %s: %d", address(token), amount);
        token.approve(senderAddr, amount);

        IpcTokenSender sender = IpcTokenSender(senderAddr);
        FundSubnetParams memory params = FundSubnetParams({
            subnet: subnetId,
            beneficiary: beneficiary,
            tokenId: tokenId,
            amount: amount
        });
        sender.fundSubnet{value: gasPayment}(params);
        vm.stopBroadcast();
    }
}
