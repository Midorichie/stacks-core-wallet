;; tests/wallet_test.clar
(use-fixture.chain-util)

(define-constant wallet-owner 'ST1PQHQKV0RJXZFY1DGX8MNSNYVE3VGZJSRTPGZGM)
(define-constant guardian-1 'ST2CY5V39NHDPWSXMW9QDT3HC3GD6Q6XX4CFRK9AG)
(define-constant guardian-2 'ST2JHG361ZXG51QTKY2NQCVBPPRRE2KZB1HR05NNC)
(define-constant guardian-3 'ST2NEB84ASENDXKYGJPQW86YXQCEFEX2ZQPG87ND)

(define-test "test-initialize-wallet"
    (begin
        (env-chain-init
            { 'network: 'testnet,
              'sender: wallet-owner })
        
        (assert-eq
            (initialize-wallet (list guardian-1 guardian-2 guardian-3))
            (ok true))))

(define-test "test-recovery-flow"
    (begin
        ;; Setup
        (env-chain-init
            { 'network: 'testnet,
              'sender: guardian-1 })
        
        ;; Test initiate recovery
        (assert-eq
            (initiate-recovery)
            (ok true))
        
        ;; Test confirmation
        (env-chain-init
            { 'sender: guardian-2 })
        (assert-eq
            (confirm-recovery guardian-1)
            (ok true))
        
        ;; Test execution
        (assert-eq
            (execute-recovery wallet-owner guardian-1)
            (ok true))))
