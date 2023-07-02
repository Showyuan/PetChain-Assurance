// SPDX-License-Identifier: MIT
pragma solidity 0.8.17;

interface IReserveFund {
    function depositFunds(string memory poolName) external payable;
    function disburseClaim(string memory poolName, uint256 amount, address claimAddress) external;
    function getReserveBalance(string memory poolName) external view returns (uint256);
    event FundsDeposited(string poolName, uint256 amount);
    event ClaimDisbursed(string poolName, uint256 amount);
}