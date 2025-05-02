;; Benefit Rewards - Companion contract for the token-benefits system
;; This contract enables a reward system for employees based on tenure and participation

;; Define token trait for the main token-benefits contract
(define-trait ft-trait
  (
    ;; Transfer tokens to a specified principal
    (transfer-tokens (principal uint) (response bool uint))
    ;; Get the token balance of the specified principal
    (get-balance (principal) (response uint uint))
    ;; Mint tokens for a recipient
    (mint-tokens (principal uint) (response bool uint))
  )
)

;; Constants
(define-constant ERR-NOT-AUTHORIZED u100)
(define-constant ERR-INSUFFICIENT-BALANCE u101)
(define-constant ERR-NOT-FOUND u102)
(define-constant ERR-ALREADY-EXISTS u103)
(define-constant ERR-COOLDOWN-ACTIVE u105)

;; Constants for improved safety
(define-constant ERR-INVALID-INPUT u200)
(define-constant ERR-PAUSED u201)

;; Data variables
(define-data-var contract-owner principal tx-sender)
(define-data-var token-contract principal 'SP000000000000000000002Q6VF78) ;; Will be updated after deployment
(define-data-var paused bool false)

;; Reward tiers
(define-map reward-tiers
  { tier-id: uint }
  {
    name: (string-ascii 32),
    threshold: uint,
    reward-amount: uint,
    cooldown-blocks: uint
  }
)

;; Employee reward status
(define-map employee-rewards
  { employee: principal }
  {
    current-tier: uint,
    total-earned: uint,
    last-reward: uint,
    participation-points: uint
  }
)

;; Tasks and achievements for earning participation points
(define-map tasks
  { task-id: (string-ascii 32) }
  {
    description: (string-ascii 100),
    points: uint,
    active: bool
  }
)

;; Track completed tasks
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

;; Administrative functions
(define-public (set-contract-owner (new-owner principal))
  (begin
    (asserts! (is-eq tx-sender (var-get contract-owner)) (err ERR-NOT-AUTHORIZED))
    ;; Validate new owner
    (asserts! (not (is-eq new-owner 'SP000000000000000000002Q6VF78)) (err ERR-INVALID-INPUT))
    (var-set contract-owner new-owner)
    (ok true)
  )
)

;; Contract pause functionality
(define-public (toggle-pause)
  (begin
    (asserts! (is-eq tx-sender (var-get contract-owner)) (err ERR-NOT-AUTHORIZED))
    (var-set paused (not (var-get paused)))
    (ok (var-get paused))
  )
)

(define-public (set-token-contract (new-contract principal))
  (begin
    (asserts! (is-eq tx-sender (var-get contract-owner)) (err ERR-NOT-AUTHORIZED))
    (var-set token-contract new-contract)
    (ok true)
  )
)

;; Helper functions
(define-read-only (get-contract-owner) 
  (var-get contract-owner)
)

(define-read-only (get-token-contract)
  (var-get token-contract)
)

(define-read-only (get-reward-tier (tier-id uint))
  (map-get? reward-tiers { tier-id: tier-id })
)

(define-read-only (get-employee-rewards (employee principal))
  (default-to 
    { 
      current-tier: u0, 
      total-earned: u0, 
      last-reward: u0,
      participation-points: u0 
    }
    (map-get? employee-rewards { employee: employee })
  )
)

;; Reward management
(define-public (add-reward-tier (tier-id uint) (name (string-ascii 32)) (threshold uint) (reward-amount uint) (cooldown-blocks uint))
  (begin
    (asserts! (is-eq tx-sender (var-get contract-owner)) (err ERR-NOT-AUTHORIZED))
    (asserts! (is-none (map-get? reward-tiers { tier-id: tier-id })) (err ERR-ALREADY-EXISTS))
    
    (map-set reward-tiers
      { tier-id: tier-id }
      {
        name: name,
        threshold: threshold,
        reward-amount: reward-amount,
        cooldown-blocks: cooldown-blocks
      }
    )
    (ok true)
  )
)

(define-public (update-reward-tier (tier-id uint) (name (string-ascii 32)) (threshold uint) (reward-amount uint) (cooldown-blocks uint))
  (begin
    (asserts! (is-eq tx-sender (var-get contract-owner)) (err ERR-NOT-AUTHORIZED))
    (asserts! (is-some (map-get? reward-tiers { tier-id: tier-id })) (err ERR-NOT-FOUND))
    
    (map-set reward-tiers
      { tier-id: tier-id }
      {
        name: name,
        threshold: threshold,
        reward-amount: reward-amount,
        cooldown-blocks: cooldown-blocks
      }
    )
    (ok true)
  )
)

;; Task management
(define-public (add-task (task-id (string-ascii 32)) (description (string-ascii 100)) (points uint))
  (begin
    (asserts! (is-eq tx-sender (var-get contract-owner)) (err ERR-NOT-AUTHORIZED))
    (asserts! (is-none (map-get? tasks { task-id: task-id })) (err ERR-ALREADY-EXISTS))
    
    (map-set tasks
      { task-id: task-id }
      {
        description: description,
        points: points,
        active: true
      }
    )
    (ok true)
  )
)

(define-public (update-task (task-id (string-ascii 32)) (description (string-ascii 100)) (points uint) (active bool))
  (begin
    (asserts! (is-eq tx-sender (var-get contract-owner)) (err ERR-NOT-AUTHORIZED))
    (asserts! (is-some (map-get? tasks { task-id: task-id })) (err ERR-NOT-FOUND))
    
    (map-set tasks
      { task-id: task-id }
      {
        description: description,
        points: points,
        active: active
      }
    )
    (ok true)
  )
)

;; Employee interactions
(define-public (complete-task (task-id (string-ascii 32)) (completion-id uint))
  (let (
    (task-info (unwrap! (map-get? tasks { task-id: task-id }) (err ERR-NOT-FOUND)))
    (active (get active task-info))
  )
    (asserts! active (err u106))
    (asserts! (is-none (map-get? completed-tasks 
      { 
        employee: tx-sender,
        task-id: task-id,
        completion-id: completion-id 
      })) (err ERR-ALREADY-EXISTS))
    
    ;; Record the task completion
    (map-set completed-tasks
      { 
        employee: tx-sender,
        task-id: task-id,
        completion-id: completion-id
      }
      {
        timestamp: block-height,
        verified: false
      }
    )
    
    (ok true)
  )
)

(define-public (verify-task-completion (employee principal) (task-id (string-ascii 32)) (completion-id uint))
  (let (
    (task-info (unwrap! (map-get? tasks { task-id: task-id }) (err ERR-NOT-FOUND)))
    (completion (unwrap! (map-get? completed-tasks 
      { 
        employee: employee,
        task-id: task-id,
        completion-id: completion-id 
      }) (err ERR-NOT-FOUND)))
    (points (get points task-info))
    (reward-status (get-employee-rewards employee))
    (current-points (get participation-points reward-status))
  )
    (asserts! (is-eq tx-sender (var-get contract-owner)) (err ERR-NOT-AUTHORIZED))
    (asserts! (not (get verified completion)) (err u107))
    
    ;; Mark the task as verified
    (map-set completed-tasks
      { 
        employee: employee,
        task-id: task-id,
        completion-id: completion-id
      }
      (merge completion { verified: true })
    )
    
    ;; Update participation points
    (map-set employee-rewards
      { employee: employee }
      (merge reward-status { 
        participation-points: (+ current-points points)
      })
    )
    
    (ok true)
  )
)

;; Claim rewards
(define-public (claim-tier-reward (tier-id uint) (token-contract-name <ft-trait>))
  (let (
    (tier-info (unwrap! (map-get? reward-tiers { tier-id: tier-id }) (err ERR-NOT-FOUND)))
    (reward-status (get-employee-rewards tx-sender))
    (threshold (get threshold tier-info))
    (current-points (get participation-points reward-status))
    (last-reward (get last-reward reward-status))
    (cooldown (get cooldown-blocks tier-info))
    (reward-amount (get reward-amount tier-info))
    (blocks-since-last (- block-height last-reward))
  )
    ;; Check eligibility
    (asserts! (>= current-points threshold) (err u109))
    (asserts! (or (is-eq last-reward u0) (>= blocks-since-last cooldown)) (err ERR-COOLDOWN-ACTIVE))
    
    ;; Call the token contract to mint rewards - now with a concrete contract name parameter
    (unwrap! (contract-call? token-contract-name mint-tokens tx-sender reward-amount) (err ERR-NOT-AUTHORIZED))
    
    ;; Update reward status
    (map-set employee-rewards
      { employee: tx-sender }
      (merge reward-status { 
        current-tier: tier-id,
        total-earned: (+ (get total-earned reward-status) reward-amount),
        last-reward: block-height
      })
    )
    
    (ok true)
  )
)

;; Initialize contract
(begin
  ;; Set up initial reward tiers
  (map-set reward-tiers
    { tier-id: u1 }
    {
      name: "Bronze",
      threshold: u100,
      reward-amount: u50,
      cooldown-blocks: u144  ;; ~1 day (assuming 10-minute blocks)
    }
  )
  
  (map-set reward-tiers
    { tier-id: u2 }
    {
      name: "Silver",
      threshold: u500,
      reward-amount: u200,
      cooldown-blocks: u144
    }
  )
  
  (map-set reward-tiers
    { tier-id: u3 }
    {
      name: "Gold",
      threshold: u1000,
      reward-amount: u500,
      cooldown-blocks: u144
    }
  )
  
  ;; Set up initial tasks
  (map-set tasks
    { task-id: "wellness-program" }
    {
      description: "Participate in company wellness program",
      points: u25,
      active: true
    }
  )
  
  (map-set tasks
    { task-id: "training-completion" }
    {
      description: "Complete professional development training",
      points: u50,
      active: true
    }
  )
)
