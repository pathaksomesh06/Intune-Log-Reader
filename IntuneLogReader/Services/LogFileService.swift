import Foundation
import SwiftUI

class LogFileService: ObservableObject {
    @Published var entries: [LogEntry] = []
    @Published var errorCount = 0
    @Published var warningCount = 0
    @Published var totalCount = 0
    @Published var isMonitoring = false
    @Published var hasNewErrors = false
    private var lastErrorCount = 0
    
    private var fileMonitor: DispatchSourceFileSystemObject?
    private var currentPath: String?
    
    func loadLogFile(from path: String, enableMonitoring: Bool = true) {
        entries.removeAll()
        currentPath = path
        
        guard let content = try? String(contentsOfFile: path, encoding: .utf8) else {
            print("Failed to read file at: \(path)")
            return
        }
        
        let lines = content.components(separatedBy: .newlines)
        
        for line in lines where !line.isEmpty {
            if let entry = parseIntuneLogLine(line) {
                entries.append(entry)
            }
        }
        
        updateCounts()
        
        if enableMonitoring {
            startMonitoring(path: path)
        }
        
        NotificationCenter.default.post(
            name: .fileLoaded,
            object: nil,
            userInfo: ["path": path]
        )
    }
    
    private func updateCounts() {
        totalCount = entries.count
        errorCount = entries.filter { $0.level == .error }.count
        warningCount = entries.filter { $0.level == .warning }.count
        checkForNewErrors()
    }
    
    private func checkForNewErrors() {
        let currentErrors = errorCount
        if currentErrors > lastErrorCount && lastErrorCount > 0 {
            hasNewErrors = true
            // Show system alert
            DispatchQueue.main.async {
                let alert = NSAlert()
                alert.messageText = "New Intune Errors"
                alert.informativeText = "\(currentErrors - self.lastErrorCount) new errors detected"
                alert.alertStyle = .warning
                alert.runModal()
            }
        }
        lastErrorCount = currentErrors
    }
    
    func detectPatterns() -> [(pattern: String, count: Int)] {
        let errors = entries.filter { $0.level == .error }
        let patterns = Dictionary(grouping: errors) { entry in
            // Extract error codes/patterns
            if let match = entry.message.range(of: #"0x[0-9A-Fa-f]{8}"#, options: .regularExpression) {
                return String(entry.message[match])
            }
            if let match = entry.message.range(of: #"Error:\s*([^,]+)"#, options: .regularExpression) {
                return String(entry.message[match])
            }
            return String(entry.message.prefix(50))
        }
        return patterns.map { ($0.key, $0.value.count) }
            .sorted { $0.1 > $1.1 }
            .prefix(5)
            .map { ($0.0, $0.1) }
    }
    
    func startMonitoring(path: String) {
        stopMonitoring()
        
        let fileDescriptor = open(path, O_EVTONLY)
        guard fileDescriptor >= 0 else { return }
        
        fileMonitor = DispatchSource.makeFileSystemObjectSource(
            fileDescriptor: fileDescriptor,
            eventMask: [.write, .extend],
            queue: DispatchQueue.main
        )
        
        fileMonitor?.setEventHandler { [weak self] in
            self?.reloadFile()
        }
        
        fileMonitor?.setCancelHandler {
            close(fileDescriptor)
        }
        
        fileMonitor?.resume()
        isMonitoring = true
    }
    
    func stopMonitoring() {
        fileMonitor?.cancel()
        fileMonitor = nil
        isMonitoring = false
    }
    
    private func reloadFile() {
        guard let path = currentPath else { return }
        loadLogFile(from: path, enableMonitoring: true)
    }
    
    private func parseIntuneLogLine(_ line: String) -> LogEntry? {
        // Format: 2025-07-22 16:16:26:133 | IntuneMDM-Daemon | I | 73077213 | ScriptOrchestrationLogger | Message
        let components = line.split(separator: "|").map { $0.trimmingCharacters(in: .whitespaces) }
        
        guard components.count >= 6 else { return nil }
        
        let dateStr = components[0]
        let process = components[1]
        let levelStr = components[2]
        let component = components[4]
        let message = components[5...].joined(separator: " | ")
        
        // Parse date (2025-07-22 16:16:26:133)
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss:SSS"
        
        guard let date = formatter.date(from: dateStr) else { return nil }
        
        // Map level
        let level: LogEntry.LogLevel
        switch levelStr {
        case "E": level = .error
        case "W": level = .warning
        case "I": level = .info
        case "D": level = .debug
        default: level = .info
        }
        
        return LogEntry(
            timestamp: date,
            level: level,
            component: "\(process) - \(component)",
            message: message,
            fullText: line
        )
    }
    
    func setAutoRefresh(_ enabled: Bool) {
        if enabled {
            if let path = currentPath {
                startMonitoring(path: path)
            }
        } else {
            stopMonitoring()
        }
    }
    
    deinit {
        stopMonitoring()
    }
}