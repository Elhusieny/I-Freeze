import Foundation
import Photos // Import Photos framework
import Combine

class PhotoManager: NSObject, ObservableObject {
    @Published var isPhotoAccessEnabled: Bool = false

    override init() {
        super.init()
        checkPhotoAuthorization()
    }

    func checkPhotoAuthorization() {
        let status = PHPhotoLibrary.authorizationStatus()
        DispatchQueue.main.async {
            self.isPhotoAccessEnabled = (status == .authorized)
        }
    }

    func requestPhotoPermission() {
        PHPhotoLibrary.requestAuthorization { status in
            DispatchQueue.main.async {
                self.isPhotoAccessEnabled = (status == .authorized)
            }
        }
    }
}
