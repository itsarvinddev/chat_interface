
import 'package:supabase_flutter/supabase_flutter.dart';

extension ChatSupabaseExtensions on SupabaseClient {
  SupabaseQueryBuilder get chatUsers => from('chat_users');
  SupabaseQueryBuilder get chatMessages => from('chat_messages');
  SupabaseQueryBuilder get chatAttachments => from('chat_attachments');
  SupabaseQueryBuilder get chatReactions => from('chat_reactions');
  SupabaseQueryBuilder get chatReplyMessages => from('chat_reply_messages');
}
