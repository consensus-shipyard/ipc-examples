// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import { Script, console2 as console } from "forge-std/Script.sol";

import  "../src/IpcTokenSender.sol";

contract DeployScript is Script {
    IpcTokenSender public sender;

    function setUp() public {}

    function run() public {
        string memory network = vm.envString("NETWORK");
        uint256 privateKey = vm.envUint(string.concat(network, "__PRIVATE_KEY"));

        console.log("loading handler address...");

        string memory path = string.concat(vm.projectRoot(), "/out/addresses.json");
        require(vm.exists(path), "no addresses.json; please run DeployTokenHandler on the destination chain");

        string memory json = vm.readFile(path);
        string memory handlerAddr = vm.parseJsonString(json, ".dest.token_handler");
        console.log("handler address: %s", handlerAddr);

        console.log("deploying token sender to %s...", network);

        // Deploy the sender on Mumbai.
        vm.startBroadcast(privateKey);
        IpcTokenSender.ConstructorParams memory params = IpcTokenSender.ConstructorParams({
            axelarGateway: vm.envAddress(string.concat(network, "__AXELAR_GATEWAY_ADDRESS")),
            axelarGasService: vm.envAddress(string.concat(network, "__AXELAR_GASSERVICE_ADDRESS")),
            destinationChain: vm.envString(string.concat(network, "__AXELAR_CHAIN_NAME")),
            tokenHandlerAddress: handlerAddr
        });
        sender = new IpcTokenSender(params);
        vm.stopBroadcast();

        console.log("token sender deployed on %s: %s", network, address(sender));

        string memory key = "out";
        vm.serializeString(key, "network", network);
        json = vm.serializeAddress(key, "token_sender", address(sender));
        vm.writeJson(json, path, ".src");

    }
}
