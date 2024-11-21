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
        guard let encodedDeviceId = storedDeviceId.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) else {
            print("Error: Failed to encode deviceId.")
            return
        }
        
        // Fetch or renew the token
        AuthService().fetchNewTokenIfNeeded(for: storedDeviceId) { [weak self] result in
            switch result {
            case .success(let token):
                // Construct the URL
                guard let url = URL(string: "https://security.flothers.com:8443/api/Devices/GetMobileConfigurations?mobileId=\(encodedDeviceId)") else {
                    print("Error: Invalid URL.")
                    return
                }
                print("Fetching configuration from URL: \(url)")
                
                // Create the request with the token
                var request = URLRequest(url: url)
                request.httpMethod = "GET"
                request.addValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
                request.addValue("application/json", forHTTPHeaderField: "Content-Type")
                
                // Start data task
                URLSession.shared.dataTask(with: request) { data, response, error in
                    guard let data = data, error == nil else {
                        print("Error fetching configuration: \(error?.localizedDescription ?? "Unknown error")")
                        return
                    }
                    
                    do {
                        if let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] {
                            print("Server response JSON: \(json)")
                            // Parse locationTracker, kioskMode, and other fields
                            if let data = json["data"] as? [String: Any],
                               let device = data["device"] as? [String: Any],
                               let serverLocationTracker = device["locationTracker"] as? Bool,
                               let serverKioskMode = device["kiosk"] as? Bool,
                               let whitelistWifi = device["whiteListWiFi"] as? Bool,
                               let blockWifi = device["blockWiFi"] as? Bool,
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
                                print("Error: Unable to retrieve configuration details from server response.")
                            }
                        }
                    } catch {
                        print("Error parsing JSON: \(error.localizedDescription)")
                    }
                }.resume()
                
            case .failure(let error):
                print("Error fetching token: \(error.localizedDescription)")
            }
        }
    }
    
    func sendLocationToServer(location: CLLocation, address: String, googleMapsURL: String) {
        // Load device ID from Keychain
        guard var deviceId = KeychainHelper.shared.load(key: "deviceId") else {
            print("Error: DeviceId not found in Keychain.")
            return
        }
        // Clean up deviceId by trimming whitespace and removing quotes
        deviceId = deviceId.trimmingCharacters(in: .whitespacesAndNewlines).replacingOccurrences(of: "\"", with: "")
        
        // Prepare the location data payload
        let locationData: [String: Any] = [
            "Location": googleMapsURL,
            "Address": address,
            "DeviceId": deviceId
        ]
        
        // Validate the API URL
        guard let url = URL(string: "https://security.flothers.com:8443/api/MobileLocation") else {
            print("Error: Invalid URL.")
            return
        }
        
        // Fetch or renew the token
        AuthService().fetchNewTokenIfNeeded(for: deviceId) { result in
            switch result {
            case .success(let token):
                var request = URLRequest(url: url)
                request.httpMethod = "POST"
                request.setValue("application/json", forHTTPHeaderField: "Content-Type")
                request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization") // Add the token to headers
                
                do {
                    // Serialize the location data into JSON
                    request.httpBody = try JSONSerialization.data(withJSONObject: locationData, options: [])
                } catch {
                    print("Error serializing JSON: \(error.localizedDescription)")
                    return
                }
                
                // Perform the POST request
                URLSession.shared.dataTask(with: request) { data, response, error in
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
                }.resume()
                
            case .failure(let error):
                print("Error fetching token: \(error.localizedDescription)")
            }
        }
    }
}
