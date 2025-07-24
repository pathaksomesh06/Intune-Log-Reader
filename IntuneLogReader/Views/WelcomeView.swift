import SwiftUI

struct WelcomeView: View {
    @Binding var showWelcome: Bool
    
    var body: some View {
        ZStack {
            // Background gradient
            LinearGradient(
                colors: [Color.blue.opacity(0.8), Color.purple.opacity(0.6)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            
            VStack(spacing: 40) {
                Spacer()
                
                // Logo
                Image(systemName: "doc.text.magnifyingglass")
                    .font(.system(size: 60))
                    .foregroundColor(.white)
                
                // Title
                VStack(spacing: 10) {
                    Text("IntuneLogReader")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                    
                    Text("Microsoft Intune Log Analysis")
                        .font(.headline)
                        .foregroundColor(.white.opacity(0.9))
                }
                
                Spacer()
                
                // Features
                VStack(spacing: 20) {
                    FeatureRow(icon: "bolt.fill", text: "Real-time log monitoring")
                    FeatureRow(icon: "magnifyingglass", text: "Advanced search & filtering")
                    FeatureRow(icon: "chart.line.uptrend.xyaxis", text: "Error analysis & insights")
                }
                .padding(.horizontal, 40)
                
                Spacer()
                
                // Get Started button - ALWAYS VISIBLE
                Button(action: {
                    #if !DEBUG
                    // Only save in production builds
                    UserDefaults.standard.set(true, forKey: "hasSeenWelcome")
                    #endif
                    showWelcome = false
                }) {
                    HStack(spacing: 8) {
                        Text("Get Started")
                            .fontWeight(.semibold)
                        Image(systemName: "arrow.right.circle.fill")
                    }
                    .foregroundColor(.blue)
                    .padding(.horizontal, 30)
                    .padding(.vertical, 15)
                    .background(Color.white)
                    .cornerRadius(30)
                    .shadow(radius: 10)
                }
                .buttonStyle(PlainButtonStyle())
                
                Spacer()
            }
        }
    }
}

struct FeatureRow: View {
    let icon: String
    let text: String
    
    var body: some View {
        HStack(spacing: 15) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(.white)
                .frame(width: 30)
            
            Text(text)
                .foregroundColor(.white.opacity(0.9))
            
            Spacer()
        }
    }
}
