# ChatUI Demo App

This is a comprehensive demonstration of the ChatUI package features, showcasing all the implemented components and functionality.

## Features Demonstrated

### 🚀 **Core Chat Features**

- **Message Bubbles**: Text messages with proper styling and themes
- **Reactions**: Emoji reactions on messages (👍, 🎉, ❤️, etc.)
- **Message Editing**: Edit messages with edit history tracking
- **Reply System**: Reply to specific messages
- **Typing Indicators**: Real-time typing status

### 📎 **Rich Content Support**

- **Image Attachments**: Display images with thumbnails
- **Location Sharing**: Share and display location with address
- **File Attachments**: Support for various file types
- **Audio Messages**: Voice message support
- **Message Threads**: Threaded conversations

### 🎨 **Customization**

- **Custom Themes**: Multiple color schemes and styling options
- **Bubble Radius**: Customizable message bubble corner radius
- **Typography**: Custom text styles and fonts
- **Color Schemes**: Light and dark theme support

### 👥 **Advanced Features**

- **User Presence**: Online/offline status indicators
- **Contact Management**: Share and display contact cards
- **Polls & Voting**: Interactive polls with real-time results
- **Threading System**: Organize conversations in threads
- **Participant Management**: Role-based thread participation

## Running the Demo

### Prerequisites

- Flutter SDK (latest stable version)
- Dart SDK
- macOS, iOS, Android, or Web platform support

### Installation

1. Clone the repository
2. Navigate to the example directory:
   ```bash
   cd chatui/example
   ```
3. Get dependencies:
   ```bash
   flutter pub get
   ```
4. Run the demo:
   ```bash
   flutter run
   ```

### Available Platforms

- **macOS**: `flutter run -d macos`
- **iOS**: `flutter run -d ios` (requires iOS simulator or device)
- **Android**: `flutter run -d android` (requires Android emulator or device)
- **Web**: `flutter run -d chrome`

## Demo Content

The demo includes:

### Sample Messages

- Welcome message from Alice
- Progress update from the current user
- Response from Bob
- Location share from Alice (San Francisco coffee shop)
- Image attachment showing mockups
- Edited message example with edit history

### Sample Users

- **You** (Current User): The demo user
- **Alice Cooper**: Active user with avatar
- **Bob Smith**: Offline user demonstrating presence

### Interactive Features

- **Send Messages**: Type and send new messages
- **Add Reactions**: Tap and hold messages to react
- **Edit Messages**: Long press your own messages to edit
- **View Locations**: Tap location messages to see details
- **Image Gallery**: Tap images to view full size

## Code Structure

```
lib/
├── main.dart                 # Main demo application
└── (simplified structure)    # Focused on core functionality
```

The demo uses the ChatUI package components:

- `ChatView`: Main chat interface
- `MessageBubble`: Individual message display
- `ChatController`: Chat state management
- `InMemoryChatAdapter`: Demo data adapter
- `ChatThemeData`: Theming and styling

## Architecture Highlights

### Clean Architecture

- **Adapter Pattern**: Pluggable backend adapters
- **Controller Layer**: Business logic separation
- **Service Layer**: Feature-specific services
- **Widget Layer**: Reusable UI components

### Real-time Features

- **Stream-based Updates**: Reactive message streams
- **Event-driven Architecture**: Thread and service events
- **State Management**: ValueNotifier for reactive updates

### Extensibility

- **Custom Adapters**: Implement your own backend
- **Theme Customization**: Full theming support
- **Widget Composition**: Modular component design

## Next Steps

After exploring the demo:

1. **Integration**: Add the ChatUI package to your own app
2. **Customization**: Implement your own adapter and themes
3. **Backend**: Connect to your real chat backend
4. **Features**: Extend with additional message types
5. **Testing**: Use the comprehensive test suite

## Support

For more information:

- Check the main package documentation
- Review the source code in the `lib/` directory
- Run the test suite with `flutter test`
- Explore individual component examples

---

**ChatUI Package** - A comprehensive Flutter chat interface solution
