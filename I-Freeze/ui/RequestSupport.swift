import SwiftUI
struct RequestSupport: View {
    @State private var name: String = ""
    @State private var email: String = ""
    @State private var phone: String = ""
    @State private var description: String = ""
    @State private var showAlert: Bool = false
    @State private var alertMessage: String = ""
    @State private var isLoading: Bool = false // For loading state

    var body: some View {
        NavigationStack {
            ZStack {
                Color(hex: "#175AA8")
                    .ignoresSafeArea()
                VStack(spacing: 20) {
                    Spacer()
                    Text("Request Support")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .padding(.top, 20)
                        .foregroundColor(.white)

                    // Name TextField
                    TextField("Name", text: $name)
                        .fontWeight(.semibold)
                        .foregroundColor(.black)
                        .padding()
                        .background(Color.white.opacity(0.99))
                        .cornerRadius(10)
                        .padding(.horizontal, 20)

                    // Email TextField
                    TextField("Email", text: $email)
                        .fontWeight(.semibold)
                        .foregroundColor(.black)
                        .padding()
                        .background(Color.white.opacity(0.99))
                        .cornerRadius(10)
                        .padding(.horizontal, 20)
                        .keyboardType(.emailAddress)

                    // Phone TextField
                    TextField("Phone", text: $phone)                  .foregroundColor(.black)
                        .fontWeight(.semibold)
                        .padding()
                        .background(Color.white.opacity(0.99))
                        .cornerRadius(10)
                        .padding(.horizontal, 20)
                        .keyboardType(.phonePad)

                    // Description TextEditor for multiline input with placeholder
                   
                    // Description TextEditor with placeholder
                    ZStack(alignment: .topLeading) {
                        // TextEditor with background and padding
                        TextEditor(text: $description)
                            .background(Color.white.opacity(0.7))
                            .foregroundColor(.black) // Set text color to black
                            .padding() // Padding inside the TextEditor
                            .frame(height: 100) // Set a fixed height for the TextEditor
                            .cornerRadius(30) // Apply corner radius to TextEditor

                        // Placeholder text
                        if description.isEmpty {
                            Text("Description")
                                .foregroundColor(.black.opacity(0.5)) // Light color for the placeholder
                                .padding(.horizontal, 30) // Adjust to fit inside the TextEditor
                                .padding(.top, 30) // Align with TextEditor padding
                        }
                    }
                    .background(
                        LinearGradient(
                            gradient: Gradient(colors: [Color.lightBlue.opacity(0.9), Color.lightBlue.opacity(0.2)]),
                            startPoint: .leading,
                            endPoint: .trailing))
                    
                    .cornerRadius(10) // Apply corner radius to the outer container
                    .padding(.horizontal,20)
                    .shadow(color: Color.black.opacity(0.4), radius: 5, x: 0, y: 2)
                    // Submit Button
                    Spacer()
                    Button(action: submitSupportRequest) {
                        if isLoading {
                            ProgressView() // Show loading indicator when submitting
                        } else {
                            HStack{
                                Text("Submit")
                                    .fontWeight(.bold)
                                    .foregroundColor(.white)
                                Spacer()

                                Image(systemName: "plus.circle.fill")  // Add icon to button
                                    .foregroundColor(.blue)
                                    .font(.system(size: 20, weight: .bold))
                                
                            }
                            .padding()
                                .frame(maxWidth: .infinity)
                        // Makes the button expand to full width
                                .background(
                                    LinearGradient(
                                        gradient: Gradient(colors: [Color.lightBlue.opacity(0.9), Color.lightBlue.opacity(0.2)]),
                                        startPoint: .leading,
                                        endPoint: .trailing))
                                .cornerRadius(10)
                                .shadow(color: Color.black.opacity(0.2), radius: 5, x: 0, y: 2)
                                .padding(.horizontal,120)
                                .shadow(color: Color.black.opacity(0.4), radius: 5, x: 0, y: 2)

                        }
                  }
                    .disabled(isLoading) // Disable button while loading
                    .alert(isPresented: $showAlert) {
                        Alert(title: Text("Submission Status"), message: Text(alertMessage), dismissButton: .default(Text("OK")))
                    }
                    

                    Spacer()
                }
            }
            .navigationTitle("Request Support")
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarBackButtonHidden(true)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    BackButton()
                }
            }
        }
    }
    
    private func submitSupportRequest() {
        guard !name.isEmpty, !email.isEmpty, !phone.isEmpty, !description.isEmpty else {
            alertMessage = "All fields are required."
            showAlert = true
            return
        }

       

        // Load device ID from Keychain
        if var storedDeviceId = KeychainHelper.shared.load(key: "deviceId") {
            storedDeviceId = storedDeviceId.trimmingCharacters(in: .whitespacesAndNewlines)
            isLoading = true // Start loading

            let supportRequest = [
                "deviceId": storedDeviceId,
                "name": name,
                "email": email,
                "phone": phone,
                "description": description
            ]
            
            let url = URL(string: "https://security.flothers.com:8443/api/Ticket")!
            var request = URLRequest(url: url)
            request.httpMethod = "POST"
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
            do {
                let jsonData = try JSONSerialization.data(withJSONObject: supportRequest, options: [])
                request.httpBody = jsonData
                
                let task = URLSession.shared.dataTask(with: request) { data, response, error in
                    DispatchQueue.main.async {
                        isLoading = false // End loading
                        if let error = error {
                            alertMessage = "Failed to submit: \(error.localizedDescription)"
                        } else {
                            alertMessage = "Support request submitted successfully!"
                        }
                        showAlert = true
                    }
                }
                task.resume()
            } catch {
                alertMessage = "Failed to encode request: \(error.localizedDescription)"
                showAlert = true
            }
        }
    }

    // Email validation function
    private func isValidEmail(_ email: String) -> Bool {
        // Simple regex for email validation
        let emailRegex = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Z|a-z]{2,}"
        let predicate = NSPredicate(format: "SELF MATCHES %@", emailRegex)
        return predicate.evaluate(with: email)
    }
}
struct RequestSupport_Previews: PreviewProvider {
    static var previews: some View {
        RequestSupport()
    }
}
