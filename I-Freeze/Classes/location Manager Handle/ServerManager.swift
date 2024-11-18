import Foundation
import CoreLocation
import Combine
class ServerManager {
    // Singleton instance for centralized server communication
    static let shared = ServerManager()

    func fetchConfiguration() {
        // Retrieve the deviceId from Keychain
        guard var storedDeviceId = KeychainHelper.shared.load(key: "deviceId") else {
            print("Error: DeviceId not found in Keychain.")
            return
        }
        
        // Clean up deviceId by trimming whitespace and removing quotes
        storedDeviceId = storedDeviceId.trimmingCharacters(in: .whitespacesAndNewlines).replacingOccurrences(of: "\"", with: "")
        print("Cleaned DeviceId from Keychain: \(storedDeviceId)")
        
        // Ensure URL encoding for deviceId
        guard let encodedDeviceId = storedDeviceId.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed),
              let url = URL(string: "https://security.flothers.com:8443/api/Devices/GetMobileConfigurations?mobileId=\(encodedDeviceId)") else {
            print("Error: Invalid URL.")
            return
        }
        print("Fetching configuration from URL: \(url)")
        
        // Start data task to fetch configuration from the server
        URLSession.shared.dataTask(with: url) { [weak self] data, response, error in
            guard let data = data, error == nil else {
                print("Error fetching configuration: \(error?.localizedDescription ?? "Unknown error")")
                return
            }
            
            do {
                if let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] {
                    print("Server response JSON: \(json)")
                    // Parse locationTracker and kioskMode states
                    if let data = json["data"] as? [String: Any],
                       let device = data["device"] as? [String: Any],
                       let serverLocationTracker = device["locationTracker"] as? Bool,
                       let serverKioskMode = device["kiosk"] as? Bool,
                       let whitelistWifi = device["whiteListWiFi"] as? Bool ,
                       let blockWifi = device["blockWiFi"] as? Bool ,

                        let exceptionWifi = data["exceptionWifi"] as? [String] {
                        DispatchQueue.main.async {
                            LocationManager.shared.updateLocationTracking(serverLocationTracker)
                            ConfigManager.shared.updateKioskMode(serverKioskMode) // Sync Kiosk Mode
                            ConfigManager.shared.updateBlockWifi(blockWifi)
                            ConfigManager.shared.updateWhiteListWifi(whitelistWifi)
                            // Send exceptionWifi via NotificationCenter
                       NotificationCenter.default.post(name: .exceptionWifiChanged, object: exceptionWifi)
                   }

                    } else {
                        print("Error: Unable to retrieve locationTracker or kioskMode from server response.")
                    }
                    
                }
            } catch {
                print("Error parsing JSON: \(error.localizedDescription)")
            }
        }.resume()
    }
    func sendLocationToServer(location: CLLocation, address: String, googleMapsURL: String) {
        // Load device ID from Keychain
            guard var deviceId = KeychainHelper.shared.load(key: "deviceId") else {
                print("Error: DeviceId not found in Keychain.")
                return
            }
            // Clean up deviceId by trimming whitespace and removing quotes
            deviceId = deviceId.trimmingCharacters(in: .whitespacesAndNewlines).replacingOccurrences(of: "\"", with: "")
        let locationData: [String: Any] = [
            "Location": googleMapsURL,
            "Address": address,
            "DeviceId":deviceId
        ]
        print(deviceId)
        
        guard let url = URL(string: "https://security.flothers.com:8443/api/MobileLocation") else {
            print("Error: Invalid URL.")
            return
        }
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: locationData, options: [])
        } catch {
            print("Error serializing JSON: \(error.localizedDescription)")
            return
        }
        
        // Send the request
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            DispatchQueue.main.async {
                if let error = error {
                    print("Error sending location to server: \(error.localizedDescription)")
                } else if let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 {
                    print("Location sent to server successfully.")
                } else if let data = data, let responseString = String(data: data, encoding: .utf8) {
                    print("Failed to send location to server. Response: \(responseString)")
                } else {
                    print("Failed to send location to server. No response data.")
                }
            }
        }
        task.resume()
    }
}
