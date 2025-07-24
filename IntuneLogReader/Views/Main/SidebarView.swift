import SwiftUI

struct SidebarView: View {
    @ObservedObject var logService: LogFileService
    @State private var currentFileName = "No file loaded"
    
    var body: some View {
        List {
            Section("File") {
                HStack {
                    Image(systemName: "doc.text")
                    Text(currentFileName)
                        .lineLimit(1)
                }
                
                if logService.isMonitoring {
                    HStack {
                        Image(systemName: "dot.radiowaves.left.and.right")
                            .foregroundColor(.green)
                        Text("Live monitoring")
                            .font(.caption)
                            .foregroundColor(.green)
                    }
                }
            }
            
            Section("Quick Stats") {
                Label("Total: \(logService.totalCount)", systemImage: "list.bullet")
                Label("Errors: \(logService.errorCount)", systemImage: "exclamationmark.circle")
                    .foregroundColor(.red)
                Label("Warnings: \(logService.warningCount)", systemImage: "exclamationmark.triangle")
                    .foregroundColor(.orange)
            }
            
            if logService.totalCount > 0 {
                Section("Summary") {
                    VStack(alignment: .leading) {
                        Text("Error Rate: \(errorPercentage)%")
                            .font(.caption)
                        Text("Warning Rate: \(warningPercentage)%")
                            .font(.caption)
                    }
                }
                
                if logService.errorCount > 0 {
                    Section("Top Errors") {
                        ErrorSummaryView(logService: logService)
                    }
                }
            }
        }
        .listStyle(SidebarListStyle())
        .onReceive(NotificationCenter.default.publisher(for: .fileLoaded)) { notification in
            if let path = notification.userInfo?["path"] as? String {
                currentFileName = URL(fileURLWithPath: path).lastPathComponent
            }
        }
    }
    
    var errorPercentage: Int {
        guard logService.totalCount > 0 else { return 0 }
        return (logService.errorCount * 100) / logService.totalCount
    }
    
    var warningPercentage: Int {
        guard logService.totalCount > 0 else { return 0 }
        return (logService.warningCount * 100) / logService.totalCount
    }
}

extension Notification.Name {
    static let fileLoaded = Notification.Name("fileLoaded")
}