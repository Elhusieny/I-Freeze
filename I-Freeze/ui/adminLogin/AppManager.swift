import SwiftUI

struct AppManager: View {
    @State private var blockApps = false
    @State private var whitelistApps = false
    @State private var newAppName = ""
    @State private var whitelistedApps: [String] = []  // List of allowed apps
    @State private var restrictedApps: [String] = ["Facebook", "Instagram"]  // List of restricted apps

    var body: some View {
        
        
        NavigationStack {
            ZStack(alignment: .top) {
                Color(hex: "#175AA8")
                    .ignoresSafeArea()
                ScrollView(.vertical)
                {
                    VStack(spacing: 20) {
                        // Block Apps Section
                        controlBlock(
                            title: "Block Apps",
                            icon: blockApps ? "app.fill" : "app",
                            text: blockApps ? "App Blocking Enabled" : "Enable App Blocking",
                            description: "Blocks access to specified apps.",
                            isOn: $blockApps,
                            backgroundColor: Color.blue
                        )
                        .padding(.top, 30)
                        .onChange(of: blockApps) { newValue in
                            // Implement app blocking logic
                            updateRestrictedApps()
                        }
                        
                        // Whitelist Apps Section
                        controlBlock(
                            title: "Whitelist Apps",
                            icon: whitelistApps ? "checkmark.circle.fill" : "circle",
                            text: whitelistApps ? "Whitelist Enabled" : "Enable App Whitelist",
                            description: "Only whitelisted apps are accessible.",
                            isOn: $whitelistApps,
                            backgroundColor: Color.blue
                        )
                        .onChange(of: whitelistApps) { newValue in
                            // Handle whitelist apps toggling
                            if newValue { updateWhitelistedApps() }
                        }
                        
                        // App Input Section for adding to whitelist
                        if whitelistApps {
                            VStack(spacing: 15) {
                                TextField("Enter App Name to Whitelist", text: $newAppName)
                                    .padding()
                                    .background(Color.white.opacity(0.7))
                                    .cornerRadius(8)
                                    .textFieldStyle(RoundedBorderTextFieldStyle())
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 8)
                                            .stroke(Color.gray.opacity(0.5), lineWidth: 1)
                                    )
                                
                                Button(action: addAppToWhitelist) {
                                    HStack {
                                        Text("Add to Whitelist")
                                            .fontWeight(.semibold)
                                            .foregroundColor(.white)
                                        Spacer()
                                        
                                        Image(systemName: "plus.circle.fill")
                                            .foregroundColor(.blue)
                                            .font(.system(size: 22, weight: .bold))
                                        
                                    }
                                    .padding()
                                    .frame(maxWidth: .infinity)
                                    .background(
                                        LinearGradient(
                                            gradient: Gradient(colors: [Color.darkBlue, Color.white.opacity(0.7)]),
                                            startPoint: .leading,
                                            endPoint: .trailing
                                        )
                                    )
                                    .cornerRadius(10)
                                    .shadow(color: Color.black.opacity(0.2), radius: 5, x: 0, y: 2)
                                }
                                .padding(.top, 10)
                                .padding(.horizontal, 40)
                            }
                            .padding(.top, 10)
                        }
                        
                        // Display whitelisted apps
                        if whitelistApps {
                            VStack(alignment: .leading) {
                                Text("Whitelisted Apps:")
                                    .font(.headline)
                                    .foregroundColor(.white)
                                    .padding(.top, 20)
                                
                                ForEach(whitelistedApps, id: \.self) { app in
                                    Text(app)
                                        .foregroundColor(.white)
                                }
                            }
                        }
                    }
                    .padding(.horizontal, 10)
                    .padding(.top, 20)
                    .shadow(color: Color.black.opacity(0.4), radius: 5, x: 0, y: 2)
                }
                .navigationTitle("App Control")
                .navigationBarTitleDisplayMode(.inline)
                .navigationBarBackButtonHidden(true)
                .toolbar {
                    ToolbarItem(placement: .navigationBarLeading) {
                        BackButton() // Assuming you have a BackButton view defined
                    }
                }
            }
        }
    }
    // Function to add an app to the whitelist
    private func addAppToWhitelist() {
        if !newAppName.isEmpty {
            whitelistedApps.append(newAppName)
            newAppName = ""
        }
    }

    // Function to update restricted apps (called when blockApps changes)
    private func updateRestrictedApps() {
        if blockApps {
            restrictedApps = ["Facebook", "Instagram", "Twitter"]
        } else {
            restrictedApps.removeAll()
        }
    }

    // Function to handle whitelisted apps toggling
    private func updateWhitelistedApps() {
        if whitelistApps {
            whitelistedApps = ["Safari", "Settings"]
        } else {
            whitelistedApps.removeAll()
        }
    }
    
    // Control block UI component
    private func controlBlock(title: String, icon: String, text: String, description: String, isOn: Binding<Bool>, backgroundColor: Color) -> some View {
        VStack(spacing: 12) {
            Text(title)
                .font(.headline)
                .foregroundColor(.white)
                .padding(.bottom, 5)

            HStack {
                Image(systemName: icon)
                    .foregroundColor(.white)
                Text(text)
                    .foregroundColor(.white)
                    .fontWeight(.bold)

                Spacer()
                Toggle("", isOn: isOn)
                    .toggleStyle(SwitchToggleStyle(tint: backgroundColor))
                    .labelsHidden()
            }
            .padding()
            .background(Color.white.opacity(0.3))
            .cornerRadius(15)

            Text(description)
                .font(.subheadline)
                .foregroundColor(.white)
                .padding(.top, 5)
        }
        .padding(20)
        .background(Color.white.opacity(0.3))
        .cornerRadius(15)
    }
}

struct AppManager_Previews: PreviewProvider {
    static var previews: some View {
        AppManager()
    }
}
