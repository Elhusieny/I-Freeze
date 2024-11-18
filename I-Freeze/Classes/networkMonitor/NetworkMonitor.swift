import Foundation
import Network
import Combine
import SystemConfiguration.CaptiveNetwork

class NetworkMonitor: ObservableObject {
     var monitor: NWPathMonitor
     var monitorQueue: DispatchQueue
    
    @Published var isWiFiConnected: Bool = false
    @Published var currentSSID: String = ""
    //Checks if Wi-Fi is connected, and if so, retrieves the current Wi-Fi SSID using the CaptiveNetwork API.
    init() {
        //The SSID is updated whenever there’s a change in Wi-Fi connection status, storing it in the currentSSID variable.
        monitor = NWPathMonitor()
        monitorQueue = DispatchQueue(label: "NetworkMonitorQueue")
        monitor.pathUpdateHandler = { [weak self] path in
            DispatchQueue.main.async {
                if path.status == .satisfied && path.usesInterfaceType(.wifi) {
                    self?.isWiFiConnected = true
                    self?.currentSSID = self?.getCurrentSSID() ?? ""
                    print("Wi-Fi connected. SSID: \(self?.currentSSID ?? "Unknown")")  // Log when connected to Wi-Fi
                } else {
                    self?.isWiFiConnected = false
                    self?.currentSSID = ""
                    print("Wi-Fi not connected.")  // Log if Wi-Fi is not connected
                }
            }
        }

        monitor.start(queue: monitorQueue)
    }
    //
    private func getCurrentSSID() -> String {
        guard let interfaceNames = CNCopySupportedInterfaces() as? [String] else {
            return ""  // Return empty string if no interfaces are found
        }
        
        for interfaceName in interfaceNames {
            if let networkInfo = CNCopyCurrentNetworkInfo(interfaceName as CFString) as? [String: Any],
               let ssid = networkInfo[kCNNetworkInfoKeySSID as String] as? String {
                return ssid
            }
        }
        
        return ""  // Return empty string if SSID is not found
    }

}
