"======================================================================
  Ride Sharing System — GNU Smalltalk Fixed Implementation
  Replaces whileTrue: string loops with explicit padding to prevent GC failure.
 ======================================================================"

"----------------------------------------------------------------------
  BASE CLASS: Ride
 ----------------------------------------------------------------------"
Object subclass: Ride [
    | rideID pickupLocation dropoffLocation distance baseFarePerMile |

    Ride class >> newWithID: anID pickup: pickup dropoff: dropoff distance: dist [
        | r |
        r := self new.
        r initID: anID pickup: pickup dropoff: dropoff distance: dist.
        ^ r
    ]

    "--- Completely Loop-Free Format Method ---"
    Ride class >> formatNumber: aNumber decimals: places [
        | scale roundedValue whole frac fracStr padSize |
        scale := 10 raisedTo: places.
        roundedValue := (aNumber * scale) rounded.
        whole := roundedValue // scale.
        frac := roundedValue \\ scale.
        fracStr := frac printString.
        
        "Instant allocation padding instead of a while loop"
        fracStr size < places ifTrue: [
            padSize := places - fracStr size.
            fracStr := (String new: padSize withAll: $0), fracStr
        ].
        ^ whole printString, '.', fracStr
    ]

    Ride class >> formatMoney: aNumber [
        ^ self formatNumber: aNumber decimals: 2
    ]

    initID: anID pickup: pickup dropoff: dropoff distance: dist [
        rideID := anID.
        pickupLocation := pickup.
        dropoffLocation := dropoff.
        distance := dist.
        baseFarePerMile := 1.50.
    ]

    rideID [ ^ rideID ]
    pickupLocation [ ^ pickupLocation ]
    dropoffLocation [ ^ dropoffLocation ]
    distance [ ^ distance ]
    baseFarePerMile [ ^ baseFarePerMile ]
    baseFarePerMile: aValue [ baseFarePerMile := aValue ]

    rideType [ ^ 'Base Ride' ]
    fare [ ^ distance * baseFarePerMile ]

    rideDetails [
        Transcript
            show: '  Ride ID    : '; show: rideID printString; cr;
            show: '  Type       : '; show: self rideType; cr;
            show: '  Pickup     : '; show: pickupLocation; cr;
            show: '  Drop-off   : '; show: dropoffLocation; cr;
            show: '  Distance   : '; show: (Ride formatNumber: distance decimals: 1); show: ' mi'; cr;
            show: '  Fare       : $'; show: (Ride formatMoney: self fare); cr.
    ]
]

"----------------------------------------------------------------------
  DERIVED CLASS: StandardRide
 ----------------------------------------------------------------------"
Ride subclass: StandardRide [
    StandardRide class >> newWithID: anID pickup: pickup dropoff: dropoff distance: dist [
        | r |
        r := self new.
        r initID: anID pickup: pickup dropoff: dropoff distance: dist.
        r baseFarePerMile: 1.25.
        ^ r
    ]

    rideType [ ^ 'Standard' ]
    fare [ ^ (distance * baseFarePerMile) + 1.00 ]

    rideDetails [
        super rideDetails.
        Transcript show: '  Booking Fee: $1.00 (included)'; cr.
    ]
]

"----------------------------------------------------------------------
  DERIVED CLASS: PremiumRide
 ----------------------------------------------------------------------"
Ride subclass: PremiumRide [
    | hasLuxuryCar |

    PremiumRide class >> newWithID: anID pickup: pickup dropoff: dropoff distance: dist luxury: luxFlag [
        | r |
        r := self new.
        r initID: anID pickup: pickup dropoff: dropoff distance: dist.
        r baseFarePerMile: 2.75.
        r setLuxury: luxFlag.
        ^ r
    ]

    PremiumRide class >> newWithID: anID pickup: pickup dropoff: dropoff distance: dist [
        ^ self newWithID: anID pickup: pickup dropoff: dropoff distance: dist luxury: false
    ]

    setLuxury: aBoolean [ hasLuxuryCar := aBoolean ]

    rideType [
        ^ hasLuxuryCar ifTrue: [ 'Premium (Luxury)' ] ifFalse: [ 'Premium' ]
    ]

    fare [
        | base surcharge |
        base := (distance * baseFarePerMile) + 3.50.
        surcharge := hasLuxuryCar ifTrue: [ 5.00 ] ifFalse: [ 0.00 ].
        ^ base + surcharge
    ]

    rideDetails [
        super rideDetails.
        Transcript show: '  Premium Fee: $3.50 (included)'; cr.
        hasLuxuryCar ifTrue: [ Transcript show: '  Luxury Surcharge: $5.00 (included)'; cr ].
    ]
]

