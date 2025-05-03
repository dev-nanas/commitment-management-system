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


;; Public validation function for client applications
;; Performs existence check and returns metadata without state modification
(define-public (validate-commitment-existence)
    (let
        (
            (entity tx-sender)
            (existing-record (map-get? commitment-registry entity))
        )
        (if (is-some existing-record)
            (let
                (
                    (current-record (unwrap! existing-record NOT_FOUND_ERROR))
                    (description-text (get commitment-description current-record))
                    (completion-status (get fulfillment-status current-record))
                )
                (ok {
                    record-found: true,
                    description-length: (len description-text),
                    is-fulfilled: completion-status
                })
            )
            (ok {
                record-found: false,
                description-length: u0,
                is-fulfilled: false
            })
        )
    )
)

;; ======================================================================
;; CORE COMMITMENT MANAGEMENT FUNCTIONS
;; ======================================================================
;; Public function enabling users to register a new commitment
;; Creates an immutable record of digital obligations
(define-public (register-commitment 
    (commitment-text (string-ascii 100)))
    (let
        (
            (entity tx-sender)
            (existing-record (map-get? commitment-registry entity))
        )
        (if (is-none existing-record)
            (begin
                (if (is-eq commitment-text "")
                    (err INVALID_INPUT_ERROR)
                    (begin
                        (map-set commitment-registry entity
                            {
                                commitment-description: commitment-text,
                                fulfillment-status: false
                            }
                        )
                        (ok "Digital commitment successfully registered in system.")
                    )
                )
            )
            (err CONFLICT_ERROR)
        )
    )
)

;; Public function enabling modification of existing commitment details
;; Allows updating both descriptive content and fulfillment status
(define-public (modify-commitment
    (commitment-text (string-ascii 100))
    (fulfillment-status bool))
    (let
        (
            (entity tx-sender)
            (existing-record (map-get? commitment-registry entity))
        )
        (if (is-some existing-record)
            (begin
                (if (is-eq commitment-text "")
                    (err INVALID_INPUT_ERROR)
                    (begin
                        (if (or (is-eq fulfillment-status true) (is-eq fulfillment-status false))
                            (begin
                                (map-set commitment-registry entity
                                    {
                                        commitment-description: commitment-text,
                                        fulfillment-status: fulfillment-status
                                    }
                                )
                                (ok "Digital commitment successfully updated in system.")
                            )
                            (err INVALID_INPUT_ERROR)
                        )
                    )
                )
            )
            (err NOT_FOUND_ERROR)
        )
    )
)

;; Public function for removing unwanted commitments
;; Completely removes commitment data from blockchain storage
(define-public (remove-commitment)
    (let
        (
            (entity tx-sender)
            (existing-record (map-get? commitment-registry entity))
        )
        (if (is-some existing-record)
            (begin
                (map-delete commitment-registry entity)
                (ok "Digital commitment successfully purged from system.")
            )
            (err NOT_FOUND_ERROR)
        )
    )
)

;; ======================================================================
;; COLLABORATION AND DELEGATION CAPABILITIES
;; ======================================================================
;; Public function enabling commitment assignment to other users
;; Facilitates team coordination and responsibility distribution
(define-public (assign-commitment
    (target-entity principal)
    (commitment-text (string-ascii 100)))
    (let
        (
            (existing-record (map-get? commitment-registry target-entity))
        )
        (if (is-none existing-record)
            (begin
                (if (is-eq commitment-text "")
                    (err INVALID_INPUT_ERROR)
                    (begin
                        (map-set commitment-registry target-entity
                            {
                                commitment-description: commitment-text,
                                fulfillment-status: false
                            }
                        )
                        (ok "Digital commitment successfully assigned to recipient.")
                    )
                )
            )
            (err CONFLICT_ERROR)
        )
    )
)

;; ======================================================================
;; ADVANCED COMMITMENT MANAGEMENT EXTENSIONS
;; ======================================================================
;; Public function for establishing time constraints
;; Defines blockchain-based deadline for commitment fulfillment
(define-public (establish-commitment-deadline (blocks-until-due uint))
    (let
        (
            (entity tx-sender)
            (existing-record (map-get? commitment-registry entity))
            (target-completion-block (+ block-height blocks-until-due))
        )
        (if (is-some existing-record)
            (if (> blocks-until-due u0)
                (begin
                    (map-set commitment-deadlines entity
                        {
                            deadline-block: target-completion-block,
                            alert-triggered: false
                        }
                    )
                    (ok "Commitment deadline successfully established.")
                )
                (err INVALID_INPUT_ERROR)
            )
            (err NOT_FOUND_ERROR)
        )
    )
)

;; Public function for priority classification
;; Implements tri-level urgency system (1=minimal, 2=moderate, 3=critical)
(define-public (establish-commitment-urgency (urgency-rating uint))
    (let
        (
            (entity tx-sender)
            (existing-record (map-get? commitment-registry entity))
        )
        (if (is-some existing-record)
            (if (and (>= urgency-rating u1) (<= urgency-rating u3))
                (begin
                    (map-set commitment-priority entity
                        {
                            urgency-level: urgency-rating
                        }
                    )
                    (ok "Commitment urgency classification successfully updated.")
                )
                (err INVALID_INPUT_ERROR)
            )
            (err NOT_FOUND_ERROR)
        )
    )
)

