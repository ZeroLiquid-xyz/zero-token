// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.8.19 <0.9.0;

import "forge-std/Test.sol";
import "./../src/Mock.sol";
import "./../src/test-helpers/SigUtils.sol";
import "./../src/test-helpers/Deposit.sol";

contract ERC20Test is Test {
    Mock internal token;
    SigUtils internal sigUtils;

    uint256 internal ownerPrivateKey;
    uint256 internal spenderPrivateKey;

    address internal owner;
    address internal spender;

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

    function setUp() public {
        token = new Mock(addresses, amounts);
        sigUtils = new SigUtils(token.getDomainSeparator());

        ownerPrivateKey = 0xA11CE;
        spenderPrivateKey = 0xB0B;

        // owner = vm.addr(ownerPrivateKey);
        // spender = vm.addr(spenderPrivateKey);

        owner = liquidity;
        spender = foundation;
    }

    // testing permit
    function test_Permit() public {
        SigUtils.Permit memory permit =
            SigUtils.Permit({owner: owner, spender: spender, value: 1e18, nonce: 0, deadline: 1 days});

        bytes32 digest = sigUtils.getTypedDataHash(permit);

        (uint8 v, bytes32 r, bytes32 s) = vm.sign(ownerPrivateKey, digest);

        token.permit(permit.owner, permit.spender, permit.value, permit.deadline, v, r, s);

        assertEq(token.allowance(owner, spender), 1e18);
        assertEq(token.nonces(owner), 1);
    }

    // testing failure for calls with an expired deadline, invalid signer, invalid nonce & signature replay
    function testRevert_ExpiredPermit() public {
        SigUtils.Permit memory permit =
            SigUtils.Permit({owner: owner, spender: spender, value: 1e18, nonce: token.nonces(owner), deadline: 1 days});

        bytes32 digest = sigUtils.getTypedDataHash(permit);

        (uint8 v, bytes32 r, bytes32 s) = vm.sign(ownerPrivateKey, digest);

        vm.warp(1 days + 1 seconds); // fast forward one second past the deadline

        vm.expectRevert("Mock:: AUTH_EXPIRED");
        token.permit(permit.owner, permit.spender, permit.value, permit.deadline, v, r, s);
    }

    function testRevert_InvalidSigner() public {
        SigUtils.Permit memory permit =
            SigUtils.Permit({owner: owner, spender: spender, value: 1e18, nonce: token.nonces(owner), deadline: 1 days});

        bytes32 digest = sigUtils.getTypedDataHash(permit);

        (uint8 v, bytes32 r, bytes32 s) = vm.sign(spenderPrivateKey, digest); // spender signs owner's approval

        vm.expectRevert("Mock:: INVALID_SIGNATURE");
        token.permit(permit.owner, permit.spender, permit.value, permit.deadline, v, r, s);
    }

    function testRevert_InvalidNonce() public {
        SigUtils.Permit memory permit = SigUtils.Permit({
            owner: owner,
            spender: spender,
            value: 1e18,
            nonce: 1, // owner nonce stored on-chain is 0
            deadline: 1 days
        });

        bytes32 digest = sigUtils.getTypedDataHash(permit);

        (uint8 v, bytes32 r, bytes32 s) = vm.sign(ownerPrivateKey, digest);

        vm.expectRevert("Mock:: INVALID_SIGNATURE");
        token.permit(permit.owner, permit.spender, permit.value, permit.deadline, v, r, s);
    }

    function testRevert_SignatureReplay() public {
        SigUtils.Permit memory permit =
            SigUtils.Permit({owner: owner, spender: spender, value: 1e18, nonce: 0, deadline: 1 days});

        bytes32 digest = sigUtils.getTypedDataHash(permit);

        (uint8 v, bytes32 r, bytes32 s) = vm.sign(ownerPrivateKey, digest);

        token.permit(permit.owner, permit.spender, permit.value, permit.deadline, v, r, s);

        vm.expectRevert("Mock:: INVALID_SIGNATURE");
        token.permit(permit.owner, permit.spender, permit.value, permit.deadline, v, r, s);
    }

    // testing transferfrom
    function test_TransferFromLimitedPermit() public {
        SigUtils.Permit memory permit =
            SigUtils.Permit({owner: owner, spender: spender, value: 1e18, nonce: 0, deadline: 1 days});

        bytes32 digest = sigUtils.getTypedDataHash(permit);

        (uint8 v, bytes32 r, bytes32 s) = vm.sign(ownerPrivateKey, digest);

        token.permit(permit.owner, permit.spender, permit.value, permit.deadline, v, r, s);

        vm.prank(spender);
        token.transferFrom(owner, spender, 1e18);

        assertEq(token.balanceOf(owner), 0);
        assertEq(token.balanceOf(spender), 1e18);
        assertEq(token.allowance(owner, spender), 0);
    }

    function test_TransferFromMaxPermit() public {
        SigUtils.Permit memory permit =
            SigUtils.Permit({owner: owner, spender: spender, value: type(uint256).max, nonce: 0, deadline: 1 days});

        bytes32 digest = sigUtils.getTypedDataHash(permit);

        (uint8 v, bytes32 r, bytes32 s) = vm.sign(ownerPrivateKey, digest);

        token.permit(permit.owner, permit.spender, permit.value, permit.deadline, v, r, s);

        vm.prank(spender);
        token.transferFrom(owner, spender, 1e18);

        assertEq(token.balanceOf(owner), 0);
        assertEq(token.balanceOf(spender), 1e18);
        assertEq(token.allowance(owner, spender), type(uint256).max);
    }

    // testing failure for calls with and invalid allowance & balance
    function testFail_InvalidAllowance() public {
        SigUtils.Permit memory permit = SigUtils.Permit({
            owner: owner,
            spender: spender,
            value: 5e17, // approve only 0.5 tokens
            nonce: 0,
            deadline: 1 days
        });

        bytes32 digest = sigUtils.getTypedDataHash(permit);

        (uint8 v, bytes32 r, bytes32 s) = vm.sign(ownerPrivateKey, digest);

        token.permit(permit.owner, permit.spender, permit.value, permit.deadline, v, r, s);

        vm.prank(spender);
        token.transferFrom(owner, spender, 1e18); // attempt to transfer 1 token
    }

    function testFail_InvalidBalance() public {
        SigUtils.Permit memory permit = SigUtils.Permit({
            owner: owner,
            spender: spender,
            value: 2e18, // approve 2 tokens
            nonce: 0,
            deadline: 1 days
        });

        bytes32 digest = sigUtils.getTypedDataHash(permit);

        (uint8 v, bytes32 r, bytes32 s) = vm.sign(ownerPrivateKey, digest);

        token.permit(permit.owner, permit.spender, permit.value, permit.deadline, v, r, s);

        vm.prank(spender);
        token.transferFrom(owner, spender, 2e18); // attempt to transfer 2 tokens (owner only owns 1)
    }
}

