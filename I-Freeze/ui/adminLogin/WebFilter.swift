import SwiftUI
import WebKit

struct WebFilter: View {
    @State private var blockUrls = false
    @State private var whitelistUrls = false
    @State private var newUrl = ""  // Input field for adding to whitelist
    @State private var whitelistedUrls: [String] = []  // List of whitelisted URLs

    var body: some View {
        NavigationStack {
            ZStack(alignment: .top) {
                Color(hex: "#175AA8")
                    .ignoresSafeArea()
                
                VStack(spacing: 20) {
                    // Block URLs Section
                    controlBlock(
                        title: "Block URLs",
                        icon: blockUrls ? "globe.slash" : "globe",
                        text: blockUrls ? "URL Blocking Enabled" : "Enable URL Blocking",
                        description: "Blocks access to specified URLs.",
                        isOn: $blockUrls,
                        backgroundColor: Color.red
                    )
                    .padding(.top, 30)
                    .onChange(of: blockUrls) { newValue in
                        UserDefaults.standard.set(newValue, forKey: "isBlockUrlsEnabled")
                        // Implement URL blocking logic here
                    }
                    
                    // Whitelist URLs Section
                    controlBlock(
                        title: "Whitelist URLs",
                        icon: whitelistUrls ? "checkmark.circle.fill" : "circle",
                        text: whitelistUrls ? "Whitelist Enabled" : "Enable URL Whitelist",
                        description: "Only whitelisted URLs are accessible.",
                        isOn: $whitelistUrls,
                        backgroundColor: Color.blue
                    )
                    .onChange(of: whitelistUrls) { newValue in
                        UserDefaults.standard.set(newValue, forKey: "isWhitelistUrlsEnabled")
                    }
                    
                    // URL Input Section
                    if whitelistUrls {
                        VStack(spacing: 15) {
                            TextField("Enter URL to Whitelist", text: $newUrl)
                                .padding()
                                .background(
                                    LinearGradient(
                                        gradient: Gradient(colors: [Color.lightBlue, Color.lightBlue.opacity(0.2)]),
                                        startPoint: .leading,
                                        endPoint: .trailing))                                .cornerRadius(8)
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                                .overlay(
                                    RoundedRectangle(cornerRadius: 8)
                                        .stroke(Color.gray.opacity(0.5), lineWidth: 1)
                                )
                            
                            Button(action: addUrlToWhitelist) {
                                HStack {
                                    Text("Add to Whitelist")
                                        .fontWeight(.semibold)
                                        .foregroundColor(.white)
                                    Spacer()
                                    
                                    Image(systemName: "plus.circle.fill")  // Add icon to button
                                        .foregroundColor(.blue)
                                        .font(.system(size: 20, weight: .bold))
                                    
                                }
                                .padding()
                                .frame(maxWidth: .infinity)  // Makes the button expand to full width
                                .background(
                                    LinearGradient(
                                        gradient: Gradient(colors: [Color.lightBlue, Color.lightBlue.opacity(0.2)]),
                                        startPoint: .leading,
                                        endPoint: .trailing))
                                .cornerRadius(10)
                                .shadow(color: Color.black.opacity(0.2), radius: 5, x: 0, y: 2)
                            }
                            .padding(.top, 10)
                            .padding(.horizontal,40)
                        }
                        .padding(.top, 10)
                    }
                }
                .padding(.horizontal, 10)
                .padding(.top, 20)
                .shadow(color: Color.black.opacity(0.4), radius: 5, x: 0, y: 2)
            }
            .navigationTitle("URL Control")
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarBackButtonHidden(true)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    BackButton()
                }
            }
        }
    }

    // Helper function to add a URL to the whitelist
    private func addUrlToWhitelist() {
        if !newUrl.isEmpty {
            whitelistedUrls.append(newUrl)
            newUrl = ""
        }
    }

    // Control block UI component, reused for both Block URLs and Whitelist URLs sections
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
        .background(
            LinearGradient(
                gradient: Gradient(colors: [Color.lightBlue, Color.lightBlue.opacity(0.2)]),
                startPoint: .leading,
                endPoint: .trailing))
        .cornerRadius(15)
    }
}

struct WebFilter_Previews: PreviewProvider {
    static var previews: some View {
        WebFilter()
    }
}
