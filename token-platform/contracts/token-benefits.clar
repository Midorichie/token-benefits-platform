;; Minimal employee benefits token contract

(define-data-var contract-owner principal tx-sender)

;; Define the fungible token
(define-fungible-token employee-token)

;; Define a map to track benefit status
(define-map benefit-status
  { employee: principal }
  { status: (string-ascii 16) }
)

;; Helper functions
(define-read-only (contract-owner?) 
  (var-get contract-owner)
)

;; Administrative functions
(define-public (set-contract-owner (new-owner principal))
  (begin
    (asserts! (is-eq tx-sender (contract-owner?)) (err u100))
    (var-set contract-owner new-owner)
    (ok true)
  )
)
