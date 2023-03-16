// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.8.19;

import { Script } from "forge-std/Script.sol";
import { Mock } from "../src/Mock.sol";

/// @dev See the Solidity Scripting tutorial: https://book.getfoundry.sh/tutorials/solidity-scripting
contract DeployFoo is Script {
    address internal deployer;
    Mock internal mock;

    address public constant FOUNDATION = 0xAfA13aa8F1b1d89454369c28b0CE1811961A7907;
    address[] internal addresses = [FOUNDATION];
    uint256[] internal amounts = [1e18];

    function setUp() public virtual {
        string memory mnemonic = vm.envString("MNEMONIC");
        (deployer,) = deriveRememberKey(mnemonic, 0);
    }

    function run() public {
        vm.startBroadcast(deployer);
        mock = new Mock(addresses, amounts);
        vm.stopBroadcast();
    }
}
