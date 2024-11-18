import Foundation
import SwiftUI
import Combine
class SettingViewModel: ObservableObject {
    @Published var isLocationTrackingEnabled = false
    
    private let deviceService = DataService()
    
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
    
    func activateLicense() {
        let deviceInfo = DeviceInfo.create() // Use the DeviceInfo model
        
        LicenseService.shared.activateLicense(with: activationKey, deviceInfo: deviceInfo) { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success(let deviceId):
                    KeychainHelper.shared.save(key: "deviceId", value: deviceId)
                    self?.activationMessage = "Activation Successful."
                    self?.isLicensed = true
                    UserDefaults.standard.set(true, forKey: "isLicensed")
                   // self?.navigateToHome = true
                case .failure:
                    self?.activationMessage = "Activation Failed"
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

    func fetchConfiguration() {
        guard let deviceId = KeychainHelper.shared.load(key: "deviceId") else {
            errorMessage = "Device ID not found."
            return
        }

        DataService.shared.fetchConfiguration(deviceId: deviceId) { [weak self] result in
            switch result {
            case .success(let response):
                DispatchQueue.main.async {
                    self?.locationTrackerEnabled = response.data.device.locationTracker
                    self?.kioskModeEnabled = response.data.device.kiosk
                    self?.blockWifiEnabled = response.data.device.blockWiFi
                    self?.whiteListWifiEnabled = response.data.device.whiteListWiFi
                    self?.exceptionWifiList = response.data.exceptionWifi!
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
