

import SwiftUI
import CoreLocation


class LocationManager: NSObject, ObservableObject {
    private let locationManager = CLLocationManager()
    
    @Published var isLocationEnabled: Bool = false

    override init() {
        super.init()
        locationManager.delegate = self
        checkLocationAuthorization()
    }

    func checkLocationAuthorization() {
        switch locationManager.authorizationStatus {
        case .authorizedWhenInUse, .authorizedAlways:
            isLocationEnabled = true
        case .notDetermined:
            locationManager.requestWhenInUseAuthorization()
        case .restricted, .denied:
            isLocationEnabled = false
        @unknown default:
            break
        }
    }
}

extension LocationManager: CLLocationManagerDelegate {
    // Implement any necessary delegate methods here
}
