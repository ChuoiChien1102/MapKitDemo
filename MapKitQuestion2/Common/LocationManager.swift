//
//  LocationManager.swift
//  Question3
//
//
import Foundation
import CoreLocation
import MapKit

protocol LocationManagerDelegate: AnyObject {
    func didUpdateVelocity(_ velocity: Double)
    func didUpdateDistanceRemaining(_ distanceRemaining: Double)
    func didUpdateTimeUsed(_ timeUsed: Double)
    func didUpdateTimeRemaining(_ timeRemaining: Double)
    func didReachTreasure()
    func showNoMovementAlert()
}

protocol LocationManagerToStoreVCDelegate: AnyObject {
    func didReachTreasure()
}

class LocationManager: NSObject, CLLocationManagerDelegate {
    static let shared = LocationManager()
    
    var locationMG = CLLocationManager()
    weak var delegate: LocationManagerDelegate?
    weak var toStoreVCdelegate: LocationManagerToStoreVCDelegate?
    
    var treasureLocation: CLLocation?
    var startTime: Date?
    var totalTimeLimit: TimeInterval = 1800
    var noMovementTimer: Timer?
    let noMovementDuration: TimeInterval = 11.0 // Time limit for detecting no movement
    
    private override init() {
        super.init()
        locationMG.delegate = self
        locationMG.desiredAccuracy = kCLLocationAccuracyBest
        checkLocationAuthorization()
    }
    
    // Function to set the target treasure location and reset tracking
    func setTreasureLocation(latitude: Double, longitude: Double, timeLimit: TimeInterval?) {
        treasureLocation = CLLocation(latitude: latitude, longitude: longitude)
        if timeLimit != nil {
            totalTimeLimit = timeLimit!
        }
    }
    
    // Check location authorization
    func checkLocationAuthorization() {
        switch locationMG.authorizationStatus {
        case .authorizedWhenInUse, .authorizedAlways:
            print("Location access allowed.")
        case .denied:
            print("Location access denied.")
        case .notDetermined:
            locationMG.requestWhenInUseAuthorization()
        case .restricted:
            print("Location access restricted.")
        @unknown default:
            break
        }
    }

    // Start a timer when there is no movement
    func startNoMovementTimer() {
        noMovementTimer?.invalidate() // Invalidate the previous timer
        noMovementTimer = Timer.scheduledTimer(withTimeInterval: noMovementDuration, repeats: false) { [weak self] _ in
            self?.delegate?.showNoMovementAlert()
        }
    }

    // Stop the no-movement timer if the user starts moving again
    func stopNoMovementTimer() {
        noMovementTimer?.invalidate()
        noMovementTimer = nil
    }

    // Handle removing the treasure from the map
    func removeTreasureAnnotation(from mapView: MKMapView) {
        guard let treasureLocation = treasureLocation else { return }
        
        let treasureAnnotations = mapView.annotations.filter {
            $0.coordinate.latitude == treasureLocation.coordinate.latitude &&
            $0.coordinate.longitude == treasureLocation.coordinate.longitude
        }
        
        // Remove all matching annotations
        for annotation in treasureAnnotations {
            mapView.removeAnnotation(annotation)
        }
    }
    
    func checkForTreasureProximity() {
            // Your logic to check if the user is near the treasure
            let reachedTreasure = true // Example condition

            if reachedTreasure {
                delegate?.didReachTreasure()  // Notify the delegate
            }
        }
    // MARK: - CLLocationManagerDelegate
    
    // Called when location updates are received
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else { return }

        // Step 1: Calculate velocity (speed in meters/second)
        /*let velocity = location.speed >= 0 ? location.speed : 0*/ // Ensure no negative speeds
        let velocity = location.speed
        delegate?.didUpdateVelocity(velocity)

        // Step 2: Calculate distance remaining if navigating to a treasure
        if let treasure = treasureLocation {
            let distanceRemaining = location.distance(from: treasure)
            delegate?.didUpdateDistanceRemaining(distanceRemaining)

            // Step 3: Calculate time used and time remaining
            if let startTime = startTime {
                let currentTime = Date()
                let timeUsed = currentTime.timeIntervalSince(startTime) // Time used in seconds
                let timeRemaining = max(totalTimeLimit - timeUsed, 0) // Time remaining, ensure it's not negative

                delegate?.didUpdateTimeUsed(timeUsed)
                delegate?.didUpdateTimeRemaining(timeRemaining)

                // Step 4: If the user has reached the treasure (within 10 meters)
                if distanceRemaining <= 10 {
                    UserModel.shared.point += 10
                    delegate?.didReachTreasure()
                    toStoreVCdelegate?.didReachTreasure()
                    stopNoMovementTimer()
                    locationMG.stopUpdatingLocation()
                }
            }
        }

        // Step 5: Handle movement detection
        if velocity < -1.5 {
            startNoMovementTimer()
        } else {
            stopNoMovementTimer()
        }
    }

    // Called if location manager fails to get a location
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Location error: \(error.localizedDescription)")
    }
}
