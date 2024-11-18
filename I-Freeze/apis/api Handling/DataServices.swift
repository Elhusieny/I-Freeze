import Foundation
import Alamofire

class DataService {
    static let shared = DataService()

    // Function to fetch device settings
    func fetchDeviceSettings(completion: @escaping (Device?) -> Void) {
        let url = Utilities().fetchDeviceSettingsUrl
        AF.request(url).responseDecodable(of: DeviceResponse.self) { response in
            switch response.result {
            case .success(let deviceResponse):
                completion(deviceResponse.data.device)
            case .failure(let error):
                print("Error fetching device settings: \(error)")
                completion(nil)
            }
        }
    }
    
    // Function to fetch configuration using a specific device ID
    func fetchConfiguration(deviceId: String, completion: @escaping (Result<DeviceResponse, Error>) -> Void) {
        guard let encodedDeviceId = deviceId.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed),
              let url = URL(string: "https://security.flothers.com:8443/api/Devices/GetMobileConfigurations?mobileId=\(encodedDeviceId)") else {
            print("Error: Invalid URL.")
            return
        }

        AF.request(url)
            .validate()
            .responseDecodable(of: DeviceResponse.self) { response in
                switch response.result {
                case .success(let config):
                    completion(.success(config))
                case .failure(let error):
                    completion(.failure(error))
                }
            }
    }

    // Function to send location data to the server
    func sendLocationToServer(locationData: LocationData, completion: @escaping (Result<Void, Error>) -> Void) {
        guard let url = URL(string: "https://security.flothers.com:8443/api/MobileLocation") else {
            print("Error: Invalid URL.")
            return
        }

        AF.request(url, method: .post, parameters: locationData, encoder: JSONParameterEncoder.default)
            .validate()
            .response { response in
                switch response.result {
                case .success:
                    completion(.success(()))
                case .failure(let error):
                    completion(.failure(error))
                }
            }
    }
}

// LicenseService.swift

class LicenseService {
    static let shared = LicenseService()
    
    private init() {}
    
    func activateLicense(with licenseKey: String, deviceInfo: DeviceInfo, completion: @escaping (Result<String, Error>) -> Void) {
       
        let urlString = "\(Utilities.BASE_URL)Licenses/ActivateMobile/\(licenseKey)"
        
        AF.request(
            urlString,
            method: .post,
            parameters: deviceInfo,
            encoder: JSONParameterEncoder.default, // Automatically encodes the model as JSON
            headers: ["Content-Type": "application/json"]
        ).responseString { response in
            switch response.result {
            case .success(let deviceId):
                completion(.success(deviceId.trimmingCharacters(in: .whitespacesAndNewlines)))
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
}

