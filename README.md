# Cue Collector - Flutter App

A comprehensive Flutter application for cue collection, asset management, activity tracking, and health management with voice recording capabilities and floating window overlay.

## Features

### 🔐 Authentication System
- **Sign Up/Sign In**: Local authentication with persistent sessions
- **User Management**: Profile management and secure logout

### 👥 People Management
- **People List**: View all added people with search functionality
- **Person Cards**: Clean card-based UI with creation timestamps
- **Add People**: Simple dialog to add new people

### 🧠 Cue System
- **Cue Types**: Three color-coded categories
  - **Conscious** (Blue): Deliberate, aware thoughts
  - **Subconscious** (Grey): Semi-conscious patterns
  - **Unconscious** (Deep Violet): Deep-seated behaviors
- **Voice Recording**: Record, pause, play, and stop audio cues
- **Cue Cards**: Visual representation with timestamps

### 💰 Asset Management
- **Asset Status**: Three progress states
  - **Red**: Yet to acquire
  - **Yellow**: On EMI (installments)
  - **Green**: Owned
- **Progress Tracking**: Visual progress bars with percentage completion
- **Amount Tracking**: Optional total and current amount fields

### 🏃 Activity Tracking
- **Activity Cards**: Grid-based activity selection
- **Current Activity**: Highlighted active activity with timestamps
- **Quick Activities**: Predefined activity suggestions
- **Activity Icons**: Smart icon selection based on activity names

### 📊 Review & Analytics
- **Charts & Graphs**: Visual data representation using FL Chart
  - Activity distribution pie chart
  - Asset progress bar chart
  - Cue type distribution
- **Timeline**: Recent actions with filtering options
- **Progress Tracking**: Historical data visualization

### 🎯 Floating Window (Overlay)
- **System Overlay**: T2S-style floating icon when app is minimized
- **Quick Access**: Fast cue, asset, and activity input
- **Expandable UI**: Compact icon expands to show options
- **Permissions**: Handles system alert window permissions

### 🗄️ Local Database
- **SQLite Integration**: Robust local data storage
- **Data Models**: Person, Cue, Asset, Activity entities
- **CRUD Operations**: Full create, read, update, delete functionality

## Technical Stack

### Frontend
- **Flutter**: Cross-platform mobile framework
- **Material Design 3**: Modern UI components
- **Provider**: State management solution
- **Go Router**: Navigation and routing

### Backend & Storage
- **SQLite**: Local database via sqflite package
- **Shared Preferences**: User session management
- **File System**: Audio file storage via path_provider

### Audio & Media
- **record**: Audio recording functionality
- **audioplayers**: Audio playback capabilities
- **permission_handler**: Runtime permissions

### Charts & Visualization
- **fl_chart**: Beautiful charts and graphs
- **percent_indicator**: Progress indicators

### System Integration
- **flutter_overlay_window**: Floating window overlay
- **System Alert Window**: Overlay permissions

## Project Structure

```
lib/
├── main.dart                 # App entry point
├── models/                   # Data models
│   ├── person.dart
│   ├── cue.dart
│   ├── asset.dart
│   └── activity.dart
├── providers/                # State management
│   ├── auth_provider.dart
│   └── data_provider.dart
├── screens/                  # Main screens
│   ├── auth/
│   │   └── auth_screen.dart
│   ├── main/
│   │   └── main_screen.dart
│   └── person/
│       └── person_detail_screen.dart
├── services/                 # Business logic
│   ├── database_service.dart
│   └── floating_window_service.dart
└── widgets/                  # Reusable components
    ├── person_card.dart
    ├── cue_section.dart
    ├── assets_section.dart
    ├── activity_section.dart
    ├── review_section.dart
    └── [various dialogs and components]
```

## Setup Instructions

### Prerequisites
- Flutter SDK (3.0.0 or higher)
- Android Studio or VS Code
- Android SDK (API level 24+)
- Git

### Installation