"----------------------------------------------------------------------
  DERIVED CLASS: SharedRide
 ----------------------------------------------------------------------"
Ride subclass: SharedRide [
    | passengerCount |

    SharedRide class >> newWithID: anID pickup: pickup dropoff: dropoff distance: dist passengers: n [
        | r |
        r := self new.
        r initID: anID pickup: pickup dropoff: dropoff distance: dist.
        r baseFarePerMile: 0.90.
        r setPassengers: n.
        ^ r
    ]

    setPassengers: n [ passengerCount := n ]
    rideType [ ^ 'Shared' ]
    fare [ ^ ((distance * baseFarePerMile) + 0.50) / passengerCount ]

    rideDetails [
        super rideDetails.
        Transcript show: '  Passengers : '; show: passengerCount printString; show: ' (fare shown is per-person)'; cr.
    ]
]

"----------------------------------------------------------------------
  CLASS: Driver
 ----------------------------------------------------------------------"
Object subclass: Driver [
    | driverID name rating assignedRides |

    Driver class >> id: anID name: aName rating: aRating [
        | d |
        d := self new.
        d initID: anID name: aName rating: aRating.
        ^ d
    ]

    initID: anID name: aName rating: aRating [
        driverID := anID.
        name := aName.
        rating := aRating.
        assignedRides := OrderedCollection new.
    ]

    addRide: aRide [ assignedRides add: aRide. ]
    rideCount [ ^ assignedRides size ]

    totalEarnings [
        | total |
        total := 0.
        assignedRides do: [ :r | total := total + r fare ].
        ^ total
    ]

    getDriverInfo [
        Transcript
            show: '  Driver ID  : '; show: driverID printString; cr;
            show: '  Name       : '; show: name; cr;
            show: '  Rating     : '; show: (Ride formatNumber: rating decimals: 1); show: ' / 5.0'; cr;
            show: '  Rides Done : '; show: self rideCount printString; cr;
            show: '  Total Earned: $'; show: (Ride formatMoney: self totalEarnings); cr.
    ]

    listRides [
        assignedRides isEmpty
            ifTrue: [ Transcript show: '  (no rides yet)'; cr ]
            ifFalse: [
                assignedRides do: [ :r |
                    Transcript 
                        show: '  - Ride #'; show: r rideID printString;
                        show: ' ['; show: r rideType; 
                        show: '] | $'; show: (Ride formatMoney: r fare); cr ] ].
    ]
]

"----------------------------------------------------------------------
  CLASS: Rider
 ----------------------------------------------------------------------"
Object subclass: Rider [
    | riderID name requestedRides |

    Rider class >> id: anID name: aName [
        | r |
        r := self new.
        r initID: anID name: aName.
        ^ r
    ]

    initID: anID name: aName [
        riderID := anID.
        name := aName.
        requestedRides := OrderedCollection new.
    ]

    requestRide: aRide [
        requestedRides add: aRide.
        Transcript show: '  >> Ride #'; show: aRide rideID printString;
                 show: ' ('; show: aRide rideType; show: ') booked for '; show: name;
                 show: '. Estimated fare: $'; show: (Ride formatMoney: aRide fare); cr.
    ]

    viewRides [
        | total |
        total := 0.
        Transcript show: '  Ride history for '; show: name; show: ' (ID '; show: riderID printString; show: '):'; cr.
        requestedRides isEmpty
            ifTrue: [ Transcript show: '    (no rides yet)'; cr ]
            ifFalse: [
                requestedRides do: [ :r |
                    Transcript show: '    Ride #'; show: r rideID printString;
                             show: ' | '; show: r pickupLocation; show: ' -> '; show: r dropoffLocation;
                             show: ' | '; show: r rideType; show: ' | $'; show: (Ride formatMoney: r fare); cr.
                    total := total + r fare ].
                Transcript show: '    Total spent: $'; show: (Ride formatMoney: total); cr ].
    ]
]

