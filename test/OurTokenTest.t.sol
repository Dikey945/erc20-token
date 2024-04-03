// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import {Test} from "forge-std/Test.sol";
import {OurToken} from "../src/OurToken.sol";
import {DeployOurToken} from "../script/DeployOurToken.s.sol";

contract OurTokenTest is Test {
    OurToken public ourToken;
    DeployOurToken public deployer;

    address bob = makeAddr("bob");
    address alice = makeAddr("alice");

    uint256 public constant STARTING_BALANCE = 10 ether;

    function setUp() public {
        deployer = new DeployOurToken();
        ourToken = deployer.run();

        // vm.deal(address(deployer), 100 ether);
        vm.prank(address(msg.sender));

        ourToken.transfer(bob, STARTING_BALANCE);
    }

    function testBobBalance() public {
        assertEq(ourToken.balanceOf(bob), STARTING_BALANCE);
    }

    function testInitialSupply() public {
        assertEq(ourToken.totalSupply(), 1000 ether);
    }

    function testAllowances() public {
        uint256 initialAllowance = 1000;
        vm.prank(bob);
        ourToken.approve(alice, initialAllowance);

        uint256 transferAmount = 500;

        vm.prank(alice);
        ourToken.transferFrom(bob, alice, transferAmount);
        assertEq(ourToken.balanceOf(alice), transferAmount);
        assertEq(ourToken.balanceOf(bob), STARTING_BALANCE - transferAmount);
    }

    function testTransferToZeroAddressReverts() public {
        uint256 transferAmount = 1 ether;
        vm.prank(bob);
        bytes memory encoded = abi.encodeWithSignature(
            "ERC20InvalidReceiver(address)",
            address(0)
        );
        vm.expectRevert(encoded);

        ourToken.transfer(address(0), transferAmount);
    }

    function testTransferMoreThanOwnersBalance() public {
        uint256 transferAmount = STARTING_BALANCE + 1 ether; // More than Bob's balance
        vm.prank(bob);
        bytes memory expectedError = abi.encodeWithSignature(
            "ERC20InsufficientBalance(address,uint256,uint256)",
            bob,
            STARTING_BALANCE,
            transferAmount
        );

        vm.expectRevert(expectedError);
        ourToken.transfer(alice, transferAmount);
    }

    function testApprovalShouldBeSetToZeroBeforeChanging() public {
        uint256 initialAllowance = 50 ether;
        uint256 newAllowance = 100 ether;
        vm.prank(bob);
        ourToken.approve(alice, initialAllowance);
        vm.prank(bob);
        bytes memory encoded = abi.encodeWithSignature(
            "ERC20InvalidReceiver(address)",
            address(0)
        );
        // This would be a security check, ensuring users set allowance to zero before changing
        vm.expectRevert(encoded); // Adjust based on your token's behavior
        ourToken.approve(alice, newAllowance);
    }
}
