# Ride-Sharing System (GNU Smalltalk)

A terminal-based simulation of a Ride-Sharing System implemented in **GNU Smalltalk (GST)**. This project models standard, premium, and shared ride architectures to demonstrate core Object-Oriented Programming (OOP) principles within a pure object-oriented runtime environment.

---

## 🚀 Features & OOP Architecture

The system maps real-world entities into a strictly encapsulated class hierarchy:

* **Encapsulation:** Internal state attributes - such as a driver's `assignedRides` or a rider's `requestedRides` collections - are completely private. They cannot be modified directly from the outside and are manipulated strictly through message passing (`addRide:`, `requestRide:`).
* **Inheritance:** A polymorphic base class `Ride` handles universal ride states (IDs, routing, and deep-level safe string formatting). Specialized behaviors are cleanly partitioned into subclasses:
  * `StandardRide`: Introduces basic booking fees.
  * `PremiumRide`: Dynamically injects premium base rates and optional luxury vehicle surcharges.
  * `SharedRide`: Manages passenger capacity and evenly splits fares among occupants.
* **Polymorphism:** Dynamic binding is utilized during runtime collection iteration. Messaging `self rideType` or `self fare` automatically evaluates down to the respective subclass implementation at execution time.

---

## 🛠️ Development Environment & Execution

This project is fully compatible with local environments and cloud-based sandbox IDEs like **OnlineGDB**.

### Running on OnlineGDB (Cloud Sandbox)

1. Navigate to [OnlineGDB](https://www.onlinegdb.com/).
2. In the top-right corner, change the **Language** dropdown to **Smalltalk**.
3. Paste the contents of `rideshare.st` into the main code editor.
4. Click **Run** (or press `F9`).

> ⚠️ **Environment Note:** Online compilers operate under strict container memory constraints. This codebase utilizes production-grade message-driven selectors (`!ClassName methodsFor: '...'!`) and memory-bounded string formatting to prevent the GNU Smalltalk virtual machine from exhausting the cloud container's tight heap allocation limit.

### Running Locally

To execute this program natively, you must have the **GNU Smalltalk** interpreter installed.

* **macOS (via Homebrew):**

    ```bash
    brew install gnu-smalltalk
    ```

* **Linux (Debian/Ubuntu):**

    ```bash
    sudo apt-get update && sudo apt-get install gnu-smalltalk
    ```

* **Execution:** Run the single-file script using the interpreter:

    ```bash
    gst RideSharingSystem.st
    ```

---

## ⚡ Technical Optimizations

* **Memory Deforestation (No Loops for Padding):** To eliminate runtime `Memory allocation failure` loops inside constrained environments, decimal number padding avoids recurring `whileTrue:` string appending. It leverages immediate, single-allocation arrays: `(String new: padSize withAll: $0)`.
* **Local Block Scope Returns:** The code explicitly refrains from using non-local returns (`^`) within closed closure execution blocks (such as conditional branch arrays inside loops), ensuring the call stack remains pristine during heavy system processing.

---

## 📊 Expected Output Demo

When executed successfully, the script instantiates a polymorphic collection of rides, processes bookings, calculates custom financials, and surfaces an end-to-end event trace on the `Transcript` stream:

```text
=======================================================
       RIDE SHARING SYSTEM  --  Smalltalk Demo
=======================================================

-------------------------------------------------------
  POLYMORPHIC RIDE DETAILS  (fare dispatched virtually)
-------------------------------------------------------

[Ride 1]
  Ride ID    : 101
  Type       : Standard
  Pickup     : Main St
  Drop-off   : Airport
  Distance   : 8.5 mi
  Fare       : $11.63
  Booking Fee: $1.00 (included)

[Ride 2]
  Ride ID    : 102
  Type       : Premium
  Pickup     : Hotel Plaza
  Drop-off   : Convention Ctr
  Distance   : 3.2 mi
  Fare       : $12.30
  Premium Fee: $3.50 (included)

[Ride 3]
  Ride ID    : 103
  Type       : Shared
  Pickup     : Downtown
  Drop-off   : University
  Distance   : 5.0 mi
  Fare       : $1.67
  Passengers : 3 (fare shown is per-person)

[Ride 4]
  Ride ID    : 104
  Type       : Premium (Luxury)
  Pickup     : Suburb
  Drop-off   : City Center
  Distance   : 12.0 mi
  Fare       : $41.50
  Premium Fee: $3.50 (included)
  Luxury Surcharge: $5.00 (included)

[Ride 5]
  Ride ID    : 105
  Type       : Standard
  Pickup     : Park Ave
  Drop-off   : Mall
  Distance   : 2.1 mi
  Fare       : $3.63
  Booking Fee: $1.00 (included)

-------------------------------------------------------
  DRIVER INFORMATION  (encapsulated assignedRides)
-------------------------------------------------------

[Driver 1]
  Driver ID  : 501
  Name       : Alex Rivera
  Rating     : 4.9 / 5.0
  Rides Done : 3
  Total Earned: $16.92
  Rides driven:
  - Ride #101 [Standard] | $11.63
  - Ride #103 [Shared] | $1.67
  - Ride #105 [Standard] | $3.63

[Driver 2]
  Driver ID  : 502
  Name       : Jordan Smith
  Rating     : 4.6 / 5.0
  Rides Done : 2
  Total Earned: $53.80
  Rides driven:
  - Ride #102 [Premium] | $12.30
  - Ride #104 [Premium (Luxury)] | $41.50

-------------------------------------------------------
  RIDER RIDE REQUESTS  (encapsulated requestedRides)
-------------------------------------------------------

  >> Ride #101 (Standard) booked for Sam Lee. Estimated fare: $11.63
  >> Ride #103 (Shared) booked for Sam Lee. Estimated fare: $1.67
  >> Ride #102 (Premium) booked for Morgan Chen. Estimated fare: $12.30
  >> Ride #104 (Premium (Luxury)) booked for Morgan Chen. Estimated fare: $41.50
  >> Ride #105 (Standard) booked for Morgan Chen. Estimated fare: $3.63

-------------------------------------------------------
  RIDER RIDE HISTORIES
-------------------------------------------------------

  Ride history for Sam Lee (ID 201):
    Ride #101 | Main St -> Airport | Standard | $11.63
    Ride #103 | Downtown -> University | Shared | $1.67
    Total spent: $13.30

  Ride history for Morgan Chen (ID 202):
    Ride #102 | Hotel Plaza -> Convention Ctr | Premium | $12.30
    Ride #104 | Suburb -> City Center | Premium (Luxury) | $41.50
    Ride #105 | Park Ave -> Mall | Standard | $3.63
    Total spent: $57.43

-------------------------------------------------------
  POLYMORPHIC FARE SUMMARY
-------------------------------------------------------

  Ride #101   [Standard]  $11.63
  Ride #102   [Premium]  $12.30
  Ride #103   [Shared]  $1.67
  Ride #104   [Premium (Luxury)]  $41.50
  Ride #105   [Standard]  $3.63
---------------------------------------------
  Grand Total Fares: $70.73

=======================================================
  OOP Principles Demonstrated Successfully
=======================================================