"======================================================================
  DEMO RUNTIME SCRIPT
 ======================================================================"
| rides d1 d2 r1 r2 grandTotal |

Transcript cr; show: '======================================================='; cr.
Transcript show: '       RIDE SHARING SYSTEM  --  Smalltalk Demo'; cr.
Transcript show: '======================================================='; cr.

rides := OrderedCollection new.
rides add: (StandardRide newWithID: 101 pickup: 'Main St' dropoff: 'Airport' distance: 8.5).
rides add: (PremiumRide newWithID: 102 pickup: 'Hotel Plaza' dropoff: 'Convention Ctr' distance: 3.2).
rides add: (SharedRide newWithID: 103 pickup: 'Downtown' dropoff: 'University' distance: 5.0 passengers: 3).
rides add: (PremiumRide newWithID: 104 pickup: 'Suburb' dropoff: 'City Center' distance: 12.0 luxury: true).
rides add: (StandardRide newWithID: 105 pickup: 'Park Ave' dropoff: 'Mall' distance: 2.1).

Transcript cr; show: '-------------------------------------------------------'; cr.
Transcript show: '  POLYMORPHIC RIDE DETAILS  (fare dispatched virtually)'; cr.
Transcript show: '-------------------------------------------------------'; cr.
rides doWithIndex: [ :r :i |
    Transcript cr; show: '[Ride '; show: i printString; show: ']'; cr.
    r rideDetails ].

d1 := Driver id: 501 name: 'Alex Rivera' rating: 4.9.
d2 := Driver id: 502 name: 'Jordan Smith' rating: 4.6.

d1 addRide: (rides at: 1).
d1 addRide: (rides at: 3).
d1 addRide: (rides at: 5).
d2 addRide: (rides at: 2).
d2 addRide: (rides at: 4).

Transcript cr; show: '-------------------------------------------------------'; cr.
Transcript show: '  DRIVER INFORMATION  (encapsulated assignedRides)'; cr.
Transcript show: '-------------------------------------------------------'; cr.
Transcript cr; show: '[Driver 1]'; cr. d1 getDriverInfo.
Transcript show: '  Rides driven:'; cr. d1 listRides.
Transcript cr; show: '[Driver 2]'; cr. d2 getDriverInfo.
Transcript show: '  Rides driven:'; cr. d2 listRides.

r1 := Rider id: 201 name: 'Sam Lee'.
r2 := Rider id: 202 name: 'Morgan Chen'.

Transcript cr; show: '-------------------------------------------------------'; cr.
Transcript show: '  RIDER RIDE REQUESTS  (encapsulated requestedRides)'; cr.
Transcript show: '-------------------------------------------------------'; cr.
Transcript cr.
r1 requestRide: (rides at: 1).
r1 requestRide: (rides at: 3).
r2 requestRide: (rides at: 2).
r2 requestRide: (rides at: 4).
r2 requestRide: (rides at: 5).

Transcript cr; show: '-------------------------------------------------------'; cr.
Transcript show: '  RIDER RIDE HISTORIES'; cr.
Transcript show: '-------------------------------------------------------'; cr.
Transcript cr.
r1 viewRides.
Transcript cr.
r2 viewRides.

grandTotal := 0.
Transcript cr; show: '-------------------------------------------------------'; cr.
Transcript show: '  POLYMORPHIC FARE SUMMARY'; cr.
Transcript show: '-------------------------------------------------------'; cr.
Transcript cr.
rides do: [ :r |
    Transcript show: '  Ride #'; show: r rideID printString;
                     show: '   ['; show: r rideType; show: ']  $'; show: (Ride formatMoney: r fare); cr.
    grandTotal := grandTotal + r fare ].
Transcript show: '---------------------------------------------'; cr.
Transcript show: '  Grand Total Fares: $'; show: (Ride formatMoney: grandTotal); cr.

Transcript cr; show: '======================================================='; cr.
Transcript show: '  OOP Principles Demonstrated Successfully'; cr.
Transcript cr.