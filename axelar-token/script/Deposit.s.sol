// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import { Script, console2 as console } from "forge-std/Script.sol";
import { IERC20 } from '@axelar-gmp-sdk-solidity/contracts/interfaces/IERC20.sol';

import "../src/IpcTokenSender.sol";
import "../src/Types.sol";

contract Deposit is Script {
    function setUp() public {}

    function run() public {
        string memory network = vm.envString("NETWORK");
        uint256 privateKey = vm.envUint(string.concat(network, "__PRIVATE_KEY"));

        string memory path = string.concat(vm.projectRoot(), "/out/addresses.json");
        require(vm.exists(path), "no addresses.json; run the deploy targets");

        string memory json = vm.readFile(path);
        address senderAddr = vm.parseJsonAddress(json, ".src.token_sender");

        console.log("token sender address: %s", senderAddr);

        uint256 amount = vm.envUint("AMOUNT");
        uint256 gasPayment = vm.envUint("GAS_PAYMENT");
        address beneficiary = vm.envAddress("BENEFICIARY");
        string memory symbol = vm.envString("SYMBOL");
        address[] memory route = new address[](1);
        route[0] = vm.envAddress("SUBNET_ADDR");
        SubnetID memory subnetId = SubnetID({root: uint64(vm.envUint("SUBNET_ROOT")), route: route});

        IERC20 token = IERC20(vm.envAddress(string.concat(network, "__ORIGIN_TOKEN_ADDRESS")));
        console.log("approving amount in origin token @ %s: %d", address(token), amount);
        token.approve(senderAddr, amount);

        vm.startBroadcast(privateKey);
        IpcTokenSender sender = IpcTokenSender(senderAddr);
        FundSubnetParams memory params = FundSubnetParams({
            subnet: subnetId,
            beneficiary: beneficiary,
            symbol: symbol,
            amount: amount
        });
        sender.fundSubnet{value: gasPayment}(params);
        vm.stopBroadcast();
    }
}
