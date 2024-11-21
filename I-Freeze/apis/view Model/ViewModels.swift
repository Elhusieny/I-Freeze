import Foundation
import SwiftUI
import Combine
class SettingViewModel: ObservableObject {
    @Published var isLocationTrackingEnabled = false
    
    private let deviceService = DataService.shared

    func loadDeviceSettings() {
        deviceService.fetchDeviceSettings { device in
            if let device = device {
                DispatchQueue.main.async {
                    self.isLocationTrackingEnabled = device.locationTracker
                }
            }
        }
    }
}

class LicenseActivationViewModel: ObservableObject {
    @Published var activationKey: String = ""
    @Published var activationMessage: String = ""
    @Published var showAlert: Bool = false
    @Published var navigateToHome: Bool = false
    @Published var isLicensed: Bool = UserDefaults.standard.bool(forKey: "isLicensed")
    
    func activateLicense(completion: @escaping (Bool) -> Void) {
        let deviceInfo = DeviceInfo.create() // Use the DeviceInfo model
        
        LicenseService.shared.activateLicense(with: activationKey, deviceInfo: deviceInfo) { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success(let deviceId):
                    KeychainHelper.shared.save(key: "deviceId", value: deviceId)
                    self?.activationMessage = "Activation Successful."
                    self?.isLicensed = true
                    UserDefaults.standard.set(true, forKey: "isLicensed")

                    completion(true) // Pass success
                case .failure:
                    self?.activationMessage = "Activation Failed"
                    completion(false) // Pass failure
                }
                self?.showAlert = true
            }
        }
    }
}

class ServerConfigViewModel: ObservableObject {
    @Published var locationTrackerEnabled: Bool = false
    @Published var kioskModeEnabled: Bool = false
    @Published var blockWifiEnabled: Bool = false
    @Published var whiteListWifiEnabled: Bool = false
    @Published var exceptionWifiList: [String] = []
    @Published var errorMessage: String?
    
    private var cancellables = Set<AnyCancellable>()
    
    // Fetch configuration and check if token needs to be refreshed
    func fetchConfiguration() {
        guard let deviceId = KeychainHelper.shared.load(key: "deviceId") else {
            errorMessage = "Device ID not found."
            return
        }
        
        // Check if the token is expired or not
        AuthService().fetchNewTokenIfNeeded(for: deviceId) { [weak self] result in
            switch result {
            case .success(let token):
                self?.fetchConfigurationFromAPI(deviceId: deviceId, token: token)
            case .failure(let error):
                DispatchQueue.main.async {
                    self?.errorMessage = "Failed to fetch token: \(error.localizedDescription)"
                }
            }
        }
    }
    
    // Function to fetch configuration data
    private func fetchConfigurationFromAPI(deviceId: String, token: String) {
        DataService.shared.fetchConfiguration(deviceId: deviceId, token: token) { [weak self] result in
            switch result {
            case .success(let response):
                DispatchQueue.main.async {
                    self?.locationTrackerEnabled = response.data.device.locationTracker
                    self?.kioskModeEnabled = response.data.device.kiosk
                    self?.blockWifiEnabled = response.data.device.blockWiFi
                    self?.whiteListWifiEnabled = response.data.device.whiteListWiFi
                    self?.exceptionWifiList = response.data.exceptionWifi ?? []
                }
            case .failure(let error):
                DispatchQueue.main.async {
                    self?.errorMessage = "Failed to fetch configuration: \(error.localizedDescription)"
                }
            }
        }
    }

    func sendLocationToServer(location: String, address: String) {
        guard let deviceId = KeychainHelper.shared.load(key: "deviceId") else {
            errorMessage = "Device ID not found."
            return
        }

        let locationData = LocationData(location: location, address: address, deviceId: deviceId)

        DataService.shared.sendLocationToServer(locationData: locationData) { [weak self] result in
            switch result {
            case .success:
                DispatchQueue.main.async {
                    print("Location sent to server successfully.")
                }
            case .failure(let error):
                DispatchQueue.main.async {
                    self?.errorMessage = "Failed to send location: \(error.localizedDescription)"
                }
            }
        }
    }
}
class AuthViewModel: ObservableObject {
    @Published var token: String?
    @Published var expiration: String?
    @Published var errorMessage: String?
    
    private let authService = AuthService()
    
    func fetchToken(deviceId: String, completion: @escaping (Bool) -> Void) {
        authService.fetchToken(for: deviceId) { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success(let response):
                    // Save the token in UserDefaults
                    UserDefaults.standard.set(response.token, forKey: "userToken")
                    UserDefaults.standard.set(response.expiration, forKey: "tokenExpiration")
                    
                    // Update the view model
                    self?.token = response.token
                    self?.expiration = response.expiration
                    
                    completion(true)
                case .failure(let error):
                    self?.errorMessage = error.localizedDescription
                    completion(false)
                }
            }
        }
    }
}
