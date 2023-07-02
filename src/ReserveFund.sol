// SPDX-License-Identifier: MIT
pragma solidity 0.8.17;

contract ReserveFund {
    mapping(string => uint256) private reserveBalance;

    event FundsDeposited(string poolName, uint256 amount);
    event ClaimDisbursed(string poolName, uint256 amount);

    /**
        depositFunds 儲存保費
        poolName: pool 名稱
     */
    function depositFunds(string memory poolName) external payable {
        reserveBalance[poolName] += msg.value;
        emit FundsDeposited(poolName, msg.value);
    }

    /**
        disburseClaim 執行理賠
        poolName: pool 名稱
        amount: 金額
        claimAddress: 理賠金收款地址
     */
    function disburseClaim(string memory poolName, uint256 amount, address claimAddress) external {
        require(reserveBalance[poolName] >= amount, "Insufficient funds in the reserve");

        reserveBalance[poolName] -= amount;
        emit ClaimDisbursed(poolName, amount);

        // Transfer the claim amount to the claimant
        payable(claimAddress).transfer(amount);
    }

    /**
        getReserveBalance 取得pool餘額
        poolName: pool 名稱
     */
    function getReserveBalance(string memory poolName) external view returns (uint256) {
        return reserveBalance[poolName];
    }
}