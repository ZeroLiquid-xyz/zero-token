// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.8.19;

import { Script } from "forge-std/Script.sol";
import { Mock } from "../src/Mock.sol";

contract Deployment is Script {
    Mock internal mock;

    address public constant liquidity = 0xbFb88f83eCc626ec8384eFEbb69B5bF605d03c26;
    address public constant foundation = 0x7fB8A16a467BbdFec3A8374720A688A3F1Fc0168;
    address public constant developmentMarketing = 0x9FadE1CD465d4376d24dC2a7397F3C89Ab1735CC;
    address public constant developmentVesting = 0x5f60Cc23857d6812e10028a3780e88Ee1b7A29f4;
    address public constant governanceVesting = 0xB9FeCAC77498776E6aFc3eE00e1dD3f5230bdE20;
    address public constant incentiveVesting = 0x7665deB06e92d87498A76526a75c9151FF9125EF;
    address public constant contributersVesting = 0x3de28bD25F1F80DDA240DD0ABDF9E9a7041864fD;

    address[] internal addresses = [
        liquidity,
        foundation,
        developmentMarketing,
        developmentVesting,
        governanceVesting,
        incentiveVesting,
        contributersVesting
    ];

    // 6000000 4000000 900000 29100000 42000000 15000000 3000000
    // 6000000000000000000000000 4000000000000000000000000 900000000000000000000000 29100000000000000000000000
    // 42000000000000000000000000 15000000000000000000000000 3000000000000000000000000

    uint256[] internal amounts = [
        6_000_000_000_000_000_000_000_000,
        4_000_000_000_000_000_000_000_000,
        900_000_000_000_000_000_000_000,
        29_100_000_000_000_000_000_000_000,
        42_000_000_000_000_000_000_000_000,
        15_000_000_000_000_000_000_000_000,
        3_000_000_000_000_000_000_000_000
    ];

    function run() external {
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
        vm.startBroadcast(deployerPrivateKey);

        mock = new Mock(addresses, amounts);

        vm.stopBroadcast();
    }
}
