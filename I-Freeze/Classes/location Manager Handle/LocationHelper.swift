import Foundation
import CoreLocation

class LocationHelper {
     static let shared = LocationHelper()
    private let geocoder = CLGeocoder()

     func reverseGeocodeLocation(location: CLLocation) {
        geocoder.reverseGeocodeLocation(location) { [weak self] placemarks, error in
            guard let self = self else { return }
            if let error = error {
                print("Error getting address: \(error.localizedDescription)")
                return
            }
            if let placemark = placemarks?.first {
                // Format the address components
                let address = [placemark.subThoroughfare, placemark.thoroughfare, placemark.locality, placemark.administrativeArea, placemark.country, placemark.postalCode]
                    .compactMap { $0 }
                    .joined(separator: ", ")
                
                // Google Maps URL with coordinates
                let googleMapsURL = "https://maps.google.com/maps/search/?api=1&query=\(location.coordinate.latitude),\(location.coordinate.longitude)"
                
                print("Address: \(address)")
                print("Google Maps URL: \(googleMapsURL)")
                
                ServerManager.shared.sendLocationToServer(location: location, address: address, googleMapsURL: googleMapsURL)
            } else {
                print("No address found.")
            }
        }
    }}
