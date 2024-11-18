import Foundation
import CoreLocation
import Combine
class LocationManager: NSObject, ObservableObject, CLLocationManagerDelegate {
    private let locationManager = CLLocationManager()
    private var locationUpdateTimer: Timer?
    private var configCheckTimer: Timer?
    @Published var isLocationEnabled: Bool = false
    @Published var currentLocation: CLLocation?
    @Published var shouldSendLocation: Bool = false
    static let shared = LocationManager()

    override init() {
        super.init()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        checkLocationAuthorization()
        startConfigPolling()
    }

    func startConfigPolling() {
        configCheckTimer = Timer.scheduledTimer(withTimeInterval: 30, repeats: true) { [weak self] _ in
            ServerManager.shared.fetchConfiguration()
        }
    }
   
    
   

    func updateLocationTracking(_ serverLocationTracker: Bool) {
        if shouldSendLocation != serverLocationTracker {
            shouldSendLocation = serverLocationTracker
            UserDefaults.standard.set(shouldSendLocation, forKey: "isTrackingEnabled")
            if shouldSendLocation {
                startLocationUpdates()
            } else {
                stopLocationUpdates()
            }
        }
        
    }

    func requestLocationPermission() {
        locationManager.requestWhenInUseAuthorization()
    }

    func checkLocationAuthorization() {
        switch locationManager.authorizationStatus {
        case .authorizedWhenInUse, .authorizedAlways:
            isLocationEnabled = true
            if shouldSendLocation {
                startLocationUpdates()
            }
        case .notDetermined:
            locationManager.requestWhenInUseAuthorization()
        case .restricted, .denied:
            isLocationEnabled = false
        @unknown default:
            break
        }
    }

    func startLocationUpdates() {
        locationManager.allowsBackgroundLocationUpdates = true
        locationManager.pausesLocationUpdatesAutomatically = false
        locationManager.startUpdatingLocation()

        // Start the timer for periodic location updates
        locationUpdateTimer = Timer.scheduledTimer(withTimeInterval: 20, repeats: true) { [weak self] _ in
            self?.sendCurrentLocation()
        }
   }

    func stopLocationUpdates() {
        locationManager.stopUpdatingLocation()
        locationUpdateTimer?.invalidate()
        locationUpdateTimer = nil
    }

    private func sendCurrentLocation() {
        guard shouldSendLocation, let location = currentLocation else { return }
        LocationHelper.shared.reverseGeocodeLocation(location: location)
    }

    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        currentLocation = locations.last
    }

    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        checkLocationAuthorization()
    }
}
