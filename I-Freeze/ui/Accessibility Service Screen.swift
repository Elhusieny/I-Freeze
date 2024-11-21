import SwiftUI

struct AccessibilityServiceScreen: View {
    @Environment(\.presentationMode) var presentationMode

    var body: some View {
        NavigationStack {
            ZStack {
                Color(hex: "#175AA8")
                    .ignoresSafeArea()

                VStack {
                    // Top Image
                    Image(systemName: "figure.walk") // Example image for accessibility
                        .resizable()
                        .scaledToFit()
                        .frame(height: 200)
                        .foregroundColor(.white)
                    
                    // Instructional Text
                    Text("Enable accessibility service in settings for keeping your mobile safe.")
                        .font(.title2)
                        .foregroundColor(.white)
                        .padding()
                        .shadow(color: .black.opacity(0.80), radius: 5, x: 0, y: 2)
                    // Steps for enabling accessibility
                    VStack(alignment: .leading, spacing: 15) {
                        ForEach(1...3, id: \.self) { step in
                            HStack {
                                NumberedCircle(number: step)
                                Text(stepText(for: step))
                                    .foregroundColor(.white)
                                    .font(.body)
                            }
                        }
                    }.shadow(color: .black.opacity(0.80), radius: 5, x: 0, y: 2)
                    .padding()
                    
                    // Buttons
                    VStack(spacing: 15) {
                        Button(action: openAccessibilitySettings) {
                            HStack {
                                Text("Settings")
                                    .foregroundColor(.white).bold()
                                    .padding(.leading)
                                Spacer()
                                Image(systemName: "gear")
                                    .resizable()
                                    .frame(width: 24, height: 24)
                                    .foregroundColor(.white)
                            }.shadow(color: .black.opacity(0.80), radius: 5, x: 0, y: 2)
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(
                                LinearGradient(
                                    gradient: Gradient(colors: [Color.darkBlue, Color.lightBlue.opacity(0.7)]),
                                    startPoint: .leading,
                                    endPoint: .trailing))
                            .cornerRadius(10)
                            .padding(.horizontal, 60)
                            .shadow(color: Color.black.opacity(0.4), radius: 5, x: 0, y: 2)
                        }
                        .padding(.top, 40)

                        NavigationLink(destination: PermissionsNotifi_Locati_Photos_Phone()) {
                            HStack {
                                Text("Next ")
                                    .foregroundColor(.white).bold()
                                    .padding(.leading)
                                Spacer()
                                Image(systemName: "chevron.right")
                                    .resizable()
                                    .frame(width: 15, height: 15)
                                    .foregroundColor(.white)
                            }.shadow(color: .black.opacity(0.80), radius: 5, x: 0, y: 2)
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
                        .padding(.top, 2) // Adds top margin of 50 points from the previous content
                    }
                }
            }
            .navigationTitle("Accessibility Services") // Set the title of the navigation bar
            .navigationBarTitleDisplayMode(.inline) // Optional: set the title to display inline
            .navigationBarBackButtonHidden(true) // Hide the default back button
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    BackButton() // Add the custom back button
                }
            }
        }
    }
    
    private func stepText(for step: Int) -> String {
        switch step {
        case 1:
            return "Open Accessibility settings by tapping the setting button below."
        case 2:
            return "Tap Installed apps or Installed services and select i-Freeze Antivirus."
        case 3:
            return "Tap the toggle to give us permission."
        default:
            return ""
        }
    }

    private func openAccessibilitySettings() {
        if let url = URL(string: UIApplication.openSettingsURLString) {
            UIApplication.shared.open(url)
        }
    }
}

struct NumberedCircle: View {
    var number: Int

    var body: some View {
        Text("\(number)")
            .frame(width: 30, height: 30)
            .background(Color.white)
            .foregroundColor(.blue)
            .clipShape(Circle())
    }
}

struct BackButton: View {
    @Environment(\.presentationMode) var presentationMode

    var body: some View {
        Button(action: {
            presentationMode.wrappedValue.dismiss() // Navigate back to the previous screen
        }) {
            HStack(spacing: 0) { // Set spacing to 0
                
                Image(systemName: "chevron.left") // Custom back icon
                    .foregroundColor(.white) // Set color
                    .font(.system(size: 15)) // Set size
                Text("Back").foregroundColor(.white).bold()
                
            }
        }
    }
}

struct AccessibilityServiceScreen_Previews: PreviewProvider {
    static var previews: some View {
        AccessibilityServiceScreen()
    }
}
