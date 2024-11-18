import SwiftUI
import UIKit
import Alamofire
struct PostAppNamesView: View {
    @State private var selectedApps: [String: Bool] = [:]
    @State private var showingAlert = false // Alert for sending app names
    @State private var alertMessage = "" // Custom alert message
    @State private var installedApps: [String] = [] // Dynamically populated installed apps
    
    // Predefined list of URL schemes to check installed apps
    let appsToCheck: [String: String] = [
        "fb://": "Facebook",
        "instagram://": "Instagram",
        "twitter://": "Twitter",
        "whatsapp://": "WhatsApp",
        "youtube://": "YouTube",
        "snapchat://": "Snapchat",
        "addressbook://": "Contacts"
    ]
    var body: some View {
        VStack(spacing: 15) {
            Text("Select Apps to Track")
                .font(.title2)
                .fontWeight(.bold)
            
            VStack {
                // List of apps with toggles
                List {
                    // Dynamically generated list of installed apps based on URL schemes
                    ForEach(installedApps, id: \.self) { app in
                        Toggle(isOn: Binding(
                            get: { selectedApps[app] ?? false },
                            set: {
                                selectedApps[app] = $0
                                saveSelectedApps()
                                
                                alertMessage = $0 ? "\(app) selected" : "\(app) deselected"
                                showingAlert = true
                            }
                        )) {
                            Text(app)
                                .foregroundColor(selectedApps[app] == true ? Color.blue : Color.black)
                                .accessibilityLabel("\(app) toggle")
                        }
                        .toggleStyle(SwitchToggleStyle(tint: Color.blue))
                    }
                }
                .listStyle(InsetGroupedListStyle())
            }
            
            // Button to send selected apps to the server
            Button(action: sendInstalledAppsToServer) {
                Text("Send Installed Apps")
                    .foregroundColor(.white)
                    .bold()
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.blue)
                    .cornerRadius(10)
                    .padding(.horizontal)
            }
        }
        .ignoresSafeArea()
        .padding(20)
        .alert(isPresented: $showingAlert) {
            Alert(title: Text("Status"), message: Text(alertMessage), dismissButton: .default(Text("OK")))
        }
        .onAppear {
            loadInstalledApps() // Automatically load installed apps when the view appears
            loadSavedData() // Load previously saved data (if any)
        }
    }
    
    // Dynamically load installed apps based on URL schemes
    private func loadInstalledApps() {
        installedApps = []
        
        for (scheme, appName) in appsToCheck {
            if let url = URL(string: scheme) {
                if UIApplication.shared.canOpenURL(url) {
                    installedApps.append(appName)
                    selectedApps[appName] = true // Automatically select installed apps
                } else {
                    print("Error: \(appName) not installed or scheme query blocked")
                }
            }
        }
    }
    // Send the installed apps to the server
    private func sendInstalledAppsToServer() {
        let selectedAppsList = installedApps.filter { selectedApps[$0] == true }
        
        guard !selectedAppsList.isEmpty else {
            alertMessage = "No apps selected"
            showingAlert = true
            return
        }
        
        sendAppInfoToServer(appNames: selectedAppsList)
    }
    
    // Makes an HTTP request to send app information to the server
    private func sendAppInfoToServer(appNames: [String]) {
        if var storedDeviceId = KeychainHelper.shared.load(key: "deviceId") {
            storedDeviceId = storedDeviceId.trimmingCharacters(in: .whitespacesAndNewlines)
            
            guard let url = URL(string: "https://yourserver.com/api/send_apps") else {
                alertMessage = "Invalid URL"
                showingAlert = true
                return
            }
            
            let appInfo: [String: Any] = [
                "installed_apps": appNames,
                "deviceId": storedDeviceId
            ]
            
            var request = URLRequest(url: url)
            request.httpMethod = "POST"
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
            
            do {
                let jsonData = try JSONSerialization.data(withJSONObject: appInfo, options: [])
                request.httpBody = jsonData
            } catch {
                alertMessage = "Error serializing JSON: \(error.localizedDescription)"
                showingAlert = true
                return
            }
            
            let task = URLSession.shared.dataTask(with: request) { data, response, error in
                if let error = error {
                    alertMessage = "Error: \(error.localizedDescription)"
                } else if let httpResponse = response as? HTTPURLResponse, (200...299).contains(httpResponse.statusCode) {
                    alertMessage = "App info sent successfully."
                } else {
                    alertMessage = "Failed to send app info. Status code: \(response as? HTTPURLResponse)?.statusCode ?? 0)"
                }
                
                DispatchQueue.main.async {
                    showingAlert = true
                }
            }
            task.resume()
        } else {
            alertMessage = "Device ID not found in Keychain"
            showingAlert = true
        }
    }
    
    // Saves the selected apps to UserDefaults
    private func saveSelectedApps() {
        let savedApps = selectedApps
        UserDefaults.standard.set(savedApps, forKey: "selectedApps")
    }
    
    // Loads saved data from UserDefaults
    private func loadSavedData() {
        if let savedSelectedApps = UserDefaults.standard.dictionary(forKey: "selectedApps") as? [String: Bool] {
            selectedApps = savedSelectedApps
        }
    }
    
}
struct PostAppNamesView_Previews: PreviewProvider {
    static var previews: some View {
        PostAppNamesView()
    }
}
