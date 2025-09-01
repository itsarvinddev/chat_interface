import 'dart:async';

import 'package:chatui/chatui.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_keyboard_visibility/flutter_keyboard_visibility.dart';
import 'package:flutter_screwdriver/flutter_screwdriver.dart';

import 'bottom_inset.dart';
import 'chat_field.dart';
import 'emoji_picker.dart';

// class ChatTextField extends StatelessWidget {
//   final ChatController controller;
//   final Future<bool> Function(ChatMessage message)? onSend;
//   const ChatTextField({super.key, required this.controller, this.onSend});

//   @override
//   Widget build(BuildContext context) {
//     Future<void> sendMessage(String value) async {
//       if (value.trim().isNullOrEmpty) return;
//       final isAction = value.trim().startsWith('/');
//       final message = ChatMessage(
//         message: value.trim(),
//         senderId: controller.currentUser.id,
//         type: isAction ? ChatMessageType.action : ChatMessageType.chat,
//         status: ChatMessageStatus.sent,
//         id: DateTime.now().millisecondsSinceEpoch.toString(),
//         roomId: "63e2364b-e0b5-4b30-b392-595944f2955b",
//         createdAt: DateTime.now(),
//       )..sender = controller.currentUser;
//       controller.addMessage(message);
//       final result = await onSend?.call(message);
//       if (result == true) {
//         message.status = ChatMessageStatus.delivered;
//         controller.updateMessage(message);
//       }
//       controller.messageController.clear();
//     }

//     return Container(
//       color: context.theme.appBarTheme.backgroundColor,
//       child: SafeArea(
//         child: Padding(
//           padding: const EdgeInsets.all(8.0),
//           child: TextField(
//             controller: controller.messageController,
//             minLines: 1,
//             maxLines: 5,
//             keyboardType: TextInputType.multiline,
//             textInputAction: TextInputAction.newline,
//             decoration: InputDecoration(
//               border: OutlineInputBorder(
//                 borderRadius: BorderRadius.circular(10),
//               ),
//               hintText: 'Type a message',
//               suffixIcon: IconButton(
//                 icon: const Icon(Icons.send),
//                 onPressed: () =>
//                     sendMessage(controller.messageController.text.trim()),
//               ),
//             ),
//             onSubmitted: sendMessage,
//           ),
//         ),
//       ),
//     );
//   }
// }

class ChatInputContainer extends StatefulWidget {
  final ChatController controller;
  const ChatInputContainer({super.key, required this.controller});

  @override
  State<ChatInputContainer> createState() => _ChatInputContainerState();
}

