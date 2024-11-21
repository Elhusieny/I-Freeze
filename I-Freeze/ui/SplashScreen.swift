import SwiftUI

import SwiftUI

struct SplashScreen: View {
    @State private var opacity = 0.0
    @State private var scale = 0.5

    var body: some View {
        ZStack{
            Color.darkBlue
                    .ignoresSafeArea()
            VStack {
                Image("logo") // Replace with your logo image name
                    .resizable()
                    .scaledToFit()
                    .frame(width: 200, height: 200)
                    .opacity(opacity)
                    .scaleEffect(scale)
                    .onAppear {
                        withAnimation(.easeIn(duration: 1.5)) {
                            opacity = 1.0
                            scale = 1.0
                        }
                    }
                Text("Freeze Your Risks")
                    .foregroundColor(.white)
                    
                    .bold().font(.title)
                   

            }
                   
            
        }
    }
}



struct SplashScreen_Previews: PreviewProvider {
    static var previews: some View {
        SplashScreen()
    }
}
