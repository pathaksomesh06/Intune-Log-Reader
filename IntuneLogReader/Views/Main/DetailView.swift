import SwiftUI

struct DetailView: View {
    @State private var selectedLog: LogEntry?
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            if let log = selectedLog {
                // Header
                Text("Log Entry Details")
                    .font(.headline)
                
                // Timestamp
                Group {
                    Text("Timestamp")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    Text(log.timestamp.formatted(date: .abbreviated, time: .standard))
                        .font(.system(.body, design: .monospaced))
                }
                
                // Level
                Group {
                    Text("Level")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    HStack {
                        Circle()
                            .fill(log.level.color)
                            .frame(width: 10, height: 10)
                        Text(log.level.rawValue)
                            .foregroundColor(log.level.color)
                            .font(.system(.body, design: .monospaced))
                    }
                }
                
                // Component
                Group {
                    Text("Component")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    Text(log.component)
                        .font(.system(.body, design: .monospaced))
                }
                
                // Message
                Group {
                    Text("Message")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    Text(log.message)
                        .font(.system(.body, design: .monospaced))
                        .textSelection(.enabled)
                }
                
                Divider()
                
                // Full Text
                Group {
                    Text("Full Log Entry")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    ScrollView {
                        Text(log.fullText)
                            .font(.system(.caption, design: .monospaced))
                            .textSelection(.enabled)
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }
                    .frame(maxHeight: 100)
                    .background(Color.gray.opacity(0.1))
                    .cornerRadius(4)
                }
                
                // Actions
                HStack {
                    Button("Copy") {
                        NSPasteboard.general.clearContents()
                        NSPasteboard.general.setString(log.fullText, forType: .string)
                    }
                    .buttonStyle(.bordered)
                    
                    Button("Export") {
                        exportLog()
                    }
                    .buttonStyle(.bordered)
                }
                
                Spacer()
            } else {
                Text("Log Details")
                    .font(.headline)
                
                Text("Select a log entry to view details")
                    .foregroundColor(.secondary)
                
                Spacer()
            }
        }
        .padding()
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        .onReceive(NotificationCenter.default.publisher(for: .logSelected)) { notification in
            if let log = notification.userInfo?["log"] as? LogEntry {
                selectedLog = log
            }
        }
    }
    
    func exportLog() {
        guard let log = selectedLog else { return }
        
        let savePanel = NSSavePanel()
        savePanel.allowedContentTypes = [.plainText]
        savePanel.nameFieldStringValue = "log_entry_\(log.timestamp.timeIntervalSince1970).txt"
        
        if savePanel.runModal() == .OK, let url = savePanel.url {
            try? log.fullText.write(to: url, atomically: true, encoding: .utf8)
        }
    }
}