;; contracts/wallet-core.clar
;; Main wallet contract implementing core functionality
 
(define-data-var wallet-owner principal tx-sender)
(define-map guardians principal bool)
(define-data-var required-confirmations uint u2)
(define-map recovery-requests
    { initiator: principal }
    { timestamp: uint,
      confirmations: (list 10 principal) })
 
;; Initialize wallet with owner and guardians
(define-public (initialize-wallet (guardian-list (list 3 principal)))
    (begin
        (asserts! (is-eq tx-sender (var-get wallet-owner)) (err u1))
        (map add-guardian guardian-list)
        (ok true)))
 
;; Add a single guardian
(define-private (add-guardian (guardian principal))
    (map-set guardians guardian true))
 
;; Helper function to create initial confirmations list
(define-private (create-initial-confirmations)
    (as-max-len? (list tx-sender) u10))
 
;; Initiate recovery process
(define-public (initiate-recovery)
    (let
        (
            (initial-confirmations (unwrap! (create-initial-confirmations) (err u8)))
            (request {
                timestamp: block-height,
                confirmations: initial-confirmations
            })
        )
        (begin
            (asserts! (default-to false (map-get? guardians tx-sender)) (err u2))
            (map-set recovery-requests
                { initiator: tx-sender }
                request)
            (ok true))))
 
;; Confirm recovery request
(define-public (confirm-recovery (initiator principal))
    (let
        ((request (unwrap! (map-get? recovery-requests { initiator: initiator }) (err u3))))
        (begin
            (asserts! (default-to false (map-get? guardians tx-sender)) (err u4))
            (map-set recovery-requests
                { initiator: initiator }
                {
                    timestamp: (get timestamp request),
                    confirmations: (unwrap! (as-max-len?
                        (append (get confirmations request) tx-sender) u10) (err u5))
                })
            (ok true))))
 
;; Execute recovery if enough confirmations
(define-public (execute-recovery (new-owner principal) (initiator principal))
    (let ((request (unwrap! (map-get? recovery-requests { initiator: initiator }) (err u6))))
        (begin
            (asserts! (>= (len (get confirmations request)) (var-get required-confirmations)) (err u7))
            (var-set wallet-owner new-owner)
            (ok true))))
 
;; Check if address is a guardian
(define-read-only (is-guardian (address principal))
    (default-to false (map-get? guardians address)))
 
;; Get current wallet owner
(define-read-only (get-wallet-owner)
    (ok (var-get wallet-owner)))
