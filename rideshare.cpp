#include <iostream>
#include <vector>
#include <string>
#include <iomanip>
#include <memory>
#include <algorithm>

// ============================================================
// BASE CLASS: Ride
// Demonstrates ENCAPSULATION via private members + public API
// ============================================================
class Ride {
private:
    int rideID;
    std::string pickupLocation;
    std::string dropoffLocation;
    double distance; // miles

protected:
    double baseFarePerMile;

public:
    Ride(int id, const std::string& pickup, const std::string& dropoff, double dist)
        : rideID(id), pickupLocation(pickup), dropoffLocation(dropoff),
          distance(dist), baseFarePerMile(1.50) {}

    virtual ~Ride() = default;

    // Getters (encapsulation)
    int getRideID()                     const { return rideID; }
    std::string getPickupLocation()     const { return pickupLocation; }
    std::string getDropoffLocation()    const { return dropoffLocation; }
    double getDistance()                const { return distance; }

    // POLYMORPHIC method — overridden in subclasses
    virtual double fare() const {
        return distance * baseFarePerMile;
    }

    // POLYMORPHIC method — overridden in subclasses
    virtual void rideDetails() const {
        std::cout << std::fixed << std::setprecision(2);
        std::cout << "  Ride ID      : " << rideID       << "\n"
                  << "  Type         : " << rideType()   << "\n"
                  << "  Pickup       : " << pickupLocation  << "\n"
                  << "  Drop-off     : " << dropoffLocation << "\n"
                  << "  Distance     : " << distance << " mi\n"
                  << "  Fare         : $" << fare()       << "\n";
    }

    // Pure virtual helper used by rideDetails()
    virtual std::string rideType() const = 0;
};

// ============================================================
// DERIVED CLASS: StandardRide — INHERITANCE + POLYMORPHISM
// ============================================================
class StandardRide : public Ride {
public:
    StandardRide(int id, const std::string& pickup, const std::string& dropoff, double dist)
        : Ride(id, pickup, dropoff, dist) {
        baseFarePerMile = 1.25; // Cheaper per-mile rate
    }

    double fare() const override {
        double base = getDistance() * baseFarePerMile;
        double bookingFee = 1.00;
        return base + bookingFee;
    }

    std::string rideType() const override { return "Standard"; }

    void rideDetails() const override {
        Ride::rideDetails();
        std::cout << "  Booking Fee  : $1.00 (included)\n";
    }
};

// ============================================================
// DERIVED CLASS: PremiumRide — INHERITANCE + POLYMORPHISM
// ============================================================
class PremiumRide : public Ride {
private:
    bool hasLuxuryCar;

public:
    PremiumRide(int id, const std::string& pickup, const std::string& dropoff,
                double dist, bool luxury = false)
        : Ride(id, pickup, dropoff, dist), hasLuxuryCar(luxury) {
        baseFarePerMile = 2.75; // Premium per-mile rate
    }

    double fare() const override {
        double base = getDistance() * baseFarePerMile;
        double premiumFee = 3.50;
        double luxurySurcharge = hasLuxuryCar ? 5.00 : 0.00;
        return base + premiumFee + luxurySurcharge;
    }

    std::string rideType() const override {
        return hasLuxuryCar ? "Premium (Luxury)" : "Premium";
    }

    void rideDetails() const override {
        Ride::rideDetails();
        std::cout << "  Premium Fee  : $3.50 (included)\n";
        if (hasLuxuryCar)
            std::cout << "  Luxury Surcharge: $5.00 (included)\n";
    }
};

// ============================================================
// DERIVED CLASS: SharedRide — third ride type
// ============================================================
class SharedRide : public Ride {
private:
    int passengerCount;

public:
    SharedRide(int id, const std::string& pickup, const std::string& dropoff,
               double dist, int passengers = 2)
        : Ride(id, pickup, dropoff, dist), passengerCount(passengers) {
        baseFarePerMile = 0.90;
    }

    double fare() const override {
        double totalCost = getDistance() * baseFarePerMile + 0.50;
        return totalCost / passengerCount; // Split among passengers
    }

    std::string rideType() const override { return "Shared"; }

    void rideDetails() const override {
        Ride::rideDetails();
        std::cout << "  Passengers   : " << passengerCount
                  << " (fare shown is per-person)\n";
    }
};

// ============================================================
// Driver Class — ENCAPSULATION of assignedRides
// ============================================================
class Driver {
private:
    int driverID;
    std::string name;
    double rating;
    std::vector<std::shared_ptr<Ride>> assignedRides; // private — encapsulated

public:
    Driver(int id, const std::string& n, double r)
        : driverID(id), name(n), rating(r) {}

    // Add a ride — only way to modify assignedRides
    void addRide(std::shared_ptr<Ride> ride) {
        assignedRides.push_back(ride);
    }

    // Read-only access to ride count
    int getRideCount() const { return static_cast<int>(assignedRides.size()); }

    double totalEarnings() const {
        double total = 0;
        for (const auto& r : assignedRides) total += r->fare();
        return total;
    }

    void getDriverInfo() const {
        std::cout << std::fixed << std::setprecision(2);
        std::cout << "  Driver ID    : " << driverID    << "\n"
                  << "  Name         : " << name        << "\n"
                  << "  Rating       : " << rating      << " / 5.0\n"
                  << "  Rides Done   : " << getRideCount() << "\n"
                  << "  Total Earned : $" << totalEarnings() << "\n";
    }

