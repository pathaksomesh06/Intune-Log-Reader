import Foundation
import SwiftUI

struct LogEntry: Identifiable, Hashable {
    let id = UUID()
    let timestamp: Date
    let level: LogLevel
    let component: String
    let message: String
    let fullText: String
    
    enum LogLevel: String {
        case error = "ERROR"
        case warning = "WARNING"
        case info = "INFO"
        case debug = "DEBUG"
        
        var color: Color {
            switch self {
            case .error: return .red
            case .warning: return .orange
            case .info: return .blue
            case .debug: return .gray
            }
        }
    }
}