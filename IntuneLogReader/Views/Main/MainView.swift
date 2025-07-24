import SwiftUI
import UniformTypeIdentifiers

extension UTType {
    static let log = UTType(filenameExtension: "log", conformingTo: .plainText)!
}

struct MainView: View {
    @StateObject private var logService = LogFileService()
    @State private var fileAccessStatus = "No file loaded"
    @State private var selectedLogPath: String?
    @State private var autoRefresh = true
    @FocusState private var searchFieldFocused: Bool
    
    private let intuneLogPath = "/Library/Logs/Microsoft/Intune"
    
    var body: some View {
        NavigationSplitView {
            SidebarView(logService: logService)
                .navigationSplitViewColumnWidth(250)
        } content: {
            LogListView(logService: logService, searchFieldFocused: $searchFieldFocused)
                .navigationSplitViewColumnWidth(min: 500, ideal: 700, max: 900)
        } detail: {
            DetailView()
                .navigationSplitViewColumnWidth(250)
        }
        .toolbar {
            ToolbarItem(placement: .automatic) {
                Button("Load Latest Intune Log") {
                    loadLatestIntuneLog()
                }
                .keyboardShortcut("i", modifiers: [.command])
            }
            ToolbarItem(placement: .automatic) {
                Button("Browse...") {
                    openLogFile()
                }
                .keyboardShortcut("o", modifiers: [.command])
            }
            ToolbarItem(placement: .automatic) {
                Menu("Export") {
                    Button("Export All (CSV)") {
                        exportLogs(filtered: false)
                    }
                    .keyboardShortcut("e", modifiers: [.command, .shift])
                    
                    Button("Export Errors Only (CSV)") {
                        exportErrorsOnly()
                    }
                    
                    Divider()
                    
                    Button("Export Detailed Report") {
                        exportDetailedReport()
                    }
                }
                .disabled(logService.entries.isEmpty)
            }
            ToolbarItem(placement: .automatic) {
                Toggle("Auto-refresh", isOn: $autoRefresh)
                    .keyboardShortcut("r", modifiers: [.command])
            }
            ToolbarItem(placement: .automatic) {
                Text(fileAccessStatus)
                    .foregroundColor(.secondary)
            }
        }
        .onAppear {
            setupKeyboardShortcuts()
        }
        .onChange(of: autoRefresh) { newValue in
            logService.setAutoRefresh(newValue)
        }
    }
    
    func setupKeyboardShortcuts() {
        NSEvent.addLocalMonitorForEvents(matching: .keyDown) { event in
            if event.modifierFlags.contains(.command) && event.charactersIgnoringModifiers == "f" {
                searchFieldFocused = true
                return nil
            }
            if event.modifierFlags.contains(.command) && event.charactersIgnoringModifiers == "l" {
                loadLatestIntuneLog()
                return nil
            }
            return event
        }
    }
    
    func loadLatestIntuneLog() {
        let fm = FileManager.default
        
        guard fm.fileExists(atPath: intuneLogPath) else {
            fileAccessStatus = "❌ Intune folder not found"
            return
        }
        
        do {
            let files = try fm.contentsOfDirectory(atPath: intuneLogPath)
            let logFiles = files.filter { $0.hasSuffix(".log") }
            
            guard !logFiles.isEmpty else {
                fileAccessStatus = "❌ No log files found"
                return
            }
            
            // Get the latest modified log file
            var latestFile: String?
            var latestDate = Date.distantPast
            
            for file in logFiles {
                let filePath = "\(intuneLogPath)/\(file)"
                if let attributes = try? fm.attributesOfItem(atPath: filePath),
                   let modDate = attributes[.modificationDate] as? Date,
                   modDate > latestDate {
                    latestDate = modDate
                    latestFile = file
                }
            }
            
            if let latest = latestFile {
                let fullPath = "\(intuneLogPath)/\(latest)"
                selectedLogPath = fullPath
                fileAccessStatus = "✅ Loaded: \(latest)"
                logService.loadLogFile(from: fullPath)
            }
        } catch {
            fileAccessStatus = "❌ Error reading folder"
        }
    }
    
    func openLogFile() {
        let panel = NSOpenPanel()
        panel.allowsMultipleSelection = false
        panel.canChooseDirectories = false
        panel.allowedContentTypes = [.plainText, .log]
        panel.directoryURL = URL(fileURLWithPath: intuneLogPath)
        
        if panel.runModal() == .OK, let path = panel.url?.path {
            selectedLogPath = path
            fileAccessStatus = "✅ File loaded"
            logService.loadLogFile(from: path)
        }
    }
    
    func exportLogs(filtered: Bool) {
        let savePanel = NSSavePanel()
        savePanel.allowedContentTypes = [.commaSeparatedText]
        savePanel.nameFieldStringValue = "intune_logs_\(Int(Date().timeIntervalSince1970)).csv"
        
        if savePanel.runModal() == .OK, let url = savePanel.url {
            exportToCSV(logs: logService.entries, to: url)
        }
    }
    
    func exportErrorsOnly() {
        let savePanel = NSSavePanel()
        savePanel.allowedContentTypes = [.commaSeparatedText]
        savePanel.nameFieldStringValue = "intune_errors_\(Int(Date().timeIntervalSince1970)).csv"
        
        if savePanel.runModal() == .OK, let url = savePanel.url {
            let errorLogs = logService.entries.filter { $0.level == .error }
            exportToCSV(logs: errorLogs, to: url)
        }
    }
    
    func exportToCSV(logs: [LogEntry], to url: URL) {
        var csv = "Timestamp,Level,Component,Message\n"
        
        for log in logs {
            let timestamp = ISO8601DateFormatter().string(from: log.timestamp)
            let row = "\"\(timestamp)\",\"\(log.level.rawValue)\",\"\(log.component)\",\"\(log.message.replacingOccurrences(of: "\"", with: "\"\""))\"\n"
            csv += row
        }
        
        try? csv.write(to: url, atomically: true, encoding: .utf8)
    }
    
    func exportDetailedReport() {
        let savePanel = NSSavePanel()
        savePanel.allowedContentTypes = [.plainText]
        savePanel.nameFieldStringValue = "intune_report_\(Int(Date().timeIntervalSince1970)).txt"
        
        if savePanel.runModal() == .OK, let url = savePanel.url {
            let errorPatterns = logService.detectPatterns()
            let errorPercentage = logService.totalCount > 0 ? (logService.errorCount * 100) / logService.totalCount : 0
            let warningPercentage = logService.totalCount > 0 ? (logService.warningCount * 100) / logService.totalCount : 0
            
            var report = """
            INTUNE LOG ANALYSIS REPORT
            Generated: \(Date().formatted())
            File: \(selectedLogPath ?? "Unknown")
            
            ========== SUMMARY ==========
            Total Entries: \(logService.totalCount)
            Errors: \(logService.errorCount) (\(errorPercentage)%)
            Warnings: \(logService.warningCount) (\(warningPercentage)%)
            Info: \(logService.totalCount - logService.errorCount - logService.warningCount)
            
            ========== TOP ERROR PATTERNS ==========
            \(errorPatterns.map { "- \($0.pattern): \($0.count) occurrences" }.joined(separator: "\n"))
            
            ========== DETAILED ERROR LOG ==========
            """
            
            let errors = logService.entries.filter { $0.level == .error }
            for log in errors {
                report += "\n\(log.timestamp.formatted())\t[\(log.level.rawValue)]\t\(log.component)\t\(log.message)"
            }
            
            try? report.write(to: url, atomically: true, encoding: .utf8)
        }
    }
}