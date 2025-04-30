(define-fungible-token employee-token)

(define-public (get-balance (principal <principal>))
  (ok (ft-get-balance? employee-token principal)))
