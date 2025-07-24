import SwiftUI

struct LogListView: View {
    @ObservedObject var logService: LogFileService
    @FocusState.Binding var searchFieldFocused: Bool
    @State private var searchText = ""
    @State private var selectedLevel = "All"
    @State private var selectedLog: LogEntry?
    @State private var showRawContent = false
    @State private var quickFilter = QuickFilter.all
    @FocusState private var listFocused: Bool
    
    enum QuickFilter: String, CaseIterable {
        case all = "All"
        case today = "Today"
        case errors = "Errors"
        case recent = "Recent (1hr)"
        
        var icon: String {
            switch self {
            case .all: return "list.bullet"
            case .today: return "calendar"
            case .errors: return "exclamationmark.circle"
            case .recent: return "clock"
            }
        }
    }
    
    var filteredLogs: [LogEntry] {
        var logs = logService.entries
        
        // Apply quick filter first
        switch quickFilter {
        case .all:
            break
        case .today:
            let calendar = Calendar.current
            let today = calendar.startOfDay(for: Date())
            logs = logs.filter { calendar.startOfDay(for: $0.timestamp) == today }
        case .errors:
            logs = logs.filter { $0.level == .error }
        case .recent:
            let oneHourAgo = Date().addingTimeInterval(-3600)
            logs = logs.filter { $0.timestamp > oneHourAgo }
        }
        
        // Apply level filter
        if selectedLevel != "All" {
            logs = logs.filter { $0.level.rawValue == selectedLevel }
        }
        
        // Apply search
        if !searchText.isEmpty {
            logs = logs.filter { 
                $0.message.localizedCaseInsensitiveContains(searchText) ||
                $0.component.localizedCaseInsensitiveContains(searchText)
            }
        }
        
        return logs
    }
    
    var body: some View {
        VStack(spacing: 0) {
            // Quick Filters
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 8) {
                    ForEach(Array(QuickFilter.allCases.enumerated()), id: \.element) { index, filter in
                        FilterChip(
                            title: filter.rawValue,
                            icon: filter.icon,
                            isSelected: quickFilter == filter,
                            shortcut: "⌘\(index + 1)"
                        ) {
                            quickFilter = filter
                        }
                    }
                }
                .padding(.horizontal)
            }
            .padding(.vertical, 8)
            
            // Filter Bar
            HStack {
                Picker("Level", selection: $selectedLevel) {
                    Text("All Levels").tag("All")
                    Text("Error").tag("ERROR")
                    Text("Warning").tag("WARNING")
                    Text("Info").tag("INFO")
                    Text("Debug").tag("DEBUG")
                }
                .pickerStyle(MenuPickerStyle())
                .frame(width: 120)
                
                Spacer()
                
                HStack {
                    Image(systemName: "magnifyingglass")
                        .foregroundColor(.secondary)
                    TextField("Search logs...", text: $searchText)
                        .textFieldStyle(PlainTextFieldStyle())
                        .focused($searchFieldFocused)
                }
                .padding(6)
                .background(Color.gray.opacity(0.1))
                .cornerRadius(8)
                .frame(maxWidth: 300)
                
                Text("\(filteredLogs.count) entries")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            .padding(.horizontal)
            .padding(.bottom, 8)
            
            Divider()
            
            // Log List with LazyVStack for performance
            ScrollViewReader { proxy in
                ScrollView {
                    LazyVStack(spacing: 0) {
                        ForEach(filteredLogs) { log in
                            LogRowView(log: log)
                                .id(log.id)
                                .background(selectedLog?.id == log.id ? Color.accentColor.opacity(0.1) : Color.clear)
                                .onTapGesture {
                                    selectedLog = log
                                    NotificationCenter.default.post(
                                        name: .logSelected,
                                        object: nil,
                                        userInfo: ["log": log]
                                    )
                                }
                            
                            Divider()
                        }
                    }
                }
                .overlay(alignment: .bottomTrailing) {
                    // Scroll to top button
                    if filteredLogs.count > 50 {
                        Button(action: {
                            withAnimation {
                                proxy.scrollTo(filteredLogs.first?.id, anchor: .top)
                            }
                        }) {
                            Image(systemName: "arrow.up.circle.fill")
                                .font(.title2)
                                .foregroundColor(.accentColor)
                                .background(Circle().fill(Color.white))
                        }
                        .padding()
                    }
                }
            }
        }
    }
}

struct FilterChip: View {
    let title: String
    let icon: String
    let isSelected: Bool
    var shortcut: String? = nil
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 4) {
                Image(systemName: icon)
                    .font(.caption)
                Text(title)
                    .font(.caption)
                if let shortcut = shortcut {
                    Text(shortcut)
                        .font(.caption2)
                        .foregroundColor(isSelected ? .white.opacity(0.7) : .secondary)
                }
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 6)
            .background(isSelected ? Color.accentColor : Color.gray.opacity(0.2))
            .foregroundColor(isSelected ? .white : .primary)
            .cornerRadius(15)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

struct LogRowView: View {
    let log: LogEntry
    
    var body: some View {
        HStack(alignment: .top, spacing: 8) {
            Circle()
                .fill(log.level.color)
                .frame(width: 8, height: 8)
                .padding(.top, 6)
            
            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Text(log.timestamp, format: .dateTime.hour().minute().second())
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    Text("[\(log.level.rawValue)]")
                        .font(.caption)
                        .foregroundColor(log.level.color)
                    
                    Text(log.component)
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .lineLimit(1)
                    
                    Spacer()
                }
                
                Text(log.message)
                    .font(.system(.body, design: .monospaced))
                    .lineLimit(2)
            }
        }
        .padding(.vertical, 8)
        .padding(.horizontal)
    }
}

extension Notification.Name {
    static let logSelected = Notification.Name("logSelected")
}