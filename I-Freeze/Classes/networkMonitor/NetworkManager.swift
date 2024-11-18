import SwiftUI
import Network

class NetworkManager: ObservableObject {
    private let monitor = NWPathMonitor()
    private let queue = DispatchQueue(label: "Monitor")

    @Published var isWifiEnabled: Bool = false // Use @Published to notify SwiftUI of changes

    // Function to start monitoring Wi-Fi status
    func startMonitoring(completion: @escaping (Bool) -> Void) {
        monitor.pathUpdateHandler = { path in
            DispatchQueue.main.async {
                self.isWifiEnabled = path.usesInterfaceType(.wifi)
                completion(self.isWifiEnabled) // Return current status
            }
        }
        monitor.start(queue: queue)
    }

    // Function to stop monitoring
    func stopMonitoring() {
        monitor.cancel()
    }
}
