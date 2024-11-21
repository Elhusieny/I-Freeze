import Foundation
import Alamofire

class DataService {
    static let shared = DataService()
    private init() {} // Prevent initialization from other places

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
    
        
        // Function to fetch device configuration data
        func fetchConfiguration(deviceId: String, token: String, completion: @escaping (Result<DeviceResponse, Error>) -> Void) {
            guard let encodedDeviceId = deviceId.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed),
                  let url = URL(string: "https://security.flothers.com:8443/api/Devices/GetMobileConfigurations?mobileId=\(encodedDeviceId)") else {
                completion(.failure(NSError(domain: "DataService", code: 400, userInfo: [NSLocalizedDescriptionKey: "Invalid URL"])))
                return
            }
            
            let headers: HTTPHeaders = [
                "Authorization": "Bearer \(token)",
                "Content-Type": "application/json"
            ]
            
            AF.request(url, method: .get, headers: headers)
                .validate()
                .responseDecodable(of: DeviceResponse.self) { response in
                    switch response.result {
                    case .success(let data):
                        completion(.success(data))
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

class AuthService {
    // Check if the token is expired
    func isTokenExpired() -> Bool {
        guard let expiration = UserDefaults.standard.value(forKey: "tokenExpiration") as? TimeInterval else {
            return true // If no expiration is found, assume it's expired
        }
        return Date().timeIntervalSince1970 > expiration
    }

    // Fetch a new token if expired
    func fetchNewTokenIfNeeded(for deviceId: String, completion: @escaping (Result<String, Error>) -> Void) {
        if isTokenExpired() {
            print("Token expired. Fetching new token.")
            fetchToken(for: deviceId) { result in
                switch result {
                case .success(let tokenResponse):
                    completion(.success(tokenResponse.token))
                case .failure(let error):
                    completion(.failure(error))
                }
            }
        } else {
            // Token is still valid, fetch the token from UserDefaults
            if let token = UserDefaults.standard.string(forKey: "userToken") {
                completion(.success(token))
            } else {
                completion(.failure(NSError(domain: "AuthService", code: 1, userInfo: [NSLocalizedDescriptionKey: "Token not found."])))
            }
        }
    }

    // Fetch the token from API and store it
    func fetchToken(for deviceId: String, completion: @escaping (Result<TokenResponse, Error>) -> Void) {
        // API URL
        let url = "https://security.flothers.com:8443/api/Account/iFreezeLogin/\(deviceId)"
        
        // Making the request and decoding the response into TokenResponse
        AF.request(url, method: .get)
            .responseDecodable(of: TokenResponse.self) { response in
                switch response.result {
                case .success(let tokenResponse):
                    // Save the token in UserDefaults
                    UserDefaults.standard.set(tokenResponse.token, forKey: "userToken")
                    UserDefaults.standard.set(tokenResponse.expiration, forKey: "tokenExpiration")
                    completion(.success(tokenResponse))
                case .failure(let error):
                    completion(.failure(error))
                }
            }
    }
}
