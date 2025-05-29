
;; CraftMarket Hub: Artisan marketplace for handmade crafts and custom orders
;; Connects skilled craftspeople with customers seeking unique handmade items

(define-data-var marketplace-curator principal tx-sender)
(define-map craft-showcase
  { craft-id: uint }
  {
    artisan: principal,
    commission: uint,
    craft-name: (string-ascii 50),
    materials: (string-ascii 500),
    creation-time: uint,
    certified: bool
  }
)

(define-map commission-timeline
  { craft-id: uint, event-id: uint }
  {
    client: principal,
    timestamp: uint,
    status: (string-ascii 20)
  }
)

(define-data-var next-craft-id uint u1)
(define-map timeline-tracker 
  { craft-id: uint }
  { events: uint }
)

;; Showcase a new craft
(define-public (showcase-craft (name-input (string-ascii 50)) (materials-input (string-ascii 500)) (time-input uint) (commission-input uint))
  (let
    (
      (craft-id (var-get next-craft-id))
      (event-id u0)
      (name name-input)
      (materials materials-input)
      (time time-input)
      (commission commission-input)
    )
    ;; Input validation
    (asserts! (> commission u0) (err u1))
    (asserts! (> (len name) u0) (err u5))
    (asserts! (> (len materials) u0) (err u6))
    (asserts! (> time u0) (err u7))
    
    (map-set craft-showcase
      { craft-id: craft-id }
      {
        artisan: tx-sender,
        commission: commission,
        craft-name: name,
        materials: materials,
        creation-time: time,
        certified: false
      }
    )
    (map-set commission-timeline
      { craft-id: craft-id, event-id: event-id }
      {
        client: tx-sender,
        timestamp: craft-id,
        status: "showcased"
      }
    )
    (map-set timeline-tracker 
      { craft-id: craft-id }
      { events: u1 }
    )
    (var-set next-craft-id (+ craft-id u1))
    (ok craft-id)
  )
)

;; Commission a craft
(define-public (commission-craft (craft-id-input uint))
  (let
    (
      (craft-id craft-id-input)
      (craft-info (unwrap! (map-get? craft-showcase { craft-id: craft-id }) (err u2)))
      (commission (get commission craft-info))
      (artisan (get artisan craft-info))
      (timeline-data (default-to { events: u0 } (map-get? timeline-tracker { craft-id: craft-id })))
      (event-id (get events timeline-data))
      (new-event-id (+ event-id u1))
    )
    ;; Input validation
    (asserts! (> craft-id u0) (err u8))
    (asserts! (not (is-eq tx-sender artisan)) (err u3))
    
    (try! (stx-transfer? commission tx-sender artisan))
    (map-set commission-timeline
      { craft-id: craft-id, event-id: event-id }
      {
        client: tx-sender,
        timestamp: (var-get next-craft-id),
        status: "commissioned"
      }
    )
    (map-set timeline-tracker 
      { craft-id: craft-id }
      { events: new-event-id }
    )
    (ok true)
  )
)

;; Certify a craft (curator only)
(define-public (certify-craft (craft-id-input uint))
  (let
    (
      (craft-id craft-id-input)
      (craft-info (unwrap! (map-get? craft-showcase { craft-id: craft-id }) (err u2)))
      (timeline-data (default-to { events: u0 } (map-get? timeline-tracker { craft-id: craft-id })))
      (event-id (get events timeline-data))
      (new-event-id (+ event-id u1))
    )
    ;; Input validation
    (asserts! (> craft-id u0) (err u8))
    (asserts! (is-eq tx-sender (var-get marketplace-curator)) (err u4))
    
    (map-set craft-showcase
      { craft-id: craft-id }
      (merge craft-info { certified: true })
    )
    (map-set commission-timeline
      { craft-id: craft-id, event-id: event-id }
      {
        client: (get artisan craft-info),
        timestamp: (var-get next-craft-id),
        status: "certified"
      }
    )
    (map-set timeline-tracker 
      { craft-id: craft-id }
      { events: new-event-id }
    )
    (ok true)
  )
)

;; Get craft details
(define-read-only (get-craft (craft-id uint))
  (map-get? craft-showcase { craft-id: craft-id })
)

;; Get commission timeline
(define-read-only (get-timeline-event (craft-id uint) (event-id uint))
  (map-get? commission-timeline { craft-id: craft-id, event-id: event-id })
)

;; Get total timeline events for a craft
(define-read-only (get-timeline-length (craft-id uint))
  (let
    (
      (timeline-data (default-to { events: u0 } (map-get? timeline-tracker { craft-id: craft-id })))
    )
    (get events timeline-data)
  )
)