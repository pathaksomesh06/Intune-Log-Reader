import SwiftUI

@main
struct IntuneLogReaderApp: App {
    var body: some Scene {
        WindowGroup {
            RootView()
        }
    }
}

struct RootView: View {
    @State private var showingWelcome = true
    
    var body: some View {
        Group {
            if showingWelcome {
                WelcomeView(showWelcome: $showingWelcome)
            } else {
                MainView()
                    .frame(minWidth: 1200, minHeight: 800)
            }
        }
        .onAppear {
            #if DEBUG
            // Force reset in debug
            showingWelcome = true
            #endif
        }
    }
}