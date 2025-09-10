import 'package:chatui/chatui.dart';
import 'package:flutter/material.dart';
import 'package:screwdriver/screwdriver.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/uuid.dart';

part 'provider.g.dart';

@riverpod
Future<ChatController?> chatControllerX(
  Ref ref, {
  required String roomId,
  required FocusNode focusNode,
  required ScrollController scrollController,
}) async {
  try {
    const pageSize = 100;
    final supabase = Supabase.instance.client;
    final currentUser = supabase.auth.currentUser;
    final roomCurrentUser = ChatUser(
      id: currentUser?.id ?? '',
      name: currentUser?.email ?? '',
    );
    if (currentUser == null) {
      return null;
    }
    final room = await supabase
        .from('rooms')
        .select('*')
        .eq('id', roomId)
        .single();
    final pagingController = PagingController<int, ChatMessage>(
      getNextPageKey: (PagingState<int, ChatMessage> state) {
        final keys = state.keys ?? [];
        final pages = state.pages;
        // Initial page key.
        if (keys.isNullOrEmpty) return 0;

        // Check for last page.
        if (pages != null && pages.last.length < pageSize) {
          return null; // <-- this is it
        }

        // Next page key.
        return keys.last + 1;
      },
      fetchPage: (pageKey) async {
        final queries = supabase
            .from('messages')
            .select('*, sender:messages_room_member_fk(*)')
            .eq('room_id', roomId)
            .order('created_at', ascending: false)
            .range(pageKey, pageKey + pageSize - 1)
            .limit(pageSize);
        final data = await queries;
        if (data.isNullOrEmpty) {
          throw Exception('No data found');
        }
        return data.map((e) => ChatMessageMapper.fromMap(e)).toList();
      },
    );
    final controller = ChatController(
      scrollController: scrollController,
      currentUser: roomCurrentUser,

      /// add other users here
      otherUsers: [/* ...room.peerUsers */],
      pagingController: pagingController,
      focusNode: focusNode,
    );
    controller.uuidGenerator = () => Uuid().v4();
    controller.onMessageAdded = (message) async {
      // call your api to send message
    };
    // controller.onTapCamera = () async {};
    // controller.onTapAttachFile = () async {};
    controller.onMarkAsSeen = (message) async {
      // call your api to mark message as seen
    };
    controller.setRoom(room);

    /// set your own camera and attach file icons (optional)
    // controller.cameraIcon = PRIcons.currencyInr;
    // controller.attachFileIcon = PRIcons.paperclip;
    controller.onTapCamera = () async {
      // custom camera action
    };
    return controller;
  } catch (e) {
    return null;
  }
}
