import UserNotifications
import SwiftUI

class NotificationManager: NSObject, ObservableObject {
    @Published var isNotificationEnabled: Bool = false

    override init() {
        super.init()
        checkNotificationAuthorization()
    }

    func checkNotificationAuthorization() {
        UNUserNotificationCenter.current().getNotificationSettings { settings in
            DispatchQueue.main.async {
                self.isNotificationEnabled = (settings.authorizationStatus == .authorized)
            }
        }
    }

    func requestNotificationPermission(completion: @escaping (Bool) -> Void) {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
            if let error = error {
                print("Error requesting notification permission: \(error.localizedDescription)")
            }
            self.checkNotificationAuthorization()
            completion(granted)
        }
    }

    func openSettings() {
        if let url = URL(string: UIApplication.openSettingsURLString) {
            UIApplication.shared.open(url)
        }
    }
}
