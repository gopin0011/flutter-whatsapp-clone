import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:whatsapp_ui/common/enums/message_enum.dart'; 

class MessageReply {
  final String message;
  final bool isMe;
  final MessageEnum messageEnum;

  MessageReply({
    required this.message, 
    required this.isMe, 
    required this.messageEnum,
  });
}

// Gunakan autoDispose agar memory tidak bocor saat pindah screen
final messageReplyProvider = StateProvider.autoDispose<MessageReply?>((ref) => null);