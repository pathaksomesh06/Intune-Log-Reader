# IntuneLogReader

A macOS tool for reading and analyzing Microsoft Intune MDM logs with real-time monitoring capabilities.

## Features

- **Real-time log monitoring** - Live monitoring of Intune log files with auto-refresh
- **Advanced search & filtering** - Powerful search and filtering by level, component, and text
- **Error analysis & insights** - Comprehensive error analysis with statistics and insights
- **Professional UI** - Clean, modern macOS interface with locked sidebars for optimal workflow
- **Welcome screen** - User-friendly onboarding experience
- **Export functionality** - Export logs to CSV format for further analysis
- **Keyboard shortcuts** - Full keyboard navigation support

## Screenshots
<img width="1312" height="964" alt="Screenshot 2025-07-24 at 13 42 12" src="https://github.com/user-attachments/assets/4e2298c5-bcab-4e98-af97-4a9ad0d2d063" />
<img width="1312" height="964" alt="Screenshot 2025-07-24 at 13 42 15" src="https://github.com/user-attachments/assets/b2d5784d-167b-4a1a-a4f4-5e369afcc358" />
<img width="1312" height="964" alt="Screenshot 2025-07-24 at 13 42 46" src="https://github.com/user-attachments/assets/eb70bb98-150e-4cb0-818d-3be6935b8649" />
<img width="1191" height="841" alt="Screenshot 2025-07-24 at 13 42 59" src="https://github.com/user-attachments/assets/4f2bf60a-521e-4733-8d62-5b231ff40476" />
<img width="1312" height="964" alt="Screenshot 2025-07-24 at 13 43 10" src="https://github.com/user-attachments/assets/cc0a4048-b55a-44ed-8002-8ddea8f7f4e5" />
<img width="1312" height="964" alt="Screenshot 2025-07-24 at 13 43 33" src="https://github.com/user-attachments/assets/fa885a2b-8600-40df-92b8-57f79720b5d5" />

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


### Key Components
- **LogFileService**: Handles log file parsing and real-time monitoring
- **LogEntry**: Data model for individual log entries
- **MainView**: Main application layout with NavigationSplitView
- **WelcomeView**: Onboarding experience


## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## Author

**Somesh Pathak**
- GitHub: [@pathaksomesh06](https://github.com/pathaksomesh06)

## Acknowledgments

- Built for macOS administrators and IT professionals
- Designed to simplify Intune log analysis and troubleshooting
- Optimized for professional workflow with fixed sidebar layout 
