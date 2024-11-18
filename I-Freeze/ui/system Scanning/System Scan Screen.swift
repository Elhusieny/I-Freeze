import SwiftUI
import LocalAuthentication

struct SystemScanScreen: View {
    @StateObject private var documentManager = DocumentManager()
    @State private var showAlert = false
    @State private var alertMessage = ""
    @State private var showSettingsAlert = false // New state variable for showing settings alert
    @State private var filesToDelete: [String] = [] // Array to hold the names of files to delete
       @State private var filesForDeletion: [String] = [] // Array to hold selected files for deletion
       @State private var tempFilesToDelete: [String] = [] // Array to hold temporary files

    var body: some View {
        ZStack {
            Color.darkBlue
                    .ignoresSafeArea()
            VStack {
                // Top Section with Image and Text
                topSection

                Spacer()

                // Main Section with Scanning Options
                mainSection

                Spacer()
            }
            .padding(.bottom, 20)

            // Custom alert view
            if showSettingsAlert {
                SettingsAlertView(message: alertMessage, showAlert: $showSettingsAlert)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .background(Color.black.opacity(0.4)) // Background overlay
            }
        }
        .alert(isPresented: $showAlert) {
            Alert(title: Text("Scan Results"), message: Text(alertMessage), dismissButton: .default(Text("OK")))
        }
        .navigationTitle("System Scan")
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden(true)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                BackButton() // Assuming you have a BackButton view defined
            }
        }
    }

    private var topSection: some View {
        VStack {
            Image("protectedLogo")
                .resizable()
                .scaledToFit()
                .frame(width: 120, height: 120) // Slightly larger logo
                .padding(.top, 40)
                .background(Color.darkBlue)

            Text("You are Protected!")
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(.white)
                .padding(.bottom, 20)
        }
        .frame(maxWidth: .infinity)
        .cornerRadius(15)
        .padding(.horizontal, 20)
    }

    private var mainSection: some View {
        VStack(spacing: 16) {
            // Button to Scan Files
            PermissionButton(title: "Scan Files", icon: "doc", description: "Choose files to scan.", iconColor: Color.green) {
                scanFilesAction()
            }

            // Button to Scan Mobile Settings
            PermissionButton(title: "Scan Mobile Settings", icon: "gear", description: "Check your mobile settings.", iconColor: Color.yellow) {
                scanMobileSettings()
            }

            // New System Cleanup Button
            PermissionButton(title: "System Cleanup", icon: "trash", description: "Clean unnecessary files.", iconColor: Color.red) {
                performSystemCleanup()
            }
            

            // Navigation Button to SecurityScreen
            NavigationButton(title: "Go to Security Screen", description: "Scan your security settings.", destination: SecurityScreen(),imageName: "chevron.right",buttonColor: .blue.opacity(0.3))
        }
        .padding(.horizontal, 20)
        .padding(.top, 20)
    }

    func scanFilesAction() {
        documentManager.checkDocumentAuthorization()
        if documentManager.isDocumentAccessEnabled {
            documentManager.presentDocumentPicker()
        } else {
            alertMessage = "Document access is not enabled. Please allow access in settings."
            showAlert = true
        }
    }

    func scanMobileSettings() {
        var scanResults: [String] = []

        if isDeviceJailbroken() {
            scanResults.append("🚨 Warning: Device may be  jailbroken.")
        } else {
            scanResults.append("✅ Device is not jailbroken.")
        }

        if isDeveloperModeEnabled() {
            scanResults.append("⚠️ Developer Mode is enabled.")
        } else {
            scanResults.append("✅ Developer Mode is disabled.")
        }

        if hasUntrustedAppsInstalled() {
            scanResults.append("🚨 Warning: Untrusted apps detected.")
        } else {
            scanResults.append("✅ No untrusted apps detected.")
        }

        if isPasscodeSet() {
            scanResults.append("✅ Device lock screen is secured with a passcode.")
        } else {
            scanResults.append("🚨 Warning: Device lock screen is not secured with a passcode.")
        }

        let systemVersion = UIDevice.current.systemVersion
        scanResults.append("iOS version: \(systemVersion)")

        // Format the alert message with line breaks
           let formattedMessage = scanResults.map { "  \($0)" }.joined(separator: "\n") // Add leading spaces for indentation
           alertMessage = formattedMessage
        alertMessage = scanResults.joined(separator: "\n")
        showSettingsAlert = true // This will now present the custom alert
    }

  
    // Function to detect potential jailbreak indicators
    func isDeviceJailbroken() -> Bool {
        let jailbreakIndicators = ["/Applications/Cydia.app", "/Library/MobileSubstrate/MobileSubstrate.dylib", "/bin/bash", "/usr/sbin/sshd", "/etc/apt"]
        
        for path in jailbreakIndicators {
            if FileManager.default.fileExists(atPath: path) {
                return true
            }
        }
        
        let testPath = "/private/jailbreak_test.txt"
        do {
            try "Jailbreak Test".write(toFile: testPath, atomically: true, encoding: .utf8)
            try FileManager.default.removeItem(atPath: testPath)
            return true
        } catch {
            return false
        }
    }

    func isDeveloperModeEnabled() -> Bool {
        return false // Placeholder for future implementation
    }

    func hasUntrustedAppsInstalled() -> Bool {
        let untrustedPaths = ["/User/Applications/", "/private/var/lib/apt/", "/private/var/stash/"]
        for path in untrustedPaths {
            if FileManager.default.fileExists(atPath: path) {
                return true
            }
        }
        return false
    }

    func isPasscodeSet() -> Bool {
        let context = LAContext()
        return context.canEvaluatePolicy(.deviceOwnerAuthentication, error: nil)
    }
   
    // Function to perform system cleanup
    func performSystemCleanup() {
        filesToDelete = fetchCacheFiles() // Get cached files to show to the user
        tempFilesToDelete = fetchTemporaryFiles() // Get temporary files to show to the user

        // Show alert if there are any files to delete
        if !filesToDelete.isEmpty || !tempFilesToDelete.isEmpty {
            showAlert = true
        } else {
            alertMessage = "No files to delete."
            showAlert = true
        }
    }

    // Function to fetch cache files
    func fetchCacheFiles() -> [String] {
        let cacheURLs = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask)
        guard let cacheURL = cacheURLs.first else {
            print("Cache directory not found.")
            return []
        }

        do {
            let cachedFiles = try FileManager.default.contentsOfDirectory(at: cacheURL, includingPropertiesForKeys: nil)
            return cachedFiles.map { $0.lastPathComponent } // Return just the file names
        } catch {
            print("Failed to fetch cache files: \(error.localizedDescription)")
            return []
        }
    }

    // Function to fetch temporary files
    func fetchTemporaryFiles() -> [String] {
        let tempURL = FileManager.default.temporaryDirectory
        do {
            let tempFiles = try FileManager.default.contentsOfDirectory(at: tempURL, includingPropertiesForKeys: nil)
            return tempFiles.map { $0.lastPathComponent } // Return just the file names
        } catch {
            print("Failed to fetch temporary files: \(error.localizedDescription)")
            return []
        }
    }

    // Function to delete files
    func deleteFiles() {
        let cacheURLs = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask)
        guard let cacheURL = cacheURLs.first else {
            print("Cache directory not found.")
            return
        }

        // Delete cached files
        for fileName in filesToDelete {
            let fileURL = cacheURL.appendingPathComponent(fileName)
            do {
                try FileManager.default.removeItem(at: fileURL)
                print("Removed cached file: \(fileName)")
            } catch {
                print("Failed to delete cached file: \(fileName), error: \(error.localizedDescription)")
            }
        }

        // Delete temporary files
        let tempURL = FileManager.default.temporaryDirectory
        for fileName in tempFilesToDelete {
            let fileURL = tempURL.appendingPathComponent(fileName)
            do {
                try FileManager.default.removeItem(at: fileURL)
                print("Removed temporary file: \(fileName)")
            } catch {
                print("Failed to delete temporary file: \(fileName), error: \(error.localizedDescription)")
            }
        }

        alertMessage = "Selected files deleted successfully!"
        showSettingsAlert = true // Show success alert
    }
}


