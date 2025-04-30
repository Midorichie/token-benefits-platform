# Contract Technical Reference

This document provides detailed technical information about the functions and data structures in the Employee Benefits Token Platform contracts.

## Benefits Token Contract (`benefits-token.clar`)

### Data Structures

#### Fungible Token
```clarity
(define-fungible-token employee-token)
```
The main token used throughout the platform.

#### Maps

1. **benefit-status**
   ```clarity
   (define-map benefit-status
     { employee: principal }
     { 
       status: (string-ascii 16),
       last-update: uint,
       level: uint
     }
   )
   ```
   Tracks the benefit status of each employee.

2. **benefit-types**
   ```clarity
   (define-map benefit-types
     { benefit-id: (string-ascii 32) }
     {
       cost: uint,
       active: bool,
       description: (string-ascii 100)
     }
   )
   ```
   Registry of available benefit types.

3. **employees**
   ```clarity
   (define-map employees
     { address: principal }
     {
       name: (string-ascii 50),
       department: (string-ascii 50),
       active: bool,
       joined-at: uint
     }
   )
   ```
   Registry of all employees.

4. **benefit-claims**
   ```clarity
   (define-map benefit-claims
     { 
       employee: principal,
       benefit-id: (string-ascii 32),
       claim-id: uint
     }
     {
       timestamp: uint,
       status: (string-ascii 16),
       amount: uint,
       processed: bool
     }
   )
   ```
   Tracks all benefit claims.

### Public Functions

#### Administrative Functions

1. **set-contract-owner**
   ```clarity
   (define-public (set-contract-owner (new-owner principal)))
   ```
   Sets a new contract owner.

2. **toggle-pause**
   ```clarity
   (define-public (toggle-pause))
   ```
   Pauses or unpauses the contract.

#### Token Management

1. **mint-tokens**
   ```clarity
   (define-public (mint-tokens (recipient principal) (amount uint)))
   ```
   Mints new tokens for an employee.

2. **transfer-tokens**
   ```clarity
   (define-public (transfer-tokens (recipient principal) (amount uint)))
   ```
   Transfers tokens between accounts.

#### Employee Management

1. **register-employee**
   ```clarity
   (define-public (register-employee (employee principal) (name (string-ascii 50)) (department (string-ascii 50))))
   ```
   Registers a new employee and grants initial tokens.

2. **deactivate-employee**
   ```clarity
   (define-public (deactivate-employee (employee principal)))
   ```
   Deactivates an employee's benefits.

#### Benefit Management

1. **register-benefit-type**
   ```clarity
   (define-public (register-benefit-type (benefit-id (string-ascii 32)) (cost uint) (description (string-ascii 100))))
   ```
   Registers a new benefit type.

2. **update-benefit-type**
   ```clarity
   (define-public (update-benefit-type (benefit-id (string-ascii 32)) (cost uint) (active bool) (description (string-ascii 100))))
   ```
   Updates an existing benefit type.

3. **claim-benefit**
   ```clarity
   (define-public (claim-benefit (benefit-id (string-ascii 32)) (claim-id uint)))
   ```
   Allows an employee to claim a benefit.

4. **process-claim**
   ```clarity
   (define-public (process-claim (employee principal) (benefit-id (string-ascii 32)) (claim-id uint) (approve bool)))
   ```
   Processes a benefit claim (approve or reject).

### Read-Only Functions

1. **get-contract-owner**
   ```clarity
   (define-read-only (get-contract-owner))
   ```
   Returns the current contract owner.

2. **is-paused**
   ```clarity
   (define-read-only (is-paused))
   ```
   Returns the pause status of the contract.

3. **get-employee-status**
   ```clarity
   (define-read-only (get-employee-status (employee principal)))
   ```
   Returns the benefit status of an employee.

4. **get-employee-info**
   ```clarity
   (define-read-only (get-employee-info (employee principal)))
   ```
   Returns the information about an employee.

5. **get-benefit-type**
   ```clarity
   (define-read-only (get-benefit-type (benefit-id (string-ascii 32))))
   ```
   Returns information about a benefit type.

6. **get-balance**
   ```clarity
   (define-read-only (get-balance (account principal)))
   ```
   Returns the token balance of an account.

## Benefit Rewards Contract (`benefit-rewards.clar`)

### Trait Definition

```clarity
(define-trait ft-trait
  (
    (transfer-tokens (principal uint) (response bool uint))
    (get-balance (principal) (response uint uint))
    (mint-tokens (principal uint) (response bool uint))
  )
)
```
Trait that the token contract must implement to interact with the rewards system.

### Data Structures

#### Maps

1. **reward-tiers**
   ```clarity
   (define-map reward-tiers
     { tier-id: uint }
     {
       name: (string-ascii 32),
       threshold: uint,
       reward-amount: uint,
       cooldown-blocks: uint
     }
   )
   ```
   Defines reward tiers with thresholds and rewards.

