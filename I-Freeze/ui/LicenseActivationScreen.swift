// LicenseActivationScreen.swift

import SwiftUI
struct LicenseActivationScreen: View {
    @Binding var isLicensed: Bool
    @StateObject private var viewModel = LicenseActivationViewModel()
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color.darkBlue
                        .ignoresSafeArea()
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
                    
                    TextField("Activation Key", text: $viewModel.activationKey)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .padding()
                    
                    Button(action: viewModel.activateLicense) {
                        Text("Activate")
                            .font(.headline)
                            .foregroundColor(.white)
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(
                                LinearGradient(
                                    gradient: Gradient(colors: [Color.darkBlue, Color.lightBlue.opacity(0.7)]),
                                    startPoint: .leading,
                                    endPoint: .trailing))                            .cornerRadius(10)
                            .shadow(color: Color.black.opacity(0.4), radius: 5, x: 0, y: 2)
                    }
                    .padding(.horizontal)
                    .alert(isPresented: $viewModel.showAlert) {
                        Alert(
                            title: Text(viewModel.activationMessage),
                            message: Text(viewModel.activationMessage.contains("Successful") ? "All features are now unlocked." : "Please check your activation key."),
                            primaryButton: .default(Text("OK")) {
                                if viewModel.activationMessage.contains("Successful") {
                                    isLicensed = true
                                    //viewModel.navigateToHome = true
                                }
                            },
                            secondaryButton: .default(Text("Go to Home")) {
                                if viewModel.activationMessage.contains("Successful") {
                                    isLicensed = true
                                    viewModel.navigateToHome = true
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
                NavigationLink(destination: HomeView(), isActive: $viewModel.navigateToHome) { EmptyView() }
            )
        }
    }
}


struct LicenseActivationScreen_Previews: PreviewProvider {
    static var previews: some View {
        LicenseActivationScreen(isLicensed: .constant(false))
    }
}
