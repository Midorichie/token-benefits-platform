;; Enhanced employee benefits token contract

;; Constants
(define-constant ERR-NOT-AUTHORIZED u100)
(define-constant ERR-INSUFFICIENT-BALANCE u101)
(define-constant ERR-NOT-FOUND u102)
(define-constant ERR-ALREADY-EXISTS u103)
(define-constant ERR-INVALID-STATUS u104)

;; Data variables
(define-data-var contract-owner principal tx-sender)
(define-data-var paused bool false)

;; Define the fungible token with metadata
(define-fungible-token employee-token)

;; Define maps for benefit tracking
(define-map benefit-status
  { employee: principal }
  { 
    status: (string-ascii 16),
    last-update: uint,
    level: uint
  }
)

;; Benefits registry for different types
(define-map benefit-types
  { benefit-id: (string-ascii 32) }
  {
    cost: uint,
    active: bool,
    description: (string-ascii 100)
  }
)

;; Employee registry
(define-map employees
  { address: principal }
  {
    name: (string-ascii 50),
    department: (string-ascii 50),
    active: bool,
    joined-at: uint
  }
)

;; Benefit claims tracking
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

;; Administrative functions
(define-public (set-contract-owner (new-owner principal))
  (begin
    (asserts! (is-eq tx-sender (var-get contract-owner)) (err ERR-NOT-AUTHORIZED))
    ;; Validation: Don't allow setting to null/zero address
    (asserts! (not (is-eq new-owner 'SP000000000000000000002Q6VF78)) (err u110))
    (var-set contract-owner new-owner)
    (ok true)
  )
)

;; Emergency pause function
(define-public (toggle-pause)
  (begin
    (asserts! (is-eq tx-sender (var-get contract-owner)) (err ERR-NOT-AUTHORIZED))
    (var-set paused (not (var-get paused)))
    (ok (var-get paused))
  )
)

;; Helper functions
(define-read-only (get-contract-owner) 
  (var-get contract-owner)
)

(define-read-only (is-paused)
  (var-get paused)
)

(define-read-only (get-employee-status (employee principal))
  (map-get? benefit-status { employee: employee })
)

(define-read-only (get-employee-info (employee principal))
  (map-get? employees { address: employee })
)

(define-read-only (get-benefit-type (benefit-id (string-ascii 32)))
  (map-get? benefit-types { benefit-id: benefit-id })
)

;; Token management functions
(define-public (mint-tokens (recipient principal) (amount uint))
  (begin
    (asserts! (is-eq tx-sender (var-get contract-owner)) (err ERR-NOT-AUTHORIZED))
    (asserts! (not (var-get paused)) (err u105))
    ;; Validate inputs
    (asserts! (> amount u0) (err u111))
    (asserts! (not (is-eq recipient 'SP000000000000000000002Q6VF78)) (err u112))
    ;; Check if recipient is registered
    (asserts! (is-some (map-get? employees { address: recipient })) (err ERR-NOT-FOUND))
    (ft-mint? employee-token amount recipient)
  )
)

(define-public (transfer-tokens (recipient principal) (amount uint))
  (begin
    (asserts! (not (var-get paused)) (err u105))
    (ft-transfer? employee-token amount tx-sender recipient)
  )
)

(define-read-only (get-balance (account principal))
  (ft-get-balance employee-token account)
)

;; Benefit management functions
(define-public (register-employee (employee principal) (name (string-ascii 50)) (department (string-ascii 50)))
  (begin
    (asserts! (is-eq tx-sender (var-get contract-owner)) (err ERR-NOT-AUTHORIZED))
    (asserts! (not (var-get paused)) (err u105))
    ;; Validate inputs
    (asserts! (not (is-eq employee 'SP000000000000000000002Q6VF78)) (err u112))
    (asserts! (> (len name) u0) (err u113))
    (asserts! (> (len department) u0) (err u114))
    (asserts! (is-none (map-get? employees { address: employee })) (err ERR-ALREADY-EXISTS))
    
    ;; Set employee data safely
    (map-set employees
      { address: employee }
      {
        name: name,
        department: department,
        active: true,
        joined-at: block-height
      }
    )
    
    ;; Set initial benefit status
    (map-set benefit-status
      { employee: employee }
      {
        status: "ACTIVE",
        last-update: block-height,
        level: u1
      }
    )
    
    ;; Grant initial tokens - handle as separate operation
    (unwrap! (as-contract (ft-mint? employee-token u1000 employee)) (err ERR-INSUFFICIENT-BALANCE))
    (ok true)
  )
)

(define-public (deactivate-employee (employee principal))
  (begin
    (asserts! (is-eq tx-sender (var-get contract-owner)) (err ERR-NOT-AUTHORIZED))
    (asserts! (not (var-get paused)) (err u105))
    (match (map-get? employees { address: employee })
      employee-data (begin
        (map-set employees
          { address: employee }
          (merge employee-data { active: false })
        )
        (map-set benefit-status
          { employee: employee }
          {
            status: "INACTIVE",
            last-update: block-height,
            level: u0
          }
        )
        (ok true)
      )
      (err ERR-NOT-FOUND)
    )
  )
)

(define-public (register-benefit-type 
  (benefit-id (string-ascii 32)) 
  (cost uint) 
  (description (string-ascii 100))
)
  (begin
    (asserts! (is-eq tx-sender (var-get contract-owner)) (err ERR-NOT-AUTHORIZED))
    (asserts! (not (var-get paused)) (err u105))
    ;; Validate inputs
    (asserts! (> (len benefit-id) u0) (err u115))
    (asserts! (> cost u0) (err u116))
    (asserts! (> (len description) u0) (err u117))
    (asserts! (is-none (map-get? benefit-types { benefit-id: benefit-id })) (err ERR-ALREADY-EXISTS))
    
    ;; Set benefit type data safely
    (map-set benefit-types
      { benefit-id: benefit-id }
      {
        cost: cost,
        active: true,
        description: description
      }
    )
    (ok true)
  )
)

(define-public (update-benefit-type 
  (benefit-id (string-ascii 32)) 
  (cost uint) 
  (active bool)
  (description (string-ascii 100))
)
  (begin
    (asserts! (is-eq tx-sender (var-get contract-owner)) (err ERR-NOT-AUTHORIZED))
    (asserts! (not (var-get paused)) (err u105))
    (asserts! (is-some (map-get? benefit-types { benefit-id: benefit-id })) (err ERR-NOT-FOUND))
    
    (map-set benefit-types
      { benefit-id: benefit-id }
      {
        cost: cost,
        active: active,
        description: description
      }
    )
    (ok true)
  )
)

;; Employee benefit claiming
(define-public (claim-benefit 
  (benefit-id (string-ascii 32))
  (claim-id uint)
)
  (let (
    ;; Validate benefit ID exists and is valid
    (benefit-info (unwrap! (map-get? benefit-types { benefit-id: benefit-id }) (err ERR-NOT-FOUND)))
    ;; Validate employee exists
    (employee-info (unwrap! (map-get? employees { address: tx-sender }) (err ERR-NOT-FOUND)))
    (cost (get cost benefit-info))
    (is-active (get active benefit-info))
    (employee-active (get active employee-info))
    (balance (ft-get-balance employee-token tx-sender))
  )
    ;; Contract state and eligibility checks
    (asserts! (not (var-get paused)) (err u105))
    (asserts! is-active (err u106))
    (asserts! employee-active (err u107))
    (asserts! (>= balance cost) (err ERR-INSUFFICIENT-BALANCE))
    
    ;; Check if claim already exists - validate against duplicate claim IDs
    (asserts! (is-none (map-get? benefit-claims 
      { 
        employee: tx-sender,
        benefit-id: benefit-id,
        claim-id: claim-id 
      })) (err ERR-ALREADY-EXISTS))
    
    ;; Create claim
    (map-set benefit-claims
      { 
        employee: tx-sender,
        benefit-id: benefit-id,
        claim-id: claim-id
      }
      {
        timestamp: block-height,
        status: "PENDING",
        amount: cost,
        processed: false
      }
    )
    
    ;; Burn tokens for the claim
    (unwrap! (ft-burn? employee-token cost tx-sender) (err ERR-INSUFFICIENT-BALANCE))
    
    (ok true)
  )
)

(define-public (process-claim 
  (employee principal)
  (benefit-id (string-ascii 32))
  (claim-id uint)
  (approve bool)
)
  (let (
    ;; Validate employee
    (is-valid-employee (is-some (map-get? employees { address: employee })))
    ;; Validate benefit type
    (is-valid-benefit (is-some (map-get? benefit-types { benefit-id: benefit-id })))
    ;; Get claim
    (claim (unwrap! (map-get? benefit-claims 
      { 
        employee: employee,
        benefit-id: benefit-id,
        claim-id: claim-id 
      }) (err ERR-NOT-FOUND)))
    (new-status (if approve "APPROVED" "REJECTED"))
  )
    ;; Authorization and state checks
    (asserts! (is-eq tx-sender (var-get contract-owner)) (err ERR-NOT-AUTHORIZED))
    (asserts! (not (var-get paused)) (err u105))
    (asserts! is-valid-employee (err ERR-NOT-FOUND))
    (asserts! is-valid-benefit (err ERR-NOT-FOUND))
    (asserts! (not (get processed claim)) (err u108))
    
    ;; Update claim status
    (map-set benefit-claims
      { 
        employee: employee,
        benefit-id: benefit-id,
        claim-id: claim-id
      }
      (merge claim { 
        status: new-status,
        processed: true
      })
    )
    
    ;; If rejected, refund tokens as contract (not as sender)
    (if (not approve)
      (as-contract (ft-mint? employee-token (get amount claim) employee))
      (ok true)
    )
  )
)

;; Initialize contract
(begin
  ;; Register initial benefit types
  (map-set benefit-types
    { benefit-id: "health-insurance" }
    {
      cost: u500,
      active: true,
      description: "Standard health insurance coverage"
    }
  )
  
  (map-set benefit-types
    { benefit-id: "retirement-plan" }
    {
      cost: u300,
      active: true,
      description: "Retirement savings plan contribution"
    }
  )
)
