import SwiftUI
struct AdminLoginScreen: View {
    var body: some View {
        NavigationStack {
            ZStack {
                Color(hex: "#175AA8")
                    .ignoresSafeArea()
                VStack {
                    // Top Section with Image and Text
                    topSection
                    
                    Spacer()
                    
                    // Main Section with Scanning Options
                    mainSection
                    
                    Spacer()
                    Spacer()
                    
                }
                .padding(.bottom, 20)
            }
            .navigationTitle("Admin Login")
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarBackButtonHidden(true)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    BackButton() // Assuming you have a BackButton view defined
                    
                }
                
            }
        }
        
    }
    private var topSection: some View {
        VStack(spacing: 10) {
            Image("adminLogin")
                .resizable()
                .scaledToFit()
                .frame(width: 120, height: 120)
                .padding(.top, 20)
                .shadow(radius: 10)
            
            Text("Welcome, Admin!")
                .font(.title)
                .fontWeight(.bold)
                .foregroundColor(.white)
            
            Text("Your system is secure and under  control.")
                .font(.subheadline)
                .foregroundColor(.white.opacity(0.9))
                .multilineTextAlignment(.center)
                .padding(.horizontal, 30)
                .padding(.bottom, 20)
            
        }
        .frame(maxWidth: .infinity)
        .padding(.horizontal, 20)
        .padding(.top,10)
        
        
    }
    
    private var mainSection: some View {
        VStack (spacing:5){
            // Individual navigation buttons
            NavigationButton(
                title: "Network Control",
                description: "Protect your network from threats.",
                destination: NetworkControl(),
                imageName: "shield",
                buttonColor: Color.blue.opacity(0.8)
            )
            
            NavigationButton(
                title: "Web Filter",
                description: "Filter unwanted websites.",
                destination: WebFilter(),
                imageName: "shield.lefthalf.fill",
                buttonColor: Color.blue.opacity(0.9)
            )
            
            NavigationButton(
                title: "App Manager",
                description: "Manage your installed apps.",
                destination: AppManager(),
                imageName: "apps.iphone",
                buttonColor: Color.blue.opacity(0.8)
            )
            
            NavigationButton(
                title: "Settings",
                description: "Adjust application preferences.",
                destination: SettingScreen(),
                imageName: "gearshape",
                buttonColor: Color.blue.opacity(0.8)
            )
        }
        .padding(.horizontal, 20)
    }
    
}
struct AdminLoginScreen_Previews: PreviewProvider {
    static var previews: some View {
        AdminLoginScreen()
    }
    
}