    void listRides() const {
        if (assignedRides.empty()) {
            std::cout << "  (no rides yet)\n";
            return;
        }
        for (const auto& r : assignedRides) {
            std::cout << "  - Ride #" << r->getRideID()
                      << " [" << r->rideType() << "]"
                      << " | $" << std::fixed << std::setprecision(2) << r->fare() << "\n";
        }
    }

    std::string getName() const { return name; }
};

// ============================================================
// Rider Class — ENCAPSULATION of requestedRides
// ============================================================
class Rider {
private:
    int riderID;
    std::string name;
    std::vector<std::shared_ptr<Ride>> requestedRides; // private — encapsulated

public:
    Rider(int id, const std::string& n) : riderID(id), name(n) {}

    void requestRide(std::shared_ptr<Ride> ride) {
        requestedRides.push_back(ride);
        std::cout << "  >> Ride #" << ride->getRideID()
                  << " (" << ride->rideType() << ") booked for " << name
                  << ". Estimated fare: $"
                  << std::fixed << std::setprecision(2) << ride->fare() << "\n";
    }

    void viewRides() const {
        std::cout << "  Ride history for " << name << " (ID " << riderID << "):\n";
        if (requestedRides.empty()) {
            std::cout << "    (no rides yet)\n";
            return;
        }
        double total = 0;
        for (const auto& r : requestedRides) {
            std::cout << "    Ride #" << r->getRideID()
                      << " | " << r->getPickupLocation()
                      << " -> " << r->getDropoffLocation()
                      << " | " << r->rideType()
                      << " | $" << std::fixed << std::setprecision(2) << r->fare() << "\n";
            total += r->fare();
        }
        std::cout << "    Total spent: $" << total << "\n";
    }

    std::string getName() const { return name; }
};

// ============================================================
// Helpers
// ============================================================
void printSeparator(const std::string& title = "") {
    std::cout << "\n" << std::string(55, '=') << "\n";
    if (!title.empty()) std::cout << "  " << title << "\n" << std::string(55, '-') << "\n";
}

// ============================================================
// MAIN — demonstrates polymorphism, encapsulation, inheritance
// ============================================================
int main() {
    std::cout << "\n";
    std::cout << "  ╔═══════════════════════════════════════════════════╗\n";
    std::cout << "  ║         RIDE SHARING SYSTEM  —  C++ Demo          ║\n";
    std::cout << "  ╚═══════════════════════════════════════════════════╝\n";

    // --- Create rides (stored as base-class pointers → polymorphism) ---
    std::vector<std::shared_ptr<Ride>> rides;
    rides.push_back(std::make_shared<StandardRide>(101, "Main St",    "Airport",       8.5));
    rides.push_back(std::make_shared<PremiumRide> (102, "Hotel Plaza","Convention Ctr",3.2));
    rides.push_back(std::make_shared<SharedRide>  (103, "Downtown",   "University",    5.0, 3));
    rides.push_back(std::make_shared<PremiumRide> (104, "Suburb",     "City Center",   12.0, true));
    rides.push_back(std::make_shared<StandardRide>(105, "Park Ave",   "Mall",          2.1));

    // --- Polymorphic dispatch: call fare() and rideDetails() ---
    printSeparator("POLYMORPHIC RIDE DETAILS  (fare() dispatched virtually)");
    for (size_t i = 0; i < rides.size(); ++i) {
        std::cout << "\n[Ride " << (i+1) << "]\n";
        rides[i]->rideDetails(); // virtual dispatch
    }

    // --- Create drivers ---
    Driver d1(501, "Alex Rivera",  4.9);
    Driver d2(502, "Jordan Smith", 4.6);

    d1.addRide(rides[0]);
    d1.addRide(rides[2]);
    d1.addRide(rides[4]);
    d2.addRide(rides[1]);
    d2.addRide(rides[3]);

    printSeparator("DRIVER INFORMATION  (encapsulated assignedRides)");
    std::cout << "\n[Driver 1]\n"; d1.getDriverInfo();
    std::cout << "\n  Rides driven:\n"; d1.listRides();
    std::cout << "\n[Driver 2]\n"; d2.getDriverInfo();
    std::cout << "\n  Rides driven:\n"; d2.listRides();

    // --- Create riders ---
    Rider r1(201, "Sam Lee");
    Rider r2(202, "Morgan Chen");

    printSeparator("RIDER RIDE REQUESTS  (encapsulated requestedRides)");
    std::cout << "\n";
    r1.requestRide(rides[0]);
    r1.requestRide(rides[2]);
    r2.requestRide(rides[1]);
    r2.requestRide(rides[3]);
    r2.requestRide(rides[4]);

    printSeparator("RIDER RIDE HISTORIES");
    std::cout << "\n"; r1.viewRides();
    std::cout << "\n"; r2.viewRides();

    // --- Polymorphic fare summary ---
    printSeparator("POLYMORPHIC FARE SUMMARY");
    std::cout << "\n";
    double grandTotal = 0;
    for (const auto& ride : rides) {
        std::cout << "  Ride #" << ride->getRideID()
                  << "  [" << std::left << std::setw(18) << (ride->rideType() + "]")
                  << "  $" << std::fixed << std::setprecision(2) << ride->fare() << "\n";
        grandTotal += ride->fare();
    }
    std::cout << std::string(45, '-') << "\n";
    std::cout << "  Grand Total Fares:              $"
              << std::fixed << std::setprecision(2) << grandTotal << "\n";

    printSeparator();
    std::cout << "  OOP Principles Demonstrated:\n"
              << "    Encapsulation : private assignedRides / requestedRides\n"
              << "    Inheritance   : Standard/Premium/SharedRide <- Ride\n"
              << "    Polymorphism  : fare() and rideDetails() dispatched virtually\n";
    printSeparator();

    return 0;
}
