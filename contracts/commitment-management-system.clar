;; Objective Management System

(define-constant NOT_FOUND_ERROR (err u404)) 


(define-map commitment-registry
    principal
    {
        commitment-description: (string-ascii 100),
        fulfillment-status: bool
    }
)

(define-constant CONFLICT_ERROR (err u409)) 
(define-constant INVALID_INPUT_ERROR (err u400))

(define-map commitment-priority
    principal
    {
        urgency-level: uint
    }
)

(define-map commitment-deadlines
    principal
    {
        deadline-block: uint,
        alert-triggered: bool
    }
)

;; ======================================================================
;; DATA RETRIEVAL FUNCTIONS
;; ======================================================================

