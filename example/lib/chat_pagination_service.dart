import 'dart:developer';

import 'package:chatui/chatui.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

int pageSize = 100;

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
        final result = await supabase
            .from('chat_messages')
            .select('*, sender:chat_messages_sender_id_fkey(*)')
            .eq('room_id', "63e2364b-e0b5-4b30-b392-595944f2955b")
            .order('created_at', ascending: false)
            .limit(pageSize)
            .range(start, end);
        return result
            .map(
              (e) => ChatMessageMapper.fromMap(e)
                ..sender = ChatUserMapper.fromMap(e['sender'])
                ..createdAt = DateTime.tryParse(
                  e['created_at'].toString(),
                )?.toLocal(),
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
      //  'public:chat_messages:room_id=eq.63e2364b-e0b5-4b30-b392-595944f2955b',
      'chat_messages',
    );
    channel
        .onPostgresChanges(
          event: PostgresChangeEvent.all,
          schema: 'public',
          table: 'chat_messages',
          filter: PostgresChangeFilter(
            type: PostgresChangeFilterType.eq,
            column: 'room_id',
            value: "63e2364b-e0b5-4b30-b392-595944f2955b",
          ),
          callback: (PostgresChangePayload payload) async {
            final message = ChatMessageMapper.fromMap(payload.newRecord);
            message.createdAt = DateTime.tryParse(
              payload.newRecord['created_at'].toString(),
            )?.toLocal();
            message.sender = allUsers.firstWhereOrNull(
              (user) => user.id == message.senderId,
            );
            final isSelfSender = message.senderId == currentUser.id;
            if (payload.eventType == PostgresChangeEvent.insert) {
              log(payload.eventType.name);
              if (isSelfSender) return;

              /// add new message to listing page
              final pages = List<List<ChatMessage>>.from(
                controller.pages ?? [],
              );
              pages.first = [message, ...pages.first];
              controller.value = controller.value.copyWith(pages: pages);

              /// update status to seen
              await supabase
                  .from('chat_messages')
                  .update({'status': ChatMessageStatus.seen.name})
                  .eq('id', message.id);
              return;
            }
            if (payload.eventType == PostgresChangeEvent.update) {
              log(payload.eventType.name);
              final message = ChatMessageMapper.fromMap(payload.newRecord);
              message.createdAt = DateTime.tryParse(
                payload.newRecord['created_at'].toString(),
              )?.toLocal();
              message.sender = allUsers.firstWhereOrNull(
                (user) => user.id == message.senderId,
              );
              message.chatStatus = ChatMessageStatus.seen;
              controller.mapItems(
                (item) => item.id == message.id ? message : item,
              );
              return;
            }
          },
        )
        .subscribe();
  } catch (e) {
    log(e.toString());
  }
}
