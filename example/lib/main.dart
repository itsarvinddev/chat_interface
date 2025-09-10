import 'package:chat_interface/chat_interface.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Supabase.initialize(
    url: 'YOUR_SUPABASE_URL',
    anonKey: 'YOUR_SUPABASE_ANON_KEY',
  );
  initializeChatInterface();
  runApp(MaterialApp(home: ChatPage(roomId: 'room-1')));
}

class ChatPage extends HookConsumerWidget {
  final String roomId;
  const ChatPage({super.key, required this.roomId});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final focusNode = useFocusNode();
    final scrollController = useScrollController();
    final snapshot = ref.watch(
      chatControllerXProvider(
        roomId: roomId,
        focusNode: focusNode,
        scrollController: scrollController,
      ),
    );
    final roomName = useMemoized(
      () => snapshot.valueOrNull?.getRoomAs<RoomModel>()?.roomTitle ?? '',
      [snapshot],
    );

    return Theme(
      data: context.theme.copyWith(
        colorScheme: context.colorScheme.copyWith(
          primary: context.colors.contentPrimary.withValues(alpha: 0.85),
          secondary: context.colors.contentSecondary,
          surface: context.colors.surface,
          secondaryContainer: context.colors.surfaceTint,
          inversePrimary: context.colors.backgroundInversePrimary.withValues(
            alpha: 0.85,
          ),
          surfaceBright: context.colors.backgroundPrimary,
          onSurface: context.colors.onSurface,
          surfaceContainer: context.colors.surfaceContainerHighest,
          surfaceContainerHighest: context.colors.surfaceContainerHighest,
          outline: context.colors.borderInverseSelected,
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: false,
          contentPadding: EdgeInsets.zero,
          border: InputBorder.none,
          hintStyle: "".labelSmall(context).style,
        ),
        iconButtonTheme: IconButtonThemeData(
          style: IconButton.styleFrom(
            backgroundColor: context.colors.surfaceContainerHighest,
            foregroundColor: context.colors.onSurface,
          ),
        ),
      ),
      child: Builder(
        builder: (context) {
          return Scaffold(
            body: snapshot.when(
              data: (controller) => controller == null
                  ? ErrorWidget.withDetails(message: "Controller is null")
                  : ChatInterface(
                      controller: controller,
                      config: ChatUiConfig(
                        scaffold: ChatExtra.scaffoldConfig(context),
                        theme: ChatExtra.chatTheme(context),
                        customMessage: (controller, message, index) =>
                            CustomChatCard(
                              controller: controller,
                              message: message,
                              index: index,
                            ),
                      ),
                    ),
              error: (error, stackTrace) =>
                  ErrorWidget.withDetails(message: "Error: $error"),
              loading: () => const Center(child: CircularProgressIndicator()),
            ),
          );
        },
      ),
    );
  }
}

class ChatExtra {
  static ScaffoldConfig scaffoldConfig(BuildContext context) => ScaffoldConfig(
    background: Container(
      decoration: BoxDecoration(
        image: DecorationImage(
          image: CachedNetworkImageProvider(
            ImageWrapper(
                  imageId: 'chat-background-1.png',
                  bucketId: 'assets',
                ).toSupabaseUrl ??
                'https://web.whatsapp.com/img/bg-chat-tile-dark_a4be512e7195b6b733d9110b408f075d.png',
          ),
          fit: BoxFit.cover,
          colorFilter: ColorFilter.mode(
            context.colors.neutral100,
            BlendMode.exclusion,
          ),
          alignment: Alignment.center,
          opacity: 0.6,
          filterQuality: FilterQuality.high,
          isAntiAlias: true,
        ),
        color: context.colors.backgroundPrimary,
      ),
    ),
  );

  static ChatTheme chatTheme(BuildContext context) =>
      ChatTheme.fromMaterialTheme(context.theme).copyWith(
        inputTextStyle: context.bodyMedium.copyWith(
          color: context.colors.contentPrimary,
        ),
        receivedMessageTextStyle: context.bodyMedium.copyWith(
          color: context.colors.contentPrimary,
        ),
        timestampColor: context.colors.onSurfaceVariant,
        attachmentButtonColor: context.colors.borderInverseOpaque,
        sentMessageTextStyle: context.bodyMedium.copyWith(
          color: context.colors.contentInversePrimary,
        ),
      );
}

class CustomChatCard extends StatelessWidget {
  final ChatController controller;
  final ChatMessage message;
  final int index;
  const CustomChatCard({
    super.key,
    required this.controller,
    required this.message,
    required this.index,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient: LinearGradient(
          colors: [
            context.colors.contentPrimary,
            context.colors.contentSecondary,
          ],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      child: Column(
        children: [
          message.message.toCurrency().headingSmall(
            context,
            color: context.colors.contentInversePrimary,
          ),
          "You offered".labelSmall(
            context,
            color: context.colors.contentInversePrimary.withValues(alpha: 0.6),
          ),
        ],
      ),
    );
  }
}