// Custom Button Style with Description
struct PermissionButton: View {
    let title: String
    let icon: String
    let description: String
    let iconColor: Color
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack {
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(title)
                            .font(.title3)
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                        Text(description)
                            .font(.subheadline)
                            .foregroundColor(.white.opacity(0.8))
                            .padding(.leading, 20)
                    }
                    Spacer()
                    Image(systemName: icon)
                        .resizable()
                        .frame(width: 24, height: 24)
                        .foregroundColor(iconColor) // Set icon color
                        .padding(10)
                        .background(Circle().fill(Color.white)) // Semi-transparent background for the icon
                } .padding()
                    .frame(maxWidth: .infinity)  // Makes the button expand to full width
                    .background(
                        LinearGradient(
                            gradient: Gradient(colors: [Color.darkBlue, Color.blue.opacity(0.7)]),
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .cornerRadius(10)
                    .shadow(color: Color.black.opacity(0.2), radius: 5, x: 0, y: 2)
                }
            }
        }
    }


// NavigationButton Component with Custom Style
struct NavigationButton<Destination: View>: View {
    let title: String
    let description: String
    let destination: Destination
    let imageName: String
    let buttonColor: Color // Add customizable button color

    var body: some View {
        NavigationLink(destination: destination) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(title)
                        .font(.title3)
                        .fontWeight(.semibold)
                        .foregroundColor(.white)
                    
                    Text(description)
                        .font(.subheadline)
                        .foregroundColor(.white.opacity(0.8))
                        .padding(.leading,10)
                }
                Spacer()
                
