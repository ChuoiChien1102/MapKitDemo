//
//  MapViewDelegate.swift
//  MapKitQuestion2
//

//

import MapKit

extension CLLocationCoordinate2D: Equatable {
    public static func == (lhs: CLLocationCoordinate2D, rhs: CLLocationCoordinate2D) -> Bool {
        return lhs.latitude == rhs.latitude && lhs.longitude == rhs.longitude
    }
}

extension ViewController {
    
    // MKMapViewDelegate method to render polylines
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        if let polyline = overlay as? MKPolyline {
            let renderer = MKPolylineRenderer(polyline: polyline)
            renderer.strokeColor = UIColor.blue
            renderer.lineWidth = 5.0
            return renderer
        }
        return MKOverlayRenderer()
    }
    
    // Handle deselection of map annotations (e.g., treasures)
    func mapView(_ mapView: MKMapView, didDeselect view: MKAnnotationView) {
        // Remove the existing polyline overlay if any when a treasure is deselected
        if let currentPolyline = currentPolyline {
            mapView.removeOverlay(currentPolyline)
            self.currentPolyline = nil
        }

        // Invalidate the exploration timer when a treasure is deselected
        explorationTimerManager?.invalidateTimers()
        
        // Reset the selected treasure to nil (to track that no treasure is currently selected)
        selectedTreasure = nil
    }

    // Handle selection of map annotations (e.g., treasures)
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        guard let treasureLocation = view.annotation?.coordinate else { return }

        // Check if a different treasure is selected
        if selectedTreasure != treasureLocation {
            // Invalidate the current timer (if any) when a new treasure is selected
            explorationTimerManager?.invalidateTimers()

            // Set the selected treasure to the new treasure
            selectedTreasure = treasureLocation

            // Navigate to the selected treasure
            navigateToTreasure(treasureLocation)

            // Start or restart the exploration timer when a new treasure is selected
            explorationTimerManager?.resetTimer(newTimeLimit: timeLimit)
            explorationTimerManager?.startExplorationTimer()
        }
    }

    func navigateToTreasure(_ destination: CLLocationCoordinate2D) {
        guard let userLocation = locationManager.clLocationManager.location?.coordinate else {
            print("User location not available")
            return
        }
        
        let sourcePlacemark = MKPlacemark(coordinate: userLocation)
        let destinationPlacemark = MKPlacemark(coordinate: destination)
        
        let directionRequest = MKDirections.Request()
        directionRequest.source = MKMapItem(placemark: sourcePlacemark)
        directionRequest.destination = MKMapItem(placemark: destinationPlacemark)
        directionRequest.transportType = .walking
        
        let directions = MKDirections(request: directionRequest)
        directions.calculate { [weak self] (response, error) in
            guard let self = self else { return }
            guard let response = response else {
                print("Error calculating directions: \(error?.localizedDescription ?? "Unknown error")")
                return
            }
            let route = response.routes[0]
            
            // Remove any existing polyline overlay before adding a new one
            if let currentPolyline = self.currentPolyline {
                self.mapView.removeOverlay(currentPolyline)
            }
            
            // Add the new polyline overlay
            self.currentPolyline = route.polyline
            self.mapView.addOverlay(self.currentPolyline!)
        }
        func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
            if let polyline = overlay as? MKPolyline {
                let renderer = MKPolylineRenderer(polyline: polyline)
                renderer.strokeColor = UIColor.blue
                renderer.lineWidth = 5.0
                return renderer
            }
            return MKOverlayRenderer()
        }
    }
}

