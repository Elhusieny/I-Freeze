import SwiftUI

struct LicenseActivationScreen: View {
    @Binding var isLicensed: Bool
    @StateObject private var activationViewModel = LicenseActivationViewModel()
    @StateObject private var authViewModel = AuthViewModel()

    var body: some View {
        NavigationStack {
            ZStack {
                Color(hex: "#175AA8")                             .ignoresSafeArea()
                
                VStack(spacing: 20) {
                    Text("Activate Your License")
                        .font(.title)
                        .fontWeight(.bold)
                        .padding(.top, 40)
                        .foregroundColor(.white)
                    
                    Text("Enter your activation key to unlock all features.")
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                        .foregroundColor(.white)
                    
                    TextField("Activation Key", text: $activationViewModel.activationKey)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .padding()
                    
                    Button {
                        activationViewModel.activateLicense { isSuccess in
                            if isSuccess {
                                handleSuccessfulActivation()
                            }
                        }
                    } label: {
                        Text("Activate")
                            .font(.headline)
                            .foregroundColor(.white)
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(
                                LinearGradient(
                                    gradient: Gradient(colors: [Color.lightBlue.opacity(0.9), Color.lightBlue.opacity(0.2)]),
                                    startPoint: .leading,
                                    endPoint: .trailing))
                            .cornerRadius(10)
                            .shadow(color: Color.black.opacity(0.4), radius: 5, x: 0, y: 2)
                    }
                    
                    .padding(.horizontal)
                    .alert(isPresented: $activationViewModel.showAlert) {
                        Alert(
                            title: Text(activationViewModel.activationMessage),
                            message: Text(activationViewModel.activationMessage.contains("Successful") ? "All features are now unlocked." : "Please check your activation key."),
                            primaryButton: .default(Text("OK")) {
                                if activationViewModel.activationMessage.contains("Successful") {
                                    isLicensed = true
                                    // Navigate to home when successful
                                    activationViewModel.navigateToHome = true
                                }
                            },
                            secondaryButton: .default(Text("Go to Home")) {
                                if activationViewModel.activationMessage.contains("Successful") {
                                    isLicensed = true
                                    activationViewModel.navigateToHome = true
                                }
                            }
                        )
                    }
                    
                    Spacer()
                }
                .padding()
                .background(Color.white.opacity(0.1))
                .cornerRadius(15)
                .shadow(radius: 10)
                .padding()
            }
            .navigationTitle("License Activation")
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarBackButtonHidden(true)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    BackButton()
                }
            }
            .background(
                NavigationLink(destination: HomeView(), isActive: $activationViewModel.navigateToHome) { EmptyView() }
            )
        }
    }

    /// Handle successful license activation
    private func handleSuccessfulActivation() {
        // Retrieve the deviceId from Keychain
        guard var storedDeviceId = KeychainHelper.shared.load(key: "deviceId") else {
            print("Error: DeviceId not found in Keychain.")
            return
        }
        // Clean up deviceId by trimming whitespace and removing quotes
        storedDeviceId = storedDeviceId.trimmingCharacters(in: .whitespacesAndNewlines).replacingOccurrences(of: "\"", with: "")
        // Fetch token using the deviceId
        authViewModel.fetchToken(deviceId: storedDeviceId) { success in
            if success {
                print("success")
                isLicensed = true
            } else {
                print("Error: Unable to fetch token.")
            }
        }
    }
}
    


struct LicenseActivationScreen_Previews: PreviewProvider {
    static var previews: some View {
        LicenseActivationScreen(isLicensed: .constant(false))
    }
}
