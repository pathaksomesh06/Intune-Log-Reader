import SwiftUI

struct ErrorSummaryView: View {
    @ObservedObject var logService: LogFileService
    
    var errorsByComponent: [(component: String, count: Int)] {
        let errors = logService.entries.filter { $0.level == .error }
        let grouped = Dictionary(grouping: errors) { $0.component }
        return grouped.map { ($0.key, $0.value.count) }
            .sorted { $0.1 > $1.1 }
            .prefix(10)
            .map { ($0.0, $0.1) }
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Error Summary")
                .font(.headline)
            
            if errorsByComponent.isEmpty {
                Text("No errors found")
                    .foregroundColor(.secondary)
            } else {
                ForEach(errorsByComponent, id: \.component) { item in
                    HStack {
                        Text(item.component)
                            .font(.caption)
                            .lineLimit(1)
                        Spacer()
                        Text("\(item.count)")
                            .font(.caption.monospacedDigit())
                            .foregroundColor(.red)
                    }
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(Color.red.opacity(0.1))
                    .cornerRadius(6)
                }
            }
        }
        .padding()
    }
}