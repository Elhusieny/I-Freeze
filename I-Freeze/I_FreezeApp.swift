

import SwiftUI

@main
struct I_FreezeApp: App {
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
            WelcomeScreen()
        }
    }
}