class _ChatInputContainerState extends State<ChatInputContainer>
    with WidgetsBindingObserver {
  bool isKeyboardVisible = false;
  late final StreamSubscription<bool> _keyboardSubscription;
  late final ControllerProvider controllerProvider = ControllerProvider(
    controller: widget.controller,
  );

  @override
  void initState() {
    controllerProvider.initRecorder();
    _keyboardSubscription = KeyboardVisibilityController().onChange.listen((
      isVisible,
    ) async {
      isKeyboardVisible = isVisible;
      if (isVisible) {
        controllerProvider.setShowEmojiPicker(false);
      }
      setState(() {});
    });

    super.initState();
  }

  @override
  void dispose() async {
    super.dispose();
    _keyboardSubscription.cancel();
  }

  void switchKeyboards() async {
    final showEmojiPicker = controllerProvider.showEmojiPicker;

    if (!showEmojiPicker && !isKeyboardVisible) {
      controllerProvider.setShowEmojiPicker(true);
    } else if (showEmojiPicker) {
      controllerProvider.fieldFocusNode.requestFocus();
      SystemChannels.textInput.invokeMethod('TextInput.show');
      Future.delayed(const Duration(milliseconds: 300), () {
        if (!mounted || showEmojiPicker) return;
        controllerProvider.setShowEmojiPicker(false);
      });
    } else if (isKeyboardVisible) {
      SystemChannels.textInput.invokeMethod('TextInput.hide');
      controllerProvider.setShowEmojiPicker(true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorTheme = context.theme.colorScheme;
    final hideElements = controllerProvider.hideElements;
    // final recordingState = ref.watch(
    //   chatControllerProvider.select((s) => s.recordingState),
    // );
    final showEmojiPicker = controllerProvider.showEmojiPicker;

    return Theme(
      data: Theme.of(context).copyWith(
        iconTheme: IconThemeData(
          color: Theme.of(context).brightness == Brightness.light
              ? colorTheme.onSurface
              : colorTheme.primary,
        ),
      ),
      child: AvoidBottomInset(
        padding: EdgeInsets.only(
          bottom: defaultTargetPlatform.isAndroid ? 4.0 : 24.0,
        ),
        conditions: [showEmojiPicker],
        offstage: Offstage(
          offstage: !showEmojiPicker,
          child: CustomEmojiPicker(
            afterEmojiPlaced: (emoji) =>
                controllerProvider.onTextChanged(emoji.emoji),
            textController: controllerProvider.controller.messageController,
          ),
        ),
        child:
            // recordingState != RecordingState.recordingLocked &&
            //     recordingState != RecordingState.paused
            // ?
            SafeArea(
              bottom: defaultTargetPlatform.isAndroid,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 5.0),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Expanded(
                      child: Container(
                        margin: const EdgeInsets.only(left: 3.0, top: 4.0),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(24.0),
                          color: Theme.of(context).brightness == Brightness.dark
                              ? colorTheme.surface
                              : colorTheme.surfaceContainer,
                        ),
                        // child: recordingState == RecordingState.notRecording
                        //     ? _buildChatField(
                        //         showEmojiPicker,
                        //         context,
                        //         hideElements,
                        //       )
                        //     : const VoiceRecorderField(),
                        child: _buildChatField(
                          showEmojiPicker,
                          context,
                          hideElements,
                        ),
                      ),
                    ),
                    const SizedBox(width: 4.0),
                    // hideElements
                    //     ?
                    IconButton.filled(
                      onPressed: () async {
                        controllerProvider.onSendBtnPressed(context);
                      },
                      style: IconButton.styleFrom(
                        shape: const CircleBorder(),
                        elevation: 0,
                        padding: EdgeInsets.zero,
                        enableFeedback: true,
                        shadowColor: colorTheme.surfaceContainerHigh,
                        iconSize: 24,
                        backgroundColor: colorTheme.primary,
                        foregroundColor: colorTheme.surface,
                        minimumSize: const Size(42, 42),
                      ),
                      tooltip: 'Send',
                      icon: const Icon(Icons.send_rounded),
                    ),
                    //  : const ChatInputMic(),
                    // : const Icon(Icons.mic_rounded),
                  ],
                ),
              ),
            ),
        // : const VoiceRecorder(),
        // : const Icon(Icons.mic_rounded),
      ),
    );
  }

  ChatField _buildChatField(
    bool showEmojiPicker,
    BuildContext context,
    bool hideElements,
  ) {
    return ChatField(
      leading: IconButton(
        onPressed: switchKeyboards,
        icon: Icon(
          !showEmojiPicker ? Icons.emoji_emotions : Icons.keyboard,
          size: 24.0,
        ),
      ),
      focusNode: controllerProvider.fieldFocusNode,
      onTextChanged: (value) => controllerProvider.onTextChanged(value),
      textController: controllerProvider.controller.messageController,
      actions: [
        IconButton(
          style: IconButton.styleFrom(minimumSize: const Size(22, 22)),
          onPressed: () {
            //   onAttachmentsIconPressed(context);
          },
          icon: Transform.rotate(
            angle: -0.8,
            child: const Icon(Icons.attach_file_rounded, size: 24.0),
          ),
        ),
        if (!hideElements) ...[
          IconButton(
            style: IconButton.styleFrom(minimumSize: const Size(22, 22)),
            onPressed: () {
              controllerProvider.navigateToCameraView(context);
            },
            icon: const Icon(Icons.camera_alt_rounded, size: 24.0),
          ),
        ],
      ],
    );
  }

  void onAttachmentsIconPressed(BuildContext context) {
    final focusNode = controllerProvider.fieldFocusNode;
    focusNode.unfocus();
    Future.delayed(
      Duration(
        milliseconds: MediaQuery.of(context).viewInsets.bottom > 0 ? 300 : 0,
      ),
      () async {
        if (!context.mounted) return;
        showDialog(
          barrierColor: null,
          context: context,
          builder: (context) {
            return Dialog(
              alignment: Alignment.bottomCenter,
              insetPadding: EdgeInsets.symmetric(
                horizontal: 10.0,
                vertical: controllerProvider.showEmojiPicker ? 36.0 : 56.0,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16.0),
              ),
              elevation: 0,
              child: const Padding(
                padding: EdgeInsets.only(top: 24.0),
                // child: AttachmentPicker(),
                child: Icon(Icons.attach_file_rounded),
              ),
            );
          },
        );
      },
    );
  }
}

class ControllerProvider extends ChangeNotifier {
  final ChatController controller;
  ControllerProvider({required this.controller});
  bool _showEmojiPicker = false;
  final FocusNode _fieldFocusNode = FocusNode();
  bool _hideElements = false;

  void initRecorder() {}

  void setShowEmojiPicker(bool value) {
    _showEmojiPicker = value;
    notifyListeners();
  }

  void onTextChanged(String value) {
    controller.messageController.text = value;
    notifyListeners();
  }

  void navigateToCameraView(BuildContext context) {
    notifyListeners();
  }

  void onSendBtnPressed(BuildContext context) {
    notifyListeners();
  }

  bool get showEmojiPicker => _showEmojiPicker;
  FocusNode get fieldFocusNode => _fieldFocusNode;
  bool get hideElements => _hideElements;

  void setHideElements(bool value) {
    _hideElements = value;
    notifyListeners();
  }
}
