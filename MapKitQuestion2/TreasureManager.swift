//
//  TreasureManager.swift
//  MapKitQuestion2
//
//

import MapKit
import CoreLocation

class TreasureManager {
    
    class Island {
        let geocoder = CLGeocoder()

        // Check if the given coordinate is on land using reverse geocoding
        func isLocationOnLand(coordinate: CLLocationCoordinate2D, completion: @escaping (Bool) -> Void) {
            let location = CLLocation(latitude: coordinate.latitude, longitude: coordinate.longitude)
            
            geocoder.reverseGeocodeLocation(location) { placemarks, error in
                if let error = error {
                    print("Reverse geocoding failed: \(error.localizedDescription)")
                    completion(false) // Assume it's water if geocoding fails
                    return
                }
                
                if let placemark = placemarks?.first {
                    // If there's a valid placemark with a country or locality, it's on land
                    if placemark.country != nil || placemark.locality != nil {
                        completion(true)
                    } else {
                        completion(false) // No country or locality means it's probably in water
                    }
                } else {
                    completion(false)
                }
            }
        }
    }

    var treasureLocations: [CLLocationCoordinate2D] = []
    let proximityThreshold: CLLocationDistance = 10.0
    let island = Island()
    
    // Hardcoded treasure coordinates
      let hardcodedTreasures = [
          CLLocationCoordinate2D(latitude: 37.31766889833659, longitude: -122.01343601587641),
          CLLocationCoordinate2D(latitude: 37.32936882185856, longitude: -122.02132529478507),
          CLLocationCoordinate2D(latitude: 37.32669934407651, longitude: -122.01939614348802),
          CLLocationCoordinate2D(latitude: 37.331631345379044, longitude: -122.01436602025738),
          CLLocationCoordinate2D(latitude: 37.33348979653727, longitude: -122.01819910546602)
      ]

      // Use hardcoded treasure locations
      func generateRandomTreasures(from userCoordinate: CLLocationCoordinate2D, mapView: MKMapView, completion: @escaping () -> Void) {
          treasureLocations.removeAll()
          mapView.removeAnnotations(mapView.annotations)

          for treasureCoordinate in hardcodedTreasures {
              treasureLocations.append(treasureCoordinate)
              
              let treasureAnnotation = MKPointAnnotation()
              treasureAnnotation.coordinate = treasureCoordinate
              treasureAnnotation.title = "Treasure"
              mapView.addAnnotation(treasureAnnotation)
              
              print("Treasure Location: Latitude: \(treasureCoordinate.latitude), Longitude: \(treasureCoordinate.longitude)")
          }
          
          completion()
      }
  }


//    // Asynchronous treasure generation that avoids water areas
//      func generateRandomTreasures(from userCoordinate: CLLocationCoordinate2D, mapView: MKMapView, completion: @escaping () -> Void) {
//          treasureLocations.removeAll()
//          mapView.removeAnnotations(mapView.annotations)
//
//          generateTreasureRecursively(count: 5, userCoordinate: userCoordinate, mapView: mapView, completion: completion)
//      }
//
//      // Recursive function to generate treasures asynchronously
//      private func generateTreasureRecursively(count: Int, userCoordinate: CLLocationCoordinate2D, mapView: MKMapView, completion: @escaping () -> Void) {
//          guard count > 0 else {
//              // Print all treasure locations to the console
//              for treasure in treasureLocations {
//                  print("Treasure Location: Latitude: \(treasure.latitude), Longitude: \(treasure.longitude)")
//              }
//              completion()
//              return
//          }
//
//          let randomLat = userCoordinate.latitude + Double.random(in: -0.01...0.01)
//          let randomLong = userCoordinate.longitude + Double.random(in: -0.01...0.01)
//          let treasureCoordinate = CLLocationCoordinate2D(latitude: randomLat, longitude: randomLong)
//
//          // Check if the treasure is on land
//          island.isLocationOnLand(coordinate: treasureCoordinate) { [weak self] isLand in
//              guard let self = self else { return }
//              if isLand {
//                  self.treasureLocations.append(treasureCoordinate)
//
//                  let treasureAnnotation = MKPointAnnotation()
//                  treasureAnnotation.coordinate = treasureCoordinate
//                  treasureAnnotation.title = "Treasure"
//                  mapView.addAnnotation(treasureAnnotation)
//              }
//
//              // Recursively generate the next treasure
//              self.generateTreasureRecursively(count: count - 1, userCoordinate: userCoordinate, mapView: mapView, completion: completion)
//          }
//      }
//  }
