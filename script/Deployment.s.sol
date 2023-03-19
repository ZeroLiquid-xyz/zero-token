// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.8.19;

import { Script } from "forge-std/Script.sol";
import { Zero } from "../src/Zero.sol";

contract Deployment is Script {
    Zero internal zero;

    address public constant liquidity = 0x8DF0EB73f815C500C49058d96F71E76aaDf548F5;
    address public constant developmentMarketing = 0x6fF9474923510C0D41d246b9f39259cbf4E5ebA3;
    address public constant developmentVesting = 0x2ae5e92D24edcB56E780F90C7bF69F014eB0B1aA;
    address public constant governanceVesting = 0x5b4Ec57143B57aa4716Da35b79F40CA65E980B8B;
    address public constant incentiveVesting = 0xa78605F5390a206E09C2B91b04e6D4fBaBa0A985;
    address public constant contributersVesting = 0xE172ae4E0861B9591a37600cFB9A67dD2FaAf835;

    address[] internal addresses =
        [liquidity, developmentMarketing, developmentVesting, governanceVesting, incentiveVesting, contributersVesting];

    // 6000000 900000 29100000 42000000 19000000 3000000
    // 6000000000000000000000000 900000000000000000000000 29100000000000000000000000
    // 42000000000000000000000000 19000000000000000000000000 3000000000000000000000000

    uint256[] internal amounts = [
        6_000_000_000_000_000_000_000_000,
        900_000_000_000_000_000_000_000,
        29_100_000_000_000_000_000_000_000,
        42_000_000_000_000_000_000_000_000,
        19_000_000_000_000_000_000_000_000,
        3_000_000_000_000_000_000_000_000
    ];

    function run() external {
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
        vm.startBroadcast(deployerPrivateKey);

        zero = new Zero(addresses, amounts);

        vm.stopBroadcast();
    }
}
