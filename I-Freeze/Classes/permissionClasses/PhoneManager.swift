import Contacts

class PhoneManager: NSObject, ObservableObject {
    @Published var isPhoneAccessEnabled: Bool = false
    var onPermissionGranted: (() -> Void)?
    var onPermissionDenied: (() -> Void)? // Callback for denied permission

    override init() {
        super.init()
        checkPhoneAuthorization()
    }
    
    func checkPhoneAuthorization() {
        let status = CNContactStore.authorizationStatus(for: .contacts)
        DispatchQueue.main.async {
            self.isPhoneAccessEnabled = (status == .authorized)
            if self.isPhoneAccessEnabled {
                self.onPermissionGranted?() // Notify that permission is granted
            } else if status == .denied {
                self.onPermissionDenied?() // Notify that permission is denied
            }
        }
    }
    
    func requestPhonePermission() {
        let status = CNContactStore.authorizationStatus(for: .contacts)
        if status == .denied {
            onPermissionDenied?() // Notify that permission is denied
        } else {
            CNContactStore().requestAccess(for: .contacts) { granted, error in
                if let error = error {
                    print("Error requesting phone permission: \(error.localizedDescription)")
                }
                DispatchQueue.main.async {
                    self.checkPhoneAuthorization() // Check status after request
                }
            }
        }
    }
}
