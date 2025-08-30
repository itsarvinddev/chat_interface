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
            .select('*')
            .order('created_at', ascending: false)
            .limit(pageSize)
            .range(start, end)
            .select();
        log(result.toString());
        return result.map((e) => ChatMessageMapper.fromMap(e)).toList();
      },
    );
