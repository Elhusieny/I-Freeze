import SwiftUI
struct SecurityScreen: View {
    @State private var showAlert = false
    @State private var alertMessage = ""
    @State private var scanResults: [ScanResult] = [
        ScanResult(title: "Scan All Security", icon: "shield.checkerboard", description: "Scan all your security settings.", color: .red, isSafe: nil),
        ScanResult(title: "Scan Device Security", icon: "shield", description: "Check Device For security threats.", color: .green, isSafe: nil),
        ScanResult(title: "Scan SMS Security", icon: "message", description: "Scan your sms for security risks.", color: .orange, isSafe: nil),
        ScanResult(title: "Scan Wi-Fi Security", icon: "wifi", description: "Check your Wi-Fi security.", color: .purple, isSafe: nil),
        ScanResult(title: "Scan Internet Security", icon: "globe", description: "Scan your internet security settings.", color: .yellow, isSafe: nil)
    ]
    
    var body: some View {
        ZStack {
            // Background Gradient
            Color(hex: "#175AA8")
                .ignoresSafeArea()
                VStack {
                ScrollView(.vertical)
                    {
                    // Title Section
                    Image(systemName: "shield.fill")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 80, height: 80)
                        .foregroundColor(.white)
                        .padding(.top, 40)
                    
                    Text("Security Checks")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                        .padding(.bottom, 20)
                    
                    // Security Buttons Section
                    let columns = [
                        GridItem(.flexible())
                    ]
                    
                    LazyVGrid(columns: columns, spacing: 10) {
                        // Button to Scan All Security
                        SecurityOptionButton(
                            title: "Scan All Security",
                            icon: scanResults[0].isSafe == true ? "checkmark.circle" : (scanResults[0].isSafe == false ? "xmark.circle" : "shield.checkerboard"),
                            description: scanResults[0].description,
                            color: .red,
                            action: scanAllSecurityAction,
                            uniqueStyle: true // To indicate it's a special button
                        ).padding(.horizontal,15)
                        
                        VStack{
                            Spacer()
                            // Individual Scan Options
                            ForEach(scanResults.dropFirst(), id: \.title) { result in
                                SecurityOptionButton(
                                    title: result.title,
                                    icon: result.isSafe == true ? "checkmark.circle" : (result.isSafe == false ? "xmark.circle" : result.icon),
                                    description: result.description,
                                    color: result.color,
                                    action: {
                                        scanIndividualSecurity(result: result)
                                        
                                    }
                                )
                                
                                .padding(.horizontal,10)
                                Spacer()
                                
                                
                                
                            }
                        }
                        .frame(maxWidth: .infinity)
                        .background(
                            Color.lightBlue.opacity(0.2)
                        )
                        .cornerRadius(20) // Apply corner radius
                        .padding(15)
                    }
                    .padding(.top, 20)
                    
                    Spacer()
                }
                .alert(isPresented: $showAlert) {
                    Alert(title: Text("Scan Results"), message: Text(alertMessage), dismissButton: .default(Text("OK")))
                }
                .navigationTitle("Security Screen")
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

    // Action for scanning all security options
    func scanAllSecurityAction() {
        for index in scanResults.indices {
            // Simulate scan results (replace with your actual scan logic)
            scanResults[index].isSafe = Bool.random() // This is where the scan result is set
            print("Scan result for \(scanResults[index].title): \(scanResults[index].isSafe!)") // Debugging output
        }
        alertMessage = "All security scans completed!"
        showAlert = true
    }

    // Individual scan action
    func scanIndividualSecurity(result: ScanResult) {
        if let index = scanResults.firstIndex(where: { $0.title == result.title }) {
            // Simulate scan result (replace with your actual scan logic)
            scanResults[index].isSafe = Bool.random() // This is where the scan result is set
            print("Scan result for \(scanResults[index].title): \(scanResults[index].isSafe!)") // Debugging output
        }
        alertMessage = "\(result.title) scan completed!"
        showAlert = true
    }
}

// Struct for scan results
struct ScanResult {
    let title: String
    let icon: String
    let description: String
    let color: Color
    var isSafe: Bool? // Optional to indicate unknown state initially
}

// Custom Button for Security Options with Description and Icon
struct SecurityOptionButton: View {
    let title: String
    let icon: String
    let description: String
    let color: Color
    let action: () -> Void
    var uniqueStyle: Bool = false // To differentiate the main scan button

    var body: some View {
        Button(action: action) {
            VStack(alignment: .leading, spacing: 5) {
                HStack {
                  
                    VStack(alignment: .leading) {
                        Text(title)
                            .font(.headline)
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                            .padding(.leading, 5)
                        Text(description)
                            .font(.subheadline)
                            .foregroundColor(.white.opacity(0.8))
                            .padding(.leading, 15)
                    }
                    Spacer()
                    Image(systemName: icon)
                        .resizable()
                        .frame(width: 20, height: 20)
                        .foregroundColor(color)
                        .padding(10)
                        .background(Circle().fill(Color.white))
                    
                }
                .padding()
                .frame(maxWidth: .infinity)  // Makes the button expand to full width
                .background(
                    LinearGradient(
                        gradient: Gradient(colors: [Color.lightBlue, Color.lightBlue.opacity(0.2)]),
                        startPoint: .leading,
                        endPoint: .trailing))
                .cornerRadius(10)
                .shadow(color: Color.black.opacity(0.4), radius: 5, x: 0, y: 2)
            }
        }
        .padding(.top, 10)
    }
}
 

struct SecurityScreen_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack {
            SecurityScreen()
        }
    }
}
