import Foundation
struct Utilities {
    static let BASE_URL = "https://security.flothers.com:8443/api/"

    private var deviceId: String? {
        return KeychainHelper.shared.load(key: "deviceId")
    }

    var fetchDeviceSettingsUrl: String {
        return "\(Utilities.BASE_URL)Devices/GetMobileConfigurations?mobileId=\(deviceId ?? "")"
    }
}
// Add this code anywhere in your project, typically in a utilities or constants file.
extension Notification.Name {
    static let locationTrackingChanged = NSNotification.Name("locationTrackingChanged")
    static let kioskModeChanged = Notification.Name("kioskModeChanged")
    static let  whitelistWiFiChanged = Notification.Name("whitelistWiFiChanged")
    static let exceptionWifiChanged = Notification.Name("exceptionWifiChanged")
    static let blockWifiChanged = Notification.Name("BlockWifiChanged")
    static let urlBlockingChanged = Notification.Name("urlBlockingChanged")


}