contract DepositTest is Test {
    Deposit internal deposit;
    Mock internal token;
    SigUtils internal sigUtils;

    uint256 internal ownerPrivateKey;
    address internal owner;

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

    function setUp() public {
        deposit = new Deposit();
        token = new Mock(addresses, amounts);
        sigUtils = new SigUtils(token.getDomainSeparator());

        // ownerPrivateKey = 0xA11CE;
        // owner = vm.addr(ownerPrivateKey);

        owner = liquidity;
    }

    function test_DepositWithLimitedPermit() public {
        SigUtils.Permit memory permit = SigUtils.Permit({
            owner: owner,
            spender: address(deposit),
            value: 1e18,
            nonce: token.nonces(owner),
            deadline: 1 days
        });

        bytes32 digest = sigUtils.getTypedDataHash(permit);

        (uint8 v, bytes32 r, bytes32 s) = vm.sign(ownerPrivateKey, digest);

        deposit.depositWithPermit(
            address(token), 1e18, permit.owner, permit.spender, permit.value, permit.deadline, v, r, s
        );

        assertEq(token.balanceOf(owner), 0);
        assertEq(token.balanceOf(address(deposit)), 1e18);

        assertEq(token.allowance(owner, address(deposit)), 0);
        assertEq(token.nonces(owner), 1);

        assertEq(deposit.userDeposits(owner, address(token)), 1e18);
    }

    function test_DepositWithMaxPermit() public {
        SigUtils.Permit memory permit = SigUtils.Permit({
            owner: owner,
            spender: address(deposit),
            value: type(uint256).max,
            nonce: token.nonces(owner),
            deadline: 1 days
        });

        bytes32 digest = sigUtils.getTypedDataHash(permit);

        (uint8 v, bytes32 r, bytes32 s) = vm.sign(ownerPrivateKey, digest);

        deposit.depositWithPermit(
            address(token), 1e18, permit.owner, permit.spender, permit.value, permit.deadline, v, r, s
        );

        assertEq(token.balanceOf(owner), 0);
        assertEq(token.balanceOf(address(deposit)), 1e18);

        assertEq(token.allowance(owner, address(deposit)), type(uint256).max);
        assertEq(token.nonces(owner), 1);

        assertEq(deposit.userDeposits(owner, address(token)), 1e18);
    }
}
