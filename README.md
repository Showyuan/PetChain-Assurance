<h1 align="center">P2P Pet Insurance</h1>

# Overview

P2P寵物保險是一種基於共享經濟概念的互惠型保險組織，類似於互助組織的原始保險模式。它的目標是讓寵物飼主可以在無需信任的情況下，透過一個透明的平台進行保險投保。在這個平台上，寵物被視為非同質化代幣（NFT），並且每個飼主可以根據自己的需求和偏好自由選擇投保組合，包括門診理賠池、住院理賠池、手術理賠池等。

這種P2P寵物保險的目標是讓飼主能夠享受更便宜的保費，同時提供共享風險和分享收益的群體保障。它利用區塊鏈技術和智能合約來實現透明、可靠的理賠流程，並且保費定價基於醫療費用行情和投保人數規模。此外，治理Token持有者還可以參與投票，決定理賠金額，並有權排除那些信用不佳的保戶。

為寵物飼主提供方便、可靠且具有彈性的保障，並讓他們更好地管理和照顧自己的寵物的健康需求。

</br>

# Features

1. 多元的投保選項：根據不同的理賠項目（例如門診、住院、手術等），建立獨立的保障資金池，讓用戶可以根據自身需求進行投保。
2. 快速可靠的理賠流程：結合獸醫診所的電子病歷，取代繁瑣的核保流程，使理賠更加迅速和可靠。
3. 透明的保費定價：根據醫療費用行情和投保人數規模，確定公平透明的保費定價機制，讓用戶清楚了解保費所涵蓋的保障範圍。
4. 保障掌握在消費者手中：治理Token持有者有權決定各項理賠金額，同時也可以進行投票，排除那些信用不佳的保戶，確保保障資源得到有效分配

</br>

# Framework

![image](https://github.com/Showyuan/P2P-Insurance/blob/main/infra.png)

**Insure Record** (Contract Name: Insurance)

* createInsurancePool 新增保險項目
* purchaseInsurance 購買保險
* cancelInsurance 拒保/退保
* getInsurancePool 取得保險內容
* getExpireTime 取得保險到期日

**Claim Record** (Contract Name: InsuranceClaim)

* fileClaim 申請理賠
* checkFraud 確認是否可以直接理賠
* checkExpirationAndRefund 確認保險是否到期，到期且沒有理賠紀錄則退還部分保費

**Reserve Fund** (Contract Name: ReserveFund)

* setClaimAddr 設置理賠合約地址
* depositFunds 儲存保費至對應池
* disburseClaim 執行理賠
* getReserveBalance 取得pool餘額

**Electronic Medical Record** (Contract Name: PetMedicalRecord)

* registerDoctor 新醫生註冊
* addMedicalRecord 新增醫療紀錄
* getMedicalRecordsCount 取得醫療紀錄筆數
* getMedicalRecord 取得醫療紀錄

**Governance** (Contract Name: Governance)

* createProposal 新增提案
* vote 投票
* executeProposal 執行提案

**Governance Token** (Contract Name: Token)

* is ERC20
  
**Pet NFTs** (Contract Name: PetNFT)

* is ERC721
* mintPet 新增一隻寵物
* transfer 移轉飼主
* getPetInfo 取得寵物資訊
* burn 銷毀寵物資訊
  
</br>

# Development

**Compile**
```
forge build
```
**Install Dependencies**
```
forge install [package name] --no-commit
```
**Remappings**
```
forge remappings > remappings.txt
```

</br>

# Testing

**InsuranceTest**
* Test1: 10隻寵物註冊 NFT
```
forge test --mt test_ten_pets_mint -vv
```
* Test2: 10隻寵物投保
```
forge test --mt test_ten_pets_insure  -vv
```
* Test3: 1隻寵物理賠
```
forge test --mt test_one_pet_claim  -vv
```
* Test4: 確認資金池餘額是否正確減少
```
forge test --mt test_reserveFund_correct  -vv
```
* Test5: 醫療紀錄和實際投保項目不同，理賠失敗
```
forge test --mt test_claim_failed  -vv
```
**GovernanceTest**
* Test1: 測試提案，並且通過後成功執行
```
forge test --mt test_create_proposal_success  -vv
```
* Test2: 測試提案，並且投票失敗
```
forge test --mt test_create_proposal_failed  -vv
```

</br>

# Usage

![image](https://github.com/Showyuan/P2P-Insurance/blob/main/Insurance_Application_Process.png)

![image](https://github.com/Showyuan/P2P-Insurance/blob/main/Claim_Process.png)

![image](https://github.com/Showyuan/P2P-Insurance/blob/main/Governance_Process.png)

