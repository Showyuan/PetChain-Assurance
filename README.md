<h1 align="center">P2P Pet Insurance</h1>

# Overview

P2P Pet Insurance is a mutual insurance organization based on the concept of sharing economy, similar to a cooperative. Its aim is to provide pet owners with a transparent P2P insurance platform that requires no trust. Pets, implanted with microchips, are treated as non-fungible tokens (NFTs), allowing owners to choose their desired insurance coverage from various claim pools such as outpatient, hospitalization, and surgery.

The goal of P2P Pet Insurance is to offer pet owners more affordable premiums while providing a collective protection that involves sharing risks and rewards. It leverages blockchain technology and smart contracts to ensure a transparent and reliable claims process. Premium pricing is based on medical cost trends and the number of policyholders. Furthermore, governance token holders have the power to vote on claim amounts and can exclude policyholders with poor credit history.

It aims to provide pet owners with convenient, reliable, and flexible coverage, enabling them to better manage and care for the health needs of their beloved pets.

</br>

# Features

1. Diverse insurance options: Establish independent funding pools based on different claim categories (e.g., outpatient, hospitalization, surgery) to allow users to customize their insurance coverage according to their needs.
2. Fast and reliable claims process: Replace cumbersome underwriting procedures with integration of electronic medical records from veterinary clinics, ensuring a swift and dependable claims experience.
3. Transparent premium pricing: Determine fair and transparent premium pricing mechanisms based on medical cost trends and the number of policyholders, enabling users to have a clear understanding of the coverage provided by their premiums.
4. Empowerment of consumers: Governance token holders have the authority to determine claim amounts and participate in voting processes, allowing for the exclusion of policyholders with poor credit history. This ensures efficient allocation of insurance resources and places control of coverage in the hands of consumers.

</br>

# Framework

![image](https://github.com/Showyuan/P2P-Insurance/blob/main/infra.png)

**Insure Record** (Contract Name: Insurance)

* createInsurancePool
* purchaseInsurance
* cancelInsurance
* getInsurancePool
* getExpireTime

**Claim Record** (Contract Name: InsuranceClaim)

* fileClaim
* checkFraud
* checkExpirationAndRefund

**Reserve Fund** (Contract Name: ReserveFund)

* setClaimAddr
* depositFunds
* disburseClaim
* getReserveBalance

**Electronic Medical Record** (Contract Name: PetMedicalRecord)

* registerDoctor
* addMedicalRecord
* getMedicalRecordsCount
* getMedicalRecord

**Governance** (Contract Name: Governance)

* createProposal
* vote
* executeProposal

**Governance Token** (Contract Name: Token)

* is ERC20
  
**Pet NFTs** (Contract Name: PetNFT)

* is ERC721
* mintPet
* transfer
* getPetInfo
* burn
  
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
* Test1
```
forge test --mt test_ten_pets_mint -vv
```
* Test2
```
forge test --mt test_ten_pets_insure  -vv
```
* Test3
```
forge test --mt test_one_pet_claim  -vv
```
* Test4
```
forge test --mt test_reserveFund_correct  -vv
```
* Test5
```
forge test --mt test_claim_failed  -vv
```
**GovernanceTest**
* Test1
```
forge test --mt test_create_proposal_success  -vv
```
* Test2
```
forge test --mt test_create_proposal_failed  -vv
```

</br>

# Usage

![image](https://github.com/Showyuan/P2P-Insurance/blob/main/Insurance_Application_Process.png)

![image](https://github.com/Showyuan/P2P-Insurance/blob/main/Claim_Process.png)

![image](https://github.com/Showyuan/P2P-Insurance/blob/main/Governance_Process.png)

