import 'dart:developer';

import 'package:chatui/chatui.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

int pageSize = 20;

PagingController<int, ChatMessage> controller() =>
    PagingController<int, ChatMessage>(
      getNextPageKey: (PagingState<int, ChatMessage> state) {
        final keys = state.keys ?? [];
        final pages = state.pages;
        // Initial page key.
        if (keys.isEmpty) return 0;

        // Check for last page.
        if (pages != null && pages.last.length < pageSize) {
          return null; // <-- this is it
        }

        // Next page key.
        return keys.last + 1;
      },
      fetchPage: (int pageKey) async {
        final supabase = Supabase.instance.client;
        final start = pageKey * pageSize;
        final end = start + pageSize - 1;
        log('start: $start, end: $end');
        final result = await supabase
            .from('chat_messages')
            .select('*, sender:chat_messages_sender_id_fkey(*)')
            .eq('room_id', "63e2364b-e0b5-4b30-b392-595944f2955b")
            .order('created_at', ascending: false)
            .limit(pageSize)
            .range(start, end);
        return result
            .map(
              (e) =>
                  ChatMessageMapper.fromMap(e)
                    ..sender = ChatUserMapper.fromMap(e['sender']),
            )
            .toList();
      },
    );

void stream(
  ChatUser currentUser,
  PagingController<int, ChatMessage> controller,
  List<ChatUser> allUsers,
) async {
  try {
    log('stream function called');
    final supabase = Supabase.instance.client;
    final channel = supabase.channel(
      'public:chat_messages:room_id=eq.63e2364b-e0b5-4b30-b392-595944f2955b',
    );
    channel
        .onPostgresChanges(
          event: PostgresChangeEvent.insert,
          schema: 'public',
          table: 'chat_messages',
          callback: (PostgresChangePayload payload) {
            final message = ChatMessageMapper.fromMap(payload.newRecord);
            message.sender = allUsers.firstWhere(
              (user) => user.id == message.senderId,
            );
            if (message.senderId == currentUser.id) return;
            controller.value = controller.value.copyWith(
              pages: controller.pages
                  ?.map((page) => [message, ...page])
                  .toList(),
            );
          },
        )
        .subscribe();
  } catch (e) {
    log(e.toString());
  }
}