1. **Clone the repository**
   ```bash
   git clone <repository-url>
   cd AppF1
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Configure Android permissions**
   The app requires the following permissions (already configured):
   - `RECORD_AUDIO`: For voice recording
   - `SYSTEM_ALERT_WINDOW`: For floating window overlay
   - `WRITE_EXTERNAL_STORAGE`: For audio file storage
   - `INTERNET`: For potential future features

4. **Run the application**
   ```bash
   flutter run
   ```

### Development Setup

1. **Enable developer options** on your Android device
2. **Enable USB debugging**
3. **Connect device** or start an emulator
4. **Run in debug mode**:
   ```bash
   flutter run --debug
   ```

## Usage Guide

### Getting Started
1. **Launch the app** and create an account or sign in
2. **Add people** using the floating action button on the main screen
3. **Select a person** to access their detailed view with tabs

### Adding Cues
1. Navigate to the **Cue tab** in person detail view
2. Use **voice recording controls** to record audio cues
3. **Add text cues** using the floating action button
4. **Select cue type** (Conscious/Subconscious/Unconscious)

### Managing Assets
1. Go to the **Assets tab**
2. **Add new assets** with status and optional amounts
3. **Update progress** by tapping the edit icon on asset cards
4. **Track completion** with visual progress bars

### Activity Tracking
1. Visit the **Activity tab**
2. **Add activities** using predefined suggestions or custom names
3. **Set current activity** by tapping on activity cards
4. **Monitor active status** with highlighted current activity

### Review & Analytics
1. Check the **Review tab** for data visualization
2. **Filter data** by type (All/Cue/Assets/Activity)
3. **View charts** showing distribution and progress
4. **Browse timeline** of recent actions

### Floating Window
1. **Exit the app** to activate floating window
2. **Tap the floating icon** to expand quick access menu
3. **Add quick cues, assets, or activities** without opening main app
4. **Collapse back** to floating icon when done

## Permissions

The app requests the following permissions:

| Permission | Purpose | Required |
|------------|---------|----------|
| Microphone | Voice recording for cues | Yes |
| Storage | Save audio files | Yes |
| System Alert Window | Floating overlay window | Optional |
| Internet | Future cloud sync features | No |

## Database Schema

### People Table
- `id`: Unique identifier
- `name`: Person's name
- `created_at`: Creation timestamp
- `updated_at`: Last modification timestamp

### Cues Table
- `id`: Unique identifier
- `person_id`: Foreign key to people
- `type`: Cue type (conscious/subconscious/unconscious)
- `content`: Text content
- `audio_path`: Path to audio file (optional)
- `created_at`: Creation timestamp

### Assets Table
- `id`: Unique identifier
- `person_id`: Foreign key to people
- `name`: Asset name
- `status`: Status (yetToAcquire/onEmi/owned)
- `progress`: Completion percentage
- `total_amount`: Total cost (optional)
- `current_amount`: Current paid amount
- `created_at`: Creation timestamp

### Activities Table
- `id`: Unique identifier
- `person_id`: Foreign key to people
- `name`: Activity name
- `is_current`: Boolean for active status
- `started_at`: Start timestamp (optional)
- `ended_at`: End timestamp (optional)
- `created_at`: Creation timestamp

## Contributing

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

## Troubleshooting

### Common Issues

**Audio recording not working:**
- Ensure microphone permission is granted
- Check device audio settings
- Restart the app if needed

**Floating window not appearing:**
- Grant "Display over other apps" permission in Android settings
- Check if battery optimization is disabled for the app

**Database errors:**
- Clear app data and restart
- Ensure sufficient storage space

**Performance issues:**
- Close background apps
- Restart the device
- Check available RAM

## Future Enhancements

- [ ] Cloud synchronization
- [ ] Export/Import data functionality
- [ ] Advanced analytics and insights
- [ ] Notification reminders
- [ ] Dark theme support
- [ ] Multi-language support
- [ ] Voice-to-text transcription
- [ ] Social sharing features

## License

This project is licensed under the MIT License - see the LICENSE file for details.

## Support

For support, please open an issue in the GitHub repository or contact the development team.

---

**Built with ❤️ using Flutter**
