import SwiftUI

@main
struct I_FreezeApp: App {
    @State private var isSplashScreenActive = true
    @State private var isLicensed = UserDefaults.standard.bool(forKey: "isLicensed")

    init() {
        // Set up global appearance for navigation bar
        let appearance = UINavigationBarAppearance()
        appearance.configureWithTransparentBackground() // Make background transparent
        appearance.titleTextAttributes = [.foregroundColor: UIColor.white] // Set title text color to white
        appearance.largeTitleTextAttributes = [.foregroundColor: UIColor.white] // Set large title text color to white
        UINavigationBar.appearance().standardAppearance = appearance
        UINavigationBar.appearance().scrollEdgeAppearance = appearance
        UINavigationBar.appearance().tintColor = .white // Set back button color to white
    }

    var body: some Scene {
        WindowGroup {
            ZStack {
                if isSplashScreenActive {
                    SplashScreen()
                        .onAppear {
                            // Transition to the main screen after 3 seconds
                            DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                                withAnimation {
                                    isSplashScreenActive = false
                                }
                            }
                        }
                } else {
                    // Check if the user is licensed
                    if isLicensed {
                   
                        HomeView() // Navigate to the Home screen if licensed
                    } else {
                        WelcomeScreen() // Navigate to the Welcome screen if not licensed
                    }
                }
            }
        }
    }
}
