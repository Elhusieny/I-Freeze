import SwiftUI
struct HomeView: View {
    // Inside HomeView
    @State private var isLicensed = UserDefaults.standard.bool(forKey: "isLicensed")
    @State private var showLicenseAlert = false // Show license activation alert
    @State private var selectedFeature: String? = nil // Track selected feature for navigation
    let functions = [
        ("System Scan", "magnifyingglass"),
        ("Web Browser", "safari"),
        ("Admin Login", "lock.fill"),
        ("Request Support", "envelope.fill"),
        ("Kiosk Apps", "apps.iphone"),
        ("Screen Sharing", "rectangle.and.pencil.and.ellipsis")
    ]
    var body: some View {
        NavigationStack {
            ZStack {
                Color.darkBlue
                        .ignoresSafeArea()
                VStack {
                    LazyVGrid(columns: Array(repeating: GridItem(.flexible(minimum: 150)), count: 2), spacing: 20) {
                        ForEach(functions, id: \.0) { function in
                            Button(action: {
                                if isLicensed {
                                    selectedFeature = function.0
                                } else {
                                    showLicenseAlert = true
                                }
                            }) {
                                VStack {
                                    Image(systemName: function.1)
                                        .font(.system(size: 60))
                                        .foregroundColor(.white)
                                        .shadow(radius: 2)
                                    
                                    Text(function.0)
                                        .font(.headline)
                                        .foregroundColor(.white)
                                        .multilineTextAlignment(.center)
                                        .padding(.top, 5)
                                }
                                .padding()
                                .frame(minWidth: 150, minHeight: 150)
                                .background(Color.white.opacity(0.1))
                                .cornerRadius(10)
                                .shadow(color: .gray.opacity(0.3), radius: 5, x: 0, y: 2)
                            }
                            .alert("Activate License", isPresented: $showLicenseAlert, actions: {
                                NavigationLink(destination: LicenseActivationScreen(isLicensed: $isLicensed)) {
                                    Text("Activate")
                                }
                                Button("Cancel", role: .cancel) {}
                            }, message: {
                                Text("This feature requires a valid license. Please activate your license to access it.")
                            })
                        }
                    }
                    .padding()
                }

                
            }
            .navigationTitle("Home")
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarBackButtonHidden(true)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    BackButton()
                }
            }
            .background(
                NavigationLink(
                    destination: destinationView(for: selectedFeature),
                    isActive: Binding(
                        get: { selectedFeature != nil },
                        set: { if !$0 { selectedFeature = nil } } // Reset `selectedFeature` after navigation
                    )
                ) {
                    EmptyView()
                }
                .hidden()
            )
            // Add onAppear here
            .onAppear {
            isLicensed = UserDefaults.standard.bool(forKey: "isLicensed") //Refresh the license status
        }
        }
    }

    @ViewBuilder
    private func destinationView(for functionName: String?) -> some View {
        switch functionName {
        case "System Scan":
            SystemScanScreen()
        case "Web Browser":
            FunctionDetailView(functionName: functionName ?? "")
        case "Admin Login":
            AdminLoginScreen()
        case "Request Support":
            RequestSupport()
        case "Kiosk Apps":
            FunctionDetailView(functionName: functionName ?? "")
        case "Screen Sharing":
            FunctionDetailView(functionName: functionName ?? "")
        default:
            FunctionDetailView(functionName: functionName ?? "")
        }
    }
}
struct FunctionDetailView: View {
    var functionName: String
    
    var body: some View {
        Text("Welcome to \(functionName) Screen")
            .font(.largeTitle)
            .padding()
    }
}

struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        HomeView()
    }
}
