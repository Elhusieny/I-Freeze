import SwiftUI
import UIKit
import Network

struct PermissionsNotifi_Locati_Photos_Phone: View {
    @StateObject var locationManager = LocationManager()
    @StateObject private var notificationManager = NotificationManager()
    @StateObject private var phoneManager = PhoneManager()
    @StateObject private var photoManager = PhotoManager()
    @StateObject private var networkManager = NetworkManager()
    @StateObject private var documentManager = DocumentManager()
    @State private var showAccessGrantedAlert = false
    @State private var showAccessDeniedAlert = false
    @State private var showNotificationAccessDeniedAlert = false
    @State private var isWifiEnabled = false
    
    // State for navigation
    @State private var navigateToHome = false
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color(hex: "#175AA8")                             .ignoresSafeArea()
                NavigationStack() {
                    Spacer()
                    PermissionSection(
                        title: "Location Services are Enabled",
                        isEnabled: locationManager.isLocationEnabled,
                        onRequest: { locationManager.requestLocationPermission() }, // Wrap in a closure
                        icon: "location.fill",
                        grantedText: "Request Location Access"
                    )
                    PermissionSection(
                        title: "Notification is Enabled",
                        isEnabled: notificationManager.isNotificationEnabled,
                        onRequest: {
                            notificationManager.requestNotificationPermission { granted in
                                if granted {
                                    showAccessGrantedAlert = true
                                } else {
                                    showNotificationAccessDeniedAlert = true
                                }
                                
                            }
                        },
                        icon: "bell",
                        grantedText: "Request Notification Access"
                    )
                    
                    PermissionSection(
                        title: "Phone Access is Enabled",
                        isEnabled: phoneManager.isPhoneAccessEnabled,
                        onRequest: {
                            phoneManager.onPermissionGranted = {
                                showAccessGrantedAlert = true
                                
                            }
                            phoneManager.onPermissionDenied = {
                                showAccessDeniedAlert = true
                                
                            }
                            phoneManager.requestPhonePermission()
                            
                        },
                        icon: "phone",
                        grantedText: "Request Phone Access"
                    )
                    
                    PermissionSection(
                        title: "Photo Access is Enabled",
                        isEnabled: photoManager.isPhotoAccessEnabled,
                        onRequest: photoManager.requestPhotoPermission,
                        icon: "photo",
                        grantedText: "Request Photo Access"
                    )
                    
                    // Wi-Fi Permission Section
                    PermissionSection(
                        title: "Wi-Fi Status",
                        isEnabled: !isWifiEnabled,
                        onRequest: checkWifiStatus,
                        icon: isWifiEnabled ? "wifi.slash" : "checkmark.circle.fill",
                        grantedText: isWifiEnabled ? "Wi-Fi is Enabled" : "Wi-Fi is Off"
                    )
                    PermissionSection(
                        title: "Document Access is Enabled",
                        isEnabled: documentManager.isDocumentAccessEnabled,
                        onRequest: documentManager.presentDocumentPicker,
                        icon: "doc",
                        grantedText: "Request Document Access"
                    )
                    // Next Button
                    NavigationLink(destination: HomeView(), isActive: $navigateToHome) {
                        Button(action: {
                            navigateToHome = true
                            
                        }) {
                            HStack {
                                Text("Next ")
                                    .foregroundColor(.white).bold()
                                    .padding(.leading)
                                Spacer()
                                Image(systemName: "chevron.right")
                                    .resizable()
                                    .frame(width: 15, height: 15)
                                    .foregroundColor(.white)
                                
                            }
                            .padding()
                            .frame(width:130)
                            .background(
                                LinearGradient(
                                    gradient: Gradient(colors: [Color.lightBlue.opacity(0.9), Color.lightBlue.opacity(0.2)]),
                                    startPoint: .leading,
                                    endPoint: .trailing))
                            .cornerRadius(10)
                            .padding(.horizontal, 20)
                            
                        }
                        .padding(.top, 100) // Adds top margin of 50 points from the previous content
                        .shadow(color: Color.black.opacity(0.4), radius: 5, x: 0, y: 2)

                        
                    }
                    
                }
                .padding(.top, 20)
                .foregroundColor(.white)
                
            }
            .navigationTitle("Permissions")
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarBackButtonHidden(true)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    BackButton()
                    
                }
            }
            .onAppear {
                locationManager.checkLocationAuthorization()
                notificationManager.checkNotificationAuthorization()
                phoneManager.checkPhoneAuthorization()
                photoManager.checkPhotoAuthorization()
                networkManager.startMonitoring { isEnabled in
                    self.isWifiEnabled = isEnabled
                }
                
            }
            .alert("Access Granted", isPresented: $showAccessGrantedAlert) {
                Button("OK", role: .cancel) {}
            } message: {
                Text("Notifications access has been granted.")
            }
            .alert("Access Denied", isPresented: $showAccessDeniedAlert) {
                Button("OK", role: .cancel) {}
            } message: {
                Text("Phone access has been denied. Please enable it in Settings.")
            }
            .alert("Notification Access Denied", isPresented: $showNotificationAccessDeniedAlert) {
                Button("Open Settings") {
                    notificationManager.openSettings()
                }
                Button("Cancel", role: .cancel) {}
            } message: {
                Text("Notification access has been denied. Please enable it in Settings.")
            }
            .alert(isPresented: Binding<Bool>(
                get: { isWifiEnabled },
                set: { _ in }
            )) {
                Alert(
                    title: Text("Wi-Fi Enabled"),
                    message: Text("Please turn off Wi-Fi to continue. If you can't, go to Settings > Wi-Fi."),
                    primaryButton: .default(Text("Go to Settings")) {
                        openWifiSettings()
                    },
                    secondaryButton: .cancel()
                )
            }
        }
    }
    
    func checkWifiStatus() {
        networkManager.startMonitoring { isEnabled in
            self.isWifiEnabled = isEnabled
        }
    }
    
    func openWifiSettings() {
        if let url = URL(string: "App-Prefs:root=WIFI") {
            if UIApplication.shared.canOpenURL(url) {
                UIApplication.shared.open(url, options: [:], completionHandler: nil)
            } else {
                print("Cannot open Wi-Fi settings")
            }
        }
    }
    
    
    struct PermissionSection: View {
        let title: String
        let isEnabled: Bool
        let onRequest: () -> Void
        let icon: String
        let grantedText: String
        
        var body: some View {
            if isEnabled {
                HStack {
                    Text(title)
                        .foregroundColor(.white).bold()
                        .padding(.leading)
                    Spacer()
                    
                    if isEnabled {
                        Image(systemName: "checkmark.circle.fill")
                            .resizable()
                            .frame(width: 24, height: 24)
                            .foregroundColor(.white.opacity(0.80))
                    }
                }
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(
                        LinearGradient(
                            gradient: Gradient(colors: [Color.lightBlue.opacity(0.9), Color.lightBlue.opacity(0.2)]),
                            startPoint: .leading,
                            endPoint: .trailing))
                    .cornerRadius(10)
                    .padding(.horizontal, 20)
                    .shadow(color: Color.black.opacity(0.4), radius: 5, x: 0, y: 2)
            } else {
                Button(action: onRequest) {
                    HStack {
                        Text(grantedText)
                            .foregroundColor(.white).bold()
                            .padding(.leading)
                        Spacer()
                        Image(systemName: icon)
                            .resizable()
                            .frame(width: 24, height: 24)
                            .foregroundColor(.white)
                        
                            .symbolVariant(.fill)
                    }
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(
                            LinearGradient(
                                gradient: Gradient(colors: [Color.lightBlue.opacity(0.9), Color.lightBlue.opacity(0.2)]),
                                startPoint: .leading,
                                endPoint: .trailing))
                        .cornerRadius(10)
                        .padding(.horizontal, 20)
                        .shadow(color: Color.black.opacity(0.4), radius: 5, x: 0, y: 2)

                }
            }
            
        }
        
    }
    
}
struct ContentView_Previews: PreviewProvider {
static var previews: some View {
PermissionsNotifi_Locati_Photos_Phone()
}
}
