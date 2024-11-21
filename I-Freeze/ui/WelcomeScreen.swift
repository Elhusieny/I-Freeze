import SwiftUI
struct WelcomeScreen: View {
    @State private var isNextScreenActive = false // State to handle navigation
    var body: some View {
        NavigationStack { // Use NavigationStack instead of NavigationView
            ZStack {
                Color(hex: "#175AA8")                             .ignoresSafeArea()
                VStack(spacing: 20) {
                    Spacer() // Push content to the center vertically
                    
                    // Logo and Title
                    VStack(spacing: 10) {
                        Image("logo")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 80, height: 80)
                        
                        Text("i-Freeze")
                            .foregroundColor(.white)
                            .font(.system(size: 40, weight: .bold)) // Larger title with bold weight
                    }
                    // Slogan
                    Text("Freeze Your Risks")
                        .foregroundColor(.white)
                        .font(.title2) // Slogan font style
                        .padding(.top, 10)
                    
                    Spacer() // Center the content
                    
                    // Description Texts with clickable links
                    VStack(alignment: .center, spacing: 5) {
                        Text("By proceeding, you confirm the")
                            .foregroundColor(.white)
                            .font(.headline)
                        
                        HStack(spacing: 4) {
                            Text("Agreement")
                                .foregroundColor(.white)
                                .font(.system(size: 20, weight: .bold))
                                .underline()
                                .onTapGesture {
                                    openLink(urlString: "https://example.com/agreement")
                                }
                            
                            Text("and")
                                .foregroundColor(.white)
                                .font(.headline)
                            
                            Text("Privacy Policy")
                                .foregroundColor(.white)
                                .font(.system(size: 20, weight: .bold))
                                .underline()
                                .onTapGesture {
                                    openLink(urlString: "https://example.com/privacy")
                                }
                        }
                    }
                    .padding(.bottom, 20) // Adds space between links and button
                    
                    // Navigation Button to Next Screen
                    NavigationLink(destination: AccessibilityServiceScreen()) {
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
                                gradient: Gradient(colors: [Color.lightBlue, Color.lightBlue.opacity(0.2)]),
                                startPoint: .leading,
                                endPoint: .trailing))
                        .cornerRadius(10)
                        .padding(.horizontal, 20)
                        .shadow(color: Color.black.opacity(0.4), radius: 5, x: 0, y: 2)

                    }
                    .padding(.top, 100) // Adds top margin of 50 points from the previous content
                }
            }
            .navigationTitle("Welcome")
            .navigationBarHidden(true) // Hide the navigation bar on this screen
        }
    }
    
    // Function to open URL
    func openLink(urlString: String) {
        if let url = URL(string: urlString) {
            UIApplication.shared.open(url)
        }
    }
}
struct WelcomeScreen_Previews: PreviewProvider {
    static var previews: some View {
        WelcomeScreen()
    }
}