2. **employee-rewards**
   ```clarity
   (define-map employee-rewards
     { employee: principal }
     {
       current-tier: uint,
       total-earned: uint,
       last-reward: uint,
       participation-points: uint
     }
   )
   ```
   Tracks reward status for each employee.

3. **tasks**
   ```clarity
   (define-map tasks
     { task-id: (string-ascii 32) }
     {
       description: (string-ascii 100),
       points: uint,
       active: bool
     }
   )
   ```
   Registry of tasks that employees can complete for points.

4. **completed-tasks**
   ```clarity
   (define-map completed-tasks
     { 
       employee: principal,
       task-id: (string-ascii 32),
       completion-id: uint
     }
     {
       timestamp: uint,
       verified: bool
     }
   )
   ```
   Tracks task completions by employees.

### Public Functions

#### Administrative Functions

1. **set-contract-owner**
   ```clarity
   (define-public (set-contract-owner (new-owner principal)))
   ```
   Sets a new contract owner.

2. **toggle-pause**
   ```clarity
   (define-public (toggle-pause))
   ```
   Pauses or unpauses the contract.

3. **set-token-contract**
   ```clarity
   (define-public (set-token-contract (new-contract principal)))
   ```
   Sets the address of the token contract.

#### Reward Management

1. **add-reward-tier**
   ```clarity
   (define-public (add-reward-tier (tier-id uint) (name (string-ascii 32)) (threshold uint) (reward-amount uint) (cooldown-blocks uint)))
   ```
   Adds a new reward tier.

2. **update-reward-tier**
   ```clarity
   (define-public (update-reward-tier (tier-id uint) (name (string-ascii 32)) (threshold uint) (reward-amount uint) (cooldown-blocks uint)))
   ```
   Updates an existing reward tier.

#### Task Management

1. **add-task**
   ```clarity
   (define-public (add-task (task-id (string-ascii 32)) (description (string-ascii 100)) (points uint)))
   ```
   Adds a new task.

2. **update-task**
   ```clarity
   (define-public (update-task (task-id (string-ascii 32)) (description (string-ascii 100)) (points uint) (active bool)))
   ```
   Updates an existing task.

#### Employee Interactions

1. **complete-task**
   ```clarity
   (define-public (complete-task (task-id (string-ascii 32)) (completion-id uint)))
   ```
   Records that an employee has completed a task.

2. **verify-task-completion**
   ```clarity
   (define-public (verify-task-completion (employee principal) (task-id (string-ascii 32)) (completion-id uint)))
   ```
   Verifies a task completion and awards points.

3. **claim-tier-reward**
   ```clarity
   (define-public (claim-tier-reward (tier-id uint) (token-contract-name <ft-trait>)))
   ```
   Allows an employee to claim a reward for reaching a tier threshold.

### Read-Only Functions

1. **get-contract-owner**
   ```clarity
   (define-read-only (get-contract-owner))
   ```
   Returns the current contract owner.

2. **get-token-contract**
   ```clarity
   (define-read-only (get-token-contract))
   ```
   Returns the address of the token contract.

3. **get-reward-tier**
   ```clarity
   (define-read-only (get-reward-tier (tier-id uint)))
   ```
   Returns information about a reward tier.

4. **get-employee-rewards**
   ```clarity
   (define-read-only (get-employee-rewards (employee principal)))
   ```
   Returns the reward status of an employee.

## Integration Patterns

### Process Flow: Employee Registration

1. Admin calls `register-employee` on the benefits token contract
2. System automatically:
   - Creates employee record
   - Sets initial benefit status
   - Mints initial tokens

### Process Flow: Claiming Benefits

1. Employee calls `claim-benefit` on the benefits token contract
2. System:
   - Verifies eligibility
   - Burns tokens
   - Creates a claim record
3. Admin calls `process-claim` to approve or reject
4. If rejected, tokens are automatically refunded

### Process Flow: Reward Earnings

1. Employee calls `complete-task` on the benefit rewards contract
2. Admin verifies completion with `verify-task-completion`
3. Employee earns participation points
4. When eligible, employee calls `claim-tier-reward`
5. System:
   - Verifies eligibility
   - Mints reward tokens
   - Updates reward status

## Implementation Notes

1. All functions include appropriate authorization checks
2. Status transitions are carefully controlled
3. Token operations use the standard ft-mint?, ft-transfer?, and ft-burn? functions
4. Error codes are standardized across both contracts
5. Input validation is applied to prevent invalid data

## Contract Deployment Order

For proper deployment:

1. Deploy `benefits-token.clar` first
2. Deploy `benefit-rewards.clar`
3. Call `set-token-contract` on the rewards contract with the address of the token contract
