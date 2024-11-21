import SwiftUI
struct NetworkControl: View {
    @State private var isWiFiBlocked = UserDefaults.standard.bool(forKey: "isBlockWifiEnabled")
    @State private var isWiFiWhitelisted = UserDefaults.standard.bool(forKey: "isWhiteListWifiEnabled")
    @State private var newSSID = ""
    @State private var whitelistedSSIDs: [String] = []
    @State private var alertMessage: String = ""
    @State private var showAlert: Bool = false
    @StateObject private var networkMonitor = NetworkMonitor()

    var body: some View {
        NavigationStack {
            ZStack(alignment: .top) {
                Color(hex: "#175AA8")
                    .ignoresSafeArea()

                VStack(spacing: 20) {
                    // Block Wi-Fi Section
                    networkControlBlock(
                        title: "Block Wi-Fi",
                        icon: isWiFiBlocked ? "wifi.slash" : "wifi",
                        text: isWiFiBlocked ? "Wi-Fi Blocked" : "Block Wi-Fi",
                        description: networkMonitor.isWiFiConnected ? "Wi-Fi is connected." : "Wi-Fi is not connected. Blocking unavailable.",
                        isOn: $isWiFiBlocked,
                        backgroundColor: Color.blue
                    )
                    .padding(.top, 30)
                    .onChange(of: isWiFiBlocked) { newValue in
                        UserDefaults.standard.set(newValue, forKey: "isBlockWifiEnabled")
                        handleWiFiBlock(newValue)  // Handle blocking logic when toggle changes
                    }
                    
                    // Whitelist Wi-Fi Section
                    networkControlBlock(
                        title: "Whitelist Wi-Fi",
                        icon: isWiFiWhitelisted ? "checkmark.circle.fill" : "circle",
                        text: isWiFiWhitelisted ? "Wi-Fi Whitelisted" : "Enable Wi-Fi Whitelist",
                        description: "Whitelisted SSIDs: \(whitelistedSSIDs.joined(separator: ", "))",
                        isOn: $isWiFiWhitelisted,
                        backgroundColor: Color.blue
                    )
                    .onChange(of: isWiFiWhitelisted) { newValue in
                        UserDefaults.standard.set(newValue, forKey: "isWhiteListWifiEnabled")
                    }

                    // SSID Input Section
                    if isWiFiWhitelisted {
                        VStack(spacing: 15) {
                            TextField("Enter Wi-Fi Name", text: $newSSID)
                                .padding()
                                .background(
                                    LinearGradient(
                                        gradient: Gradient(colors: [Color.lightBlue, Color.lightBlue.opacity(0.2)]),
                                        startPoint: .leading,
                                        endPoint: .trailing))                .cornerRadius(8)
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                                .overlay(
                                    RoundedRectangle(cornerRadius: 8)
                                        .stroke(Color.gray.opacity(0.7), lineWidth: 1)
                                )

                            Button(action: addSSIDToWhitelist) {
                                HStack {
                                    Text("Add to Whitelist")
                                        .fontWeight(.semibold)
                                        .foregroundColor(.white)
                                    Spacer()

                                    Image(systemName: "plus.circle.fill")  // Add icon to button
                                        .foregroundColor(.blue)
                                        .font(.system(size: 20, weight: .bold))

                                }
                                .padding()
                                .frame(maxWidth: .infinity)  // Makes the button expand to full width
                                .background(
                                    LinearGradient(
                                        gradient: Gradient(colors: [Color.blue, Color.white.opacity(0.7)]),
                                        startPoint: .leading,
                                        endPoint: .trailing
                                    )
                                )
                                .cornerRadius(10)
                                .shadow(color: Color.black.opacity(0.2), radius: 5, x: 0, y: 2)
                            }
                            .padding(.top, 10)
                            .padding(.horizontal,40)
                        }
                        .padding(.top, 10)
                    }
                }
                .padding(.horizontal, 10)
                .padding(.top, 20)
                .shadow(color: Color.black.opacity(0.4), radius: 5, x: 0, y: 2)
            }
            .navigationTitle("Network Control")
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarBackButtonHidden(true)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    BackButton()
                }
            }
            .onAppear {
                networkMonitor.monitor.start(queue: networkMonitor.monitorQueue)
            }.onReceive(NotificationCenter.default.publisher(for: .blockWifiChanged)) { notification in
                if let enabled = notification.object as? Bool {
                    isWiFiBlocked = enabled
                }
            }
            .onReceive(NotificationCenter.default.publisher(for: .exceptionWifiChanged)) { notification in
                if let ssids = notification.object as? [String] {
                    whitelistedSSIDs = ssids
                }
            }
            .alert(isPresented: $showAlert) {
                Alert(
                    title: Text("Wi-Fi Status"),
                    message: Text(alertMessage),
                    primaryButton: .default(Text("Go to Settings"), action: {
                        openWiFiSettings()  // Open Settings when button is tapped
                    }),
                    secondaryButton: .default(Text("OK"))
                )
            }
            .onReceive(NotificationCenter.default.publisher(for: .whitelistWiFiChanged)) { notification in
                if let enabled = notification.object as? Bool {
                    isWiFiWhitelisted = enabled
                }
            }
            .onChange(of: isWiFiWhitelisted) { _ in
                checkWiFiConnection()
            }
        }
    }

    private func networkControlBlock(title: String, icon: String, text: String, description: String, isOn: Binding<Bool>, backgroundColor: Color) -> some View {
        VStack(spacing: 12) {
            Text(title)
                .font(.headline)
                .foregroundColor(.white)
                .padding(.bottom, 5)

            HStack {
                Image(systemName: icon)
                    .foregroundColor(.white)
                Text(text)
                    .foregroundColor(.white)
                    .fontWeight(.bold)

                Spacer()
                Toggle("", isOn: isOn)
                    .toggleStyle(SwitchToggleStyle(tint: backgroundColor))
                    .labelsHidden()
            }
            .padding()
            .background(Color.white.opacity(0.3))
            .cornerRadius(15)

            Text(description)
                .font(.subheadline)
                .foregroundColor(.white)
                .padding(.top, 5)
        }
        .padding( 20)
        .background(
            LinearGradient(
                gradient: Gradient(colors: [Color.lightBlue, Color.lightBlue.opacity(0.2)]),
                startPoint: .leading,
                endPoint: .trailing))
        .cornerRadius(15)
    }

    private func addSSIDToWhitelist() {
        guard !newSSID.isEmpty, !whitelistedSSIDs.contains(newSSID) else { return }
        whitelistedSSIDs.append(newSSID)
        newSSID = ""
    }

    private func checkWiFiConnection() {
        let currentSSIDNormalized = networkMonitor.currentSSID.lowercased()
        let whitelistedSSIDsNormalized = whitelistedSSIDs.map { $0.lowercased() }
        
        if isWiFiWhitelisted {
            if whitelistedSSIDsNormalized.contains(currentSSIDNormalized) {
                alertMessage = "Connected to a whitelisted Wi-Fi network."
            } else {
                alertMessage = "Not connected to a whitelisted Wi-Fi network."
            }
            showAlert = true
        }
    }

    // Handle Wi-Fi block based on toggle state
    private func handleWiFiBlock(_ shouldBlock: Bool) {
        // Simulate API request to check Wi-Fi status (could be replaced with an actual API call)
        checkWiFiStatus { isOpen in
            if isOpen {
                // Wi-Fi is open and connected, show an alert to ask the user to disconnect manually from Settings
                alertMessage = "Wi-Fi is currently open. Please disconnect it manually from Settings before we can block it."
                // Show alert with the 'Go to Settings' button
                showAlert = true
            } else {
                // Wi-Fi is not open, proceed to block/unblock based on the toggle state
                if shouldBlock {
                    // Block Wi-Fi logic (mock functionality for now)
                    alertMessage = "Wi-Fi is now blocked."
                    // Make an API call to block Wi-Fi (mock or real)
                } else {
                    alertMessage = "Wi-Fi is now unblocked."
                    // Make an API call to unblock Wi-Fi (mock or real)
                }
                // Show alert with success message
                showAlert = true
            }
        }
    }

    // Simulate an API call to check if Wi-Fi is open
    private func checkWiFiStatus(completion: @escaping (Bool) -> Void) {
        // Simulate a network check. In reality, you could make an actual API call here.
        DispatchQueue.global().asyncAfter(deadline: .now() + 1) {
            // Simulate response: Wi-Fi is open
            completion(true) // Change this to `false` to simulate Wi-Fi being closed
        }
    }

    // A helper function to open Wi-Fi settings
    private func openWiFiSettings() {
        if let url = URL(string: UIApplication.openSettingsURLString) {
            if UIApplication.shared.canOpenURL(url) {
                UIApplication.shared.open(url, options: [:], completionHandler: nil)
            }
        }
    }
}

struct NetworkControl_Previews: PreviewProvider {
    static var previews: some View {
        NetworkControl()
    }
}
