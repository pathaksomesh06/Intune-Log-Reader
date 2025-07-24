# IntuneLogReader

A professional macOS tool for reading and analyzing Microsoft Intune MDM logs with real-time monitoring capabilities.

## Features

- **Real-time log monitoring** - Live monitoring of Intune log files with auto-refresh
- **Advanced search & filtering** - Powerful search and filtering by level, component, and text
- **Error analysis & insights** - Comprehensive error analysis with statistics and insights
- **Professional UI** - Clean, modern macOS interface with locked sidebars for optimal workflow
- **Welcome screen** - User-friendly onboarding experience
- **Export functionality** - Export logs to CSV format for further analysis
- **Keyboard shortcuts** - Full keyboard navigation support

## Screenshots

The application features a three-panel layout:
- **Left Sidebar**: File information and quick statistics
- **Center Panel**: Log list with filtering and search capabilities
- **Right Sidebar**: Detailed log entry information

## Installation

### Prerequisites
- macOS 15.5 or later
- Xcode 16.4 or later (for development)

### Building from Source
1. Clone the repository:
   ```bash
   git clone https://github.com/pathaksomesh06/Intune-Log-Reader.git
   cd Intune-Log-Reader
   ```

2. Open the project in Xcode:
   ```bash
   open IntuneLogReader.xcodeproj
   ```

3. Build and run the application (⌘+R)

## Usage

### First Launch
1. Launch the application
2. Click "Get Started" on the welcome screen
3. The app will remember your choice for future launches

### Loading Log Files
- **Load Latest Intune Log** (⌘+I): Automatically loads the most recent Intune log file
- **Browse...** (⌘+O): Manually select a log file from your system

### Filtering and Search
- **Quick Filters**: All, Today, Errors, Recent (1hr)
- **Level Filter**: Filter by Error, Warning, Info, Debug levels
- **Search**: Search through log messages and components
- **Real-time filtering**: Results update as you type

### Viewing Log Details
- Click on any log entry to view detailed information in the right sidebar
- Copy individual log entries or export them
- View full log text and formatted details

### Exporting Data
- **Export All** (⌘+Shift+E): Export all visible logs to CSV
- **Export Errors Only**: Export only error-level logs to CSV

## Keyboard Shortcuts

- `⌘+I`: Load Latest Intune Log
- `⌘+O`: Browse for log file
- `⌘+F`: Focus search field
- `⌘+L`: Load latest log
- `⌘+R`: Toggle auto-refresh
- `⌘+Shift+E`: Export all logs

## Technical Details

### Architecture
- **SwiftUI**: Modern declarative UI framework
- **NavigationSplitView**: Three-panel layout with fixed sidebar widths
- **File Monitoring**: Real-time log file monitoring using DispatchSource
- **UserDefaults**: Persistent user preferences

### Log Format Support
The application parses Intune log files with the following format:
```
2025-07-22 16:16:26:133 | IntuneMDM-Daemon | I | 73077213 | ScriptOrchestrationLogger | Message
```

### File Locations
- Intune logs are typically located at: `/Library/Logs/Microsoft/Intune/`
- The application automatically detects and loads the most recent log file

## Development

### Project Structure
```
IntuneLogReader/
├── App/
│   └── IntuneLogReaderApp.swift
├── Models/
│   └── LogEntry.swift
├── Services/
│   └── LogFileService.swift
├── Views/
│   ├── Main/
│   │   ├── MainView.swift
│   │   ├── SidebarView.swift
│   │   ├── LogListView.swift
│   │   └── DetailView.swift
│   └── WelcomeView.swift
└── Assets.xcassets/
```

### Key Components
- **LogFileService**: Handles log file parsing and real-time monitoring
- **LogEntry**: Data model for individual log entries
- **MainView**: Main application layout with NavigationSplitView
- **WelcomeView**: Onboarding experience

## Contributing

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add some amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## Author

**Somesh Pathak**
- GitHub: [@pathaksomesh06](https://github.com/pathaksomesh06)

## Acknowledgments

- Built for macOS administrators and IT professionals
- Designed to simplify Intune log analysis and troubleshooting
- Optimized for professional workflow with fixed sidebar layout 