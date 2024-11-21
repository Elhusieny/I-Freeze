
import SwiftUI
struct SettingScreen: View {
    @StateObject private var viewModel = ServerConfigViewModel()

    @ObservedObject var locationManager = LocationManager.shared
    @State private var isTrackingEnabled = false
    @State private var isKioskModeEnabled = UserDefaults.standard.bool(forKey: "isKioskModeEnabled")
    @State private var appNames: [String] = []
    @State private var showingAlert = false
    @State private var navigateToPostAppNames = false
    var body: some View {
        NavigationStack {
            ZStack {
                Color(hex: "#175AA8")                             .ignoresSafeArea()
                VStack(spacing: 0) {
                    topSection
                    mainSection
                    Spacer()
                }
                .padding(.bottom, 20)
            }
            .navigationTitle("Settings")
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarBackButtonHidden(true)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    BackButton()
                }
            }
            .fullScreenCover(isPresented: $isKioskModeEnabled) {
                KioskView(isKioskModeEnabled: $isKioskModeEnabled)
            }
        }
        
    }
    private var topSection: some View {
        VStack {
            Image(systemName: "checkmark.shield.fill")
                .resizable()
                .scaledToFit()
                .frame(width: 80, height: 80)
                .foregroundColor(.white)
                .padding(.top, 10)
                .shadow(radius: 10)
            
            Text("You are Protected!")
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(.white)
                .padding(.bottom, 10)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .padding(.horizontal, 20)
        .padding(.top, 20)
        .shadow(color: .black.opacity(0.3), radius: 10, x: 0, y: 4)
        
    }
    private var mainSection: some View {
        VStack(spacing: 20) {
            locationSection
            kioskModeSection
            sendAppNamesButton
        }
        .padding(.horizontal, 10)
        .onAppear {
            loadSettings()
        }
        .alert(isPresented: Binding<Bool>(
            get: { !locationManager.isLocationEnabled && isTrackingEnabled },
            set: { _ in }
        )) {
            Alert(
                title: Text("Location Access Denied"),
                message: Text("Please enable location access in Settings."),
                dismissButton: .default(Text("OK"))
            )
        }
        .padding(.top, 20)
        
    }
    
    private var locationSection: some View {
        VStack(spacing: 12) {
            Text("Location Tracking")
                .font(.title3.weight(.heavy))
                .foregroundColor(.white)
                .padding(.vertical, 10)
            
            Toggle(isOn: $locationManager.shouldSendLocation) {
                HStack {
                    Image(systemName: "location.fill")
                        .foregroundColor(.white)
                    Text("Enable Location Tracking")
                        .foregroundColor(.white)
                }
                
            }
            .toggleStyle(SwitchToggleStyle(tint: Color.blue))
            .onChange(of: locationManager.shouldSendLocation) { value in
                UserDefaults.standard.set(value, forKey: "isTrackingEnabled")
                locationManager.shouldSendLocation = value
                if value {
                    locationManager.startLocationUpdates()
                } else {
                    locationManager.stopLocationUpdates()
                }
            }
            .padding()
            .background(Color.white.opacity(0.1))
            .cornerRadius(10)
            
            if let location = locationManager.currentLocation {
                HStack {
                    Image(systemName: "map.fill")
                        .foregroundColor(.blue)
                    Text("Current Location: \(location.coordinate.latitude), \(location.coordinate.longitude)")
                        .foregroundColor(.white)
                        .font(.footnote)
                }
                .padding()
                .background(Color.white.opacity(0.1))
                .cornerRadius(10)
            } else {
                Text("Location not available.")
                    .foregroundColor(.red)
                    .padding()
                    .background(Color.white.opacity(0.1))
                    .cornerRadius(10)
            }
        }
        .padding(.horizontal, 20)
        .padding(.top, 10)
        .padding(.bottom,10)
        .background(
            LinearGradient(
                gradient: Gradient(colors: [Color.lightBlue, Color.lightBlue.opacity(0.2)]),
                startPoint: .leading,
                endPoint: .trailing))
        .cornerRadius(15)
        .shadow(color: Color.black.opacity(0.2), radius: 5, x: 0, y: 2)
        
    }
    
    private var kioskModeSection: some View {
        VStack(spacing: 12) {
            Text("Kiosk Mode")
                .font(.title3.weight(.heavy))
                .foregroundColor(.white)
                .padding(.vertical, 10)
            
            // Toggle Kiosk Mode and show instructions
            Toggle(isOn: $isKioskModeEnabled) {
                HStack {
                    Image(systemName: "lock.rectangle.fill")
                        .foregroundColor(.white)
                    Text("Enable Kiosk Mode")
                        .foregroundColor(.white)
                }
            }
            .toggleStyle(SwitchToggleStyle(tint: Color.blue))
            .onChange(of: isKioskModeEnabled) { value in
                UserDefaults.standard.set(value, forKey: "isKioskModeEnabled")
            }
            .padding()
            .background(Color.white.opacity(0.1))
            .cornerRadius(10)
            .padding(.bottom,10)

        }// Add this to SettingScreen to observe changes to Kiosk Mode
        .onReceive(NotificationCenter.default.publisher(for: .kioskModeChanged)) { notification in
            if let enabled = notification.object as? Bool {
                isKioskModeEnabled = enabled
            }
        }
        
        .padding(.horizontal, 20)
        .padding(.top, 10)
        .background(
            LinearGradient(
                gradient: Gradient(colors: [Color.lightBlue, Color.lightBlue.opacity(0.2)]),
                startPoint: .leading,
                endPoint: .trailing))
        .cornerRadius(15)
        .shadow(color: Color.black.opacity(0.2), radius: 5, x: 0, y: 2)
    }
    private var sendAppNamesButton: some View {
        VStack {
            NavigationLink(destination: PostAppNamesView(), isActive: $navigateToPostAppNames) {
                EmptyView()
            }
            Button(action: {
                navigateToPostAppNames = true
            }) {
                HStack {
                    Image(systemName: "square.and.arrow.up")
                        .foregroundColor(.white)
                    Text("Send App Names")
                        .foregroundColor(.white)
                        .fontWeight(.bold)
                }
                .padding()
                .background(Color.blue)
                .cornerRadius(10)
            }
            .padding(.horizontal, 20)
            .padding(.top, 10)
        }
        
    }
    
    private func loadSettings() {
        isTrackingEnabled = UserDefaults.standard.bool(forKey: "isTrackingEnabled")
        locationManager.shouldSendLocation = isTrackingEnabled
        if isTrackingEnabled {
            locationManager.startLocationUpdates()
        }
        isKioskModeEnabled = UserDefaults.standard.bool(forKey: "isKioskModeEnabled")
    }
    
}
struct SettingScreen_Previews: PreviewProvider {
    static var previews: some View {
        SettingScreen()
    }
    
}
