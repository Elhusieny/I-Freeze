import SwiftUI
import UIKit

class DocumentManager: NSObject, ObservableObject {
    @Published var isDocumentAccessEnabled: Bool = false
    var selectedFiles: [URL] = [] // Store selected file URLs
    @State private var showAlert = false
    @State private var alertMessage = ""
    
    func checkDocumentAuthorization() {
        // You can implement logic here if needed to check for document access.
        isDocumentAccessEnabled = true // Assume access for this example.
    }
    
    func presentDocumentPicker() {
        let documentPicker = UIDocumentPickerViewController(forOpeningContentTypes: [.item], asCopy: true)
        documentPicker.delegate = self
        documentPicker.modalPresentationStyle = .formSheet
        
        // Present the document picker from the appropriate view controller.
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let rootVC = windowScene.windows.first?.rootViewController {
            rootVC.present(documentPicker, animated: true, completion: nil)
        }
    }
    
    func scanSelectedFiles() {
            for fileURL in selectedFiles {
                // Check the file type
                let fileExtension = fileURL.pathExtension.lowercased()
                var scanResult = "Scanning file: \(fileURL.lastPathComponent)"
                
                // Check for specific file types (e.g., images, documents)
                if fileExtension == "jpg" || fileExtension == "png" {
                    scanResult += " - Image file detected."
                } else if fileExtension == "pdf" {
                    scanResult += " - PDF file detected."
                } else if fileExtension == "txt" {
                    scanResult += " - Text file detected."
                    // Read content and check for specific keywords
                    if let content = try? String(contentsOf: fileURL) {
                        if content.contains("malware") {
                            scanResult += " - Malware keyword found!"
                        } else {
                            scanResult += " - No issues found."
                        }
                    }
                } else {
                    scanResult += " - Unsupported file type."
                }
                
                // Update the alert message
                alertMessage += scanResult + "\n"
            }
            showAlert = true // Show the alert after scanning
        }
    }

extension DocumentManager: UIDocumentPickerDelegate {
    func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
        selectedFiles = urls // Store selected file URLs
        scanSelectedFiles()   // Call the scanning function
    }
    
    func documentPickerWasCancelled(_ controller: UIDocumentPickerViewController) {
        print("Document picker was cancelled.")
    }
}
