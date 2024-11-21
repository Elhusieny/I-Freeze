import Foundation
import KeychainAccess
import Combine


class ConfigManager: ObservableObject {
    private var configCheckTimer: Timer?
    static let shared = ConfigManager()
    @Published var shouldSendLocation: Bool = false
    
    
    init() {
        startConfigPolling()
    }
    
    
    func startConfigPolling() {
        configCheckTimer = Timer.scheduledTimer(withTimeInterval: 30, repeats: true) {[weak self] _ in
            ServerManager.shared.fetchConfiguration()
        }
    }
    
    func fetchConfiguration() {
        guard let deviceId = KeychainHelper.shared.load(key: "deviceId") else { return }
    }
    
    func updateWhiteListWifi(_ serverWhiteListWifi: Bool) {
        if UserDefaults.standard.bool(forKey: "isWhiteListWifiEnabled") != serverWhiteListWifi {
            UserDefaults.standard.set(serverWhiteListWifi, forKey: "isWhiteListWifiEnabled")
            NotificationCenter.default.post(name: .whitelistWiFiChanged, object: serverWhiteListWifi)
        }
    }
    func updateBlockWifi(_ serverBlockWifi: Bool) {
        if UserDefaults.standard.bool(forKey: "isBlockWifiEnabled") != serverBlockWifi {
            UserDefaults.standard.set(serverBlockWifi, forKey: "isBlockWifiEnabled")
            NotificationCenter.default.post(name: .blockWifiChanged, object: serverBlockWifi)
        }
    }
    
    func updateKioskMode(_ serverKioskMode: Bool) {
        if UserDefaults.standard.bool(forKey: "isKioskModeEnabled") != serverKioskMode {
            UserDefaults.standard.set(serverKioskMode, forKey: "isKioskModeEnabled")
            NotificationCenter.default.post(name: .kioskModeChanged, object: serverKioskMode)
        }
    }
    
   
}
