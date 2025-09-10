# ChatUI Theme Customization

The ChatUI package now supports comprehensive theme customization, allowing developers to customize the appearance of chat components to match their app's design.

## Basic Usage

### Using Default Themes

```dart
import 'package:chat_interface/chat_interface.dart';

// Light theme
ChatInterface(
  controller: controller,
  config: ChatUiConfig(
    theme: ChatTheme.light(),
  ),
)

// Dark theme
ChatInterface(
  controller: controller,
  config: ChatUiConfig(
    theme: ChatTheme.dark(),
  ),
)

// Auto-generated theme from Material theme
ChatInterface(
  controller: controller,
  config: ChatUiConfig(
    theme: ChatTheme.fromMaterialTheme(Theme.of(context)),
  ),
)
```

### Custom Theme

```dart
ChatInterface(
  controller: controller,
  config: ChatUiConfig(
    theme: ChatTheme.light().copyWith(
      primaryColor: Colors.purple,
      sentMessageBackgroundColor: Colors.purple.shade600,
      receivedMessageBackgroundColor: Colors.grey.shade100,
      sendButtonColor: Colors.purple,
      messageBorderRadius: BorderRadius.circular(20),
      inputBorderRadius: BorderRadius.circular(30),
    ),
  ),
)
```

## Available Customizations

### Colors

- `primaryColor` - Primary color for the chat interface
- `secondaryColor` - Secondary color for the chat interface
- `backgroundColor` - Background color for the chat area
- `sentMessageBackgroundColor` - Background color for sent messages
- `receivedMessageBackgroundColor` - Background color for received messages
- `sentMessageTextColor` - Text color for sent messages
- `receivedMessageTextColor` - Text color for received messages
- `timestampColor` - Color for message timestamps
- `inputTextColor` - Color for input field text
- `inputBackgroundColor` - Background color for input field
- `inputBorderColor` - Border color for input field
- `sendButtonColor` - Color for send button
- `attachmentButtonColor` - Color for attachment buttons

### Text Styles

- `sentMessageTextStyle` - Text style for sent messages
- `receivedMessageTextStyle` - Text style for received messages
- `timestampTextStyle` - Text style for timestamps
- `inputTextStyle` - Text style for input field

### Layout

- `messageBorderRadius` - Border radius for message bubbles
- `inputBorderRadius` - Border radius for input field
- `messagePadding` - Padding for message bubbles
- `inputPadding` - Padding for input container
- `messageElevation` - Elevation for message bubbles
- `inputElevation` - Elevation for input container

## Examples

### WhatsApp-like Theme

```dart
final whatsappTheme = ChatTheme.light().copyWith(
  backgroundColor: Color(0xFFECE5DD),
  sentMessageBackgroundColor: Color(0xFF075E54),
  receivedMessageBackgroundColor: Colors.white,
  sendButtonColor: Color(0xFF075E54),
  messageBorderRadius: BorderRadius.circular(8),
);
```

### Telegram-like Theme

```dart
final telegramTheme = ChatTheme.light().copyWith(
  primaryColor: Color(0xFF0088CC),
  sentMessageBackgroundColor: Color(0xFF0088CC),
  receivedMessageBackgroundColor: Colors.white,
  sendButtonColor: Color(0xFF0088CC),
  messageBorderRadius: BorderRadius.circular(12),
);
```

### Discord-like Dark Theme

```dart
final discordTheme = ChatTheme.dark().copyWith(
  backgroundColor: Color(0xFF36393F),
  sentMessageBackgroundColor: Color(0xFF5865F2),
  receivedMessageBackgroundColor: Color(0xFF40444B),
  sendButtonColor: Color(0xFF5865F2),
  messageBorderRadius: BorderRadius.circular(8),
);
```

## Backwards Compatibility

The theme system is fully backwards compatible. If no theme is provided, the chat UI will automatically generate a theme based on your Material theme:

```dart
// This still works and will use auto-generated theme
ChatInterface(controller: controller)

// Same as above
ChatInterface(
  controller: controller,
  config: ChatUiConfig(), // No theme specified
)
```