                Image(systemName: imageName)
                    .resizable()
                    .frame(width: 20, height: 20)
                    .foregroundColor(.blue.opacity(0.9))
                    .padding(12)
                    .background(Circle().fill(Color.white))
            }
            .padding()
            .frame(maxWidth: .infinity)  // Makes the button expand to full width
            .background(
                LinearGradient(
                    gradient: Gradient(colors: [Color.darkBlue, Color.blue.opacity(0.7)]),
                    startPoint: .leading,
                    endPoint: .trailing))
            .cornerRadius(10)
            .shadow(color: Color.black.opacity(0.2), radius: 5, x: 0, y: 2)
        }
    }
}
// Preview Provider
struct SystemScanScreen_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack {
            SystemScanScreen()
        }
    }
}

// Custom alert view for displaying scan results
struct SettingsAlertView: View {
    let message: String
    @Binding var showAlert: Bool

    var body: some View {
        VStack(spacing: 20) {
            Text("Scan Results")
                .font(.title2)
                .fontWeight(.bold)
                .padding(.top)

            Text("Here are the results of your scan:")
                .font(.headline)
                .foregroundColor(.gray)

            // Main message formatted as a list
            VStack(alignment: .leading, spacing: 8) {
                ForEach(message.components(separatedBy: "\n"), id: \.self) { line in
                    HStack(spacing: 8) { // HStack to hold the icon and text
                        if line.contains("✅") { // Check for a success icon
                            Image(systemName: "checkmark.circle.fill") // Success icon
                                .resizable()
                                .frame(width: 20, height: 20) // Adjust size
                                .foregroundColor(.green)
                        } else if line.contains("🚨") { // Check for a warning icon
                            Image(systemName: "exclamationmark.triangle.fill") // Warning icon
                                .resizable()
                                .frame(width: 20, height: 20) // Adjust size
                                .foregroundColor(.red)
                        } else {
                            Image(systemName: "info.circle") // Default info icon
                                .resizable()
                                .frame(width: 20, height: 20) // Adjust size
                                .foregroundColor(.blue)
                        }
                        
                        Text(line.replacingOccurrences(of: "✅", with: "").replacingOccurrences(of: "🚨", with: "").trimmingCharacters(in: .whitespaces))
                            .font(.title3)
                            .multilineTextAlignment(.leading)
                            .foregroundColor(.black)
                    }
                }
            }
            .padding(.horizontal)

            // Button stack
            HStack(spacing: 20) {
                // Button to Open Settings
                Button(action: openSettings) {
                    Text("Open Settings")
                        .fontWeight(.bold)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(
                            Capsule()
                                .fill(LinearGradient(gradient: Gradient(colors: [Color.blue, Color.blue.opacity(0.7)]), startPoint: .top, endPoint: .bottom))
                        )
                        .foregroundColor(.white)
                }
                
                // Dismiss Button
                Button(action: {
                    showAlert = false // Dismiss the alert
                }) {
                    Text("OK")
                        .fontWeight(.bold)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.gray.opacity(0.2))
                        .cornerRadius(10)
                }
            }
            .padding(.horizontal)
        }
        .padding()
        .frame(maxWidth:.infinity)
        .background(RoundedRectangle(cornerRadius: 15).fill(Color.white))
        .shadow(radius: 20)
        .padding()
    }
    
    // Function to open the Settings app
    private func openSettings() {
        if let url = URL(string: UIApplication.openSettingsURLString) {
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
        }
    }
}
