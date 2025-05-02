# Employee Benefits Platform Quick Start Guide

This guide will help you quickly get started with the Employee Benefits Token Platform.

## Installation

### Prerequisites

- Node.js v14+ and npm
- Git
- [Clarinet](https://github.com/hirosystems/clarinet) - Install with `npm install -g @hirosystems/clarinet`

### Setup Project

```bash
# Clone the repository
git clone https://github.com/midorichie/token-benefits-platform.git
cd token-benefits-platform

# Install dependencies
npm install

# Verify contracts
clarinet check
```

## Local Development

Start a local development environment:

```bash
clarinet console
```

This will give you an interactive console where you can test contract functions.

## Initial Configuration

### 1. Deploy Contracts

In a production environment, you would deploy contracts in this order:

```bash
# Deploy benefits token contract
clarinet deploy ./contracts/benefits-token.clar

# Deploy benefit rewards contract
clarinet deploy ./contracts/benefit-rewards.clar
```

In the Clarinet console, contracts are automatically deployed.

### 2. Link Contracts

Link the benefit rewards contract to the token contract:

```clarity
(contract-call? .benefit-rewards set-token-contract .benefits-token)
```

## Core Workflows

### For Administrators

#### Register a New Employee

```clarity
(contract-call? .benefits-token register-employee 'ST1PQHQKV0RJXZFY1DGX8MNSNYVE3VGZJSRTPGZGM "John Doe" "Engineering")
```

#### Add a New Benefit Type

```clarity
(contract-call? .benefits-token register-benefit-type "gym-membership" u300 "Monthly gym membership subsidy")
```

#### Add a New Task

```clarity
(contract-call? .benefit-rewards add-task "mentorship" "Participate in mentorship program" u75)
```

#### Verify Task Completion

```clarity
(contract-call? .benefit-rewards verify-task-completion 'ST1PQHQKV0RJXZFY1DGX8MNSNYVE3VGZJSRTPGZGM "mentorship" u1)
```

#### Process a Benefit Claim

```clarity
;; Approve a claim
(contract-call? .benefits-token process-claim 'ST1PQHQKV0RJXZFY1DGX8MNSNYVE3VGZJSRTPGZGM "health-insurance" u1 true)

;; Reject a claim
(contract-call? .benefits-token process-claim 'ST1PQHQKV0RJXZFY1DGX8MNSNYVE3VGZJSRTPGZGM "health-insurance" u2 false)
```

### For Employees

#### Check Token Balance

```clarity
(contract-call? .benefits-token get-balance tx-sender)
```

#### Transfer Tokens

```clarity
(contract-call? .benefits-token transfer-tokens 'ST2PQHQKV0RJXZFY1DGX8MNSNYVE3VGZJSRTPGZGM u100)
```

#### Claim a Benefit

```clarity
(contract-call? .benefits-token claim-benefit "health-insurance" u1)
```

#### Complete a Task

```clarity
(contract-call? .benefit-rewards complete-task "wellness-program" u1)
```

#### Claim a Reward

```clarity
(contract-call? .benefit-rewards claim-tier-reward u1 .benefits-token)
```

## Checking Status

### Check Employee Status

```clarity
(contract-call? .benefits-token get-employee-info tx-sender)
(contract-call? .benefits-token get-employee-status tx-sender)
```

### Check Reward Status

```clarity
(contract-call? .benefit-rewards get-employee-rewards tx-sender)
```

### Check Benefit Details

```clarity
(contract-call? .benefits-token get-benefit-type "health-insurance")
```

### Check Reward Tier Details

```clarity
(contract-call? .benefit-rewards get-reward-tier u1)
```

## Emergency Functionality

### Pause Contract

```clarity
(contract-call? .benefits-token toggle-pause)
(contract-call? .benefit-rewards toggle-pause)
```

### Check Pause Status

```clarity
(contract-call? .benefits-token is-paused)
(contract-call? .benefit-rewards is-paused)
```

## Testing the Platform

A complete test suite is available in the `/tests` directory. Run tests with:

```bash
clarinet test
```

## Troubleshooting

### Common Issues

1. **Authorization Errors (u100)**
   - Only the contract owner can call administrative functions
   - Use the correct principal that owns the contract

2. **Not Found Errors (u102)**
   - Ensure that benefit types, employees, or tasks exist before referencing them

3. **Already Exists Errors (u103)**
   - Unique IDs must be used for benefit types, tasks, and claim IDs

4. **Insufficient Balance (u101)**
   - Employee must have enough tokens to claim a benefit

### Debugging

Use the built-in Clarity Print function to debug:

```clarity
(print "Debug message")
(print { key: value })
```

## Next Steps

1. Customize benefit types and reward tiers for your organization
2. Integrate with your frontend application
3. Connect to your employee onboarding systems
4. Run a pilot program with a small group of employees

## Resources

- [Clarity Language Reference](https://docs.stacks.co/clarity/language)
- [Stacks Developer Documentation](https://docs.stacks.co/)
- [Clarinet Documentation](https://github.com/hirosystems/clarinet)
