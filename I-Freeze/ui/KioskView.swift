import SwiftUI

struct KioskView: View {
    @Binding var isKioskModeEnabled: Bool
    @State private var password: String = ""
    @State private var showPasswordAlert: Bool = false
    private let correctPassword = "1234" // Define your correct password here
    @State private var isShowingGuidedAccessInstructions = false

    var body: some View {
        ZStack {
            Color.darkBlue
                .ignoresSafeArea()
            
            VStack(spacing: 20) {
                // Header
                Text("Kiosk Mode")
                    .font(.largeTitle.weight(.bold))
                    .foregroundColor(.white)
                    .padding(.top, 40)
                
                Spacer()

                // Setup Section
                setupSection
                Spacer()

                // Password Section for Exiting Kiosk Mode
                exitSection

                Spacer()
            }
            .padding(.horizontal, 20)
        }
        .alert(isPresented: $showPasswordAlert) {
            Alert(
                title: Text("Access Denied"),
                message: Text("Incorrect password. Please try again."),
                dismissButton: .default(Text("OK")) {
                    password = "" // Clear password field on dismiss
                }
            )
        }
    }
    
    // Setup Section with Instructions and Settings Button
    private var setupSection: some View {
        VStack(spacing: 20) {
            CustomButton(
                text: "Guided Access Setup Instructions",
                icon: "questionmark.circle",
                action: { isShowingGuidedAccessInstructions.toggle() }
            )
            
            if isShowingGuidedAccessInstructions {
                guidedAccessInstructions
            }
            
            CustomButton(
                text: "Open Accessibility Settings",
                icon: "gearshape",
                action: openAccessibilitySettings
            )
        }
        .padding()
        .background(Color.white.opacity(0.1))
        .cornerRadius(10)
    }

    
    // Password Entry and Exit Button with Exit Icon
    private var exitSection: some View {
        VStack(spacing: 10) {
            Text("Enter Password to Exit Kiosk Mode")
                .foregroundColor(.white)
                .font(.headline)
            
            SecureField("Password", text: $password)
                .padding()
                .background(Color.white.opacity(0.8))
                .cornerRadius(10)
                .padding(.horizontal, 55)
            
            CustomButton(
                text: "Exit Kiosk Mode",
                icon: "xmark.circle", // Exit icon
                action: exitKioskMode
            )
            .padding(.horizontal, 40)
        }
        .padding(.top, 20)
    }
    
    // Guided Access Instructions Content
    private var guidedAccessInstructions: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Guided Access Setup")
                .font(.title2.weight(.bold))
                .foregroundColor(.white)
                .padding(.top, 10)
            Text("1. Go to Settings > Accessibility > Guided Access and turn it on.")
                .foregroundColor(.white)
            Text("2. Set a Passcode to prevent the user from exiting Guided Access mode.")
                .foregroundColor(.white)
            Text("3. Activate Guided Access by triple-pressing the Side (or Home) button.")
                .foregroundColor(.white)
            Text("Note: Guided Access requires user setup and can't be toggled by this app.")
                .foregroundColor(.red)
                .font(.footnote)
        }
        .padding()
        .background(Color.white.opacity(0.1))
        .cornerRadius(10)
    }
    
    private func openAccessibilitySettings() {
        if let url = URL(string: UIApplication.openSettingsURLString) {
            UIApplication.shared.open(url)
        }
    }

    private func exitKioskMode() {
        if password == correctPassword {
            isKioskModeEnabled = false
            NotificationCenter.default.post(name: NSNotification.Name("ExitKioskMode"), object: nil)
            password = "" // Clear password field
        } else {
            showPasswordAlert = true
        }
    }
}

// Reusable Custom Button Component
struct CustomButton: View {
    var text: String
    var icon: String? = nil
    var action: () -> Void
    var body: some View {
        Button(action: action) {
            HStack {
                Text(text)
                    .foregroundColor(.white)
                    .fontWeight(.bold)
                Spacer()
                if let icon = icon {
                    Image(systemName: icon)
                        .foregroundColor(.white)
                }
                
            }
            .padding()
            .frame(maxWidth: .infinity)
            .background(
                LinearGradient(
                    gradient: Gradient(colors: [Color.darkBlue, Color.lightBlue.opacity(0.7)]),
                    startPoint: .leading,
                    endPoint: .trailing
                )
            )
            .cornerRadius(10)

        .shadow(color: Color.black.opacity(0.4), radius: 5, x: 0, y: 2)
        }
    }
}

struct KioskView_Previews: PreviewProvider {
    static var previews: some View {
        KioskView(isKioskModeEnabled: .constant(true))
    }
}
